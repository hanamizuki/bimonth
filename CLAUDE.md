# Bimonth — Notes for AI Agents & Future Sessions

This file captures hard-won, non-obvious knowledge about working in this repo.
For product/feature scope see [`docs/spec.md`](docs/spec.md); for the visual
system see [`DESIGN.md`](DESIGN.md); for setup see [`README.md`](README.md).

## Build / regenerate workflow

The `.xcodeproj` is generated from `project.yml` by [XcodeGen](https://github.com/yonaskolb/XcodeGen).
Whenever `project.yml` changes, regenerate before building:

```bash
xcodegen generate
xcodebuild -project Bimonth.xcodeproj -scheme Bimonth \
  -configuration Debug -destination 'platform=macOS' build
```

After regenerating you may see SourceKit "Cannot find … in scope" diagnostics
in the editor for a few seconds while Xcode re-indexes. They are not real
build errors — `xcodebuild` will succeed.

## Critical: `ENABLE_DEBUG_DYLIB: NO`

**Do not remove this from `project.yml`.** Xcode 16+ defaults Debug builds
to a thin main binary plus a separate `<Target>.debug.dylib` for faster
incremental linking. macOS WidgetKit's host process (`chronod`) cannot
follow the `@rpath` load to the split dylib in its sandbox. When the dylib
fails to load, chronod silently falls back to its last successful **snapshot
cache** of the widget — your code changes never reach the rendered widget,
no matter how many times you rebuild, kill processes, or remove and re-add
the widget on the desktop.

Symptoms when this regresses:
- Widget picker preview shows the latest code (rendered on demand)
- Widget on desktop renders an older state, sometimes very old
- Killing `chronod`, re-registering with `pluginkit`, removing/re-adding the
  widget — none of it helps

Setting `ENABLE_DEBUG_DYLIB: NO` forces a monolithic binary that chronod
loads cleanly. `ENABLE_PREVIEWS: YES` is independent and can stay on for
SwiftUI Previews in the Xcode IDE.

## Xcode skips the widget target on incremental builds

When you change only files in the `Bimonth` target (e.g. `ContentView.swift`,
`BimonthApp.swift`) and run `xcodebuild`, Xcode's incremental linker may
**not** rebuild the `BimonthWidget` extension — it concludes nothing the
widget depends on changed. The container app gets your edits, the desktop
widget keeps running yesterday's binary, and the file timestamp on the
`.appex` is misleading (codesign rewrites it without recompiling).

If a widget edit doesn't appear after rebuild, before chasing snapshot
caches, force a clean build:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Bimonth-*
xcodegen generate
xcodebuild -project Bimonth.xcodeproj -scheme Bimonth \
  -configuration Debug -destination 'platform=macOS' build
```

Then continue with the reload workflow below.

## Widget reload workflow during development

Even with the binary loading correctly, widgets are aggressively cached. After
a build, force a reload:

```bash
APPEX="$HOME/Library/Developer/Xcode/DerivedData/Bimonth-*/Build/Products/Debug/Bimonth.app/Contents/PlugIns/BimonthWidget.appex"
pluginkit -r $APPEX
pluginkit -a $APPEX
killall BimonthWidget chronod 2>/dev/null
```

Then on the desktop: remove the existing Bimonth widget and add it again
from **Edit Widgets**. The picker preview alone is not a sufficient test —
the desktop instance goes through chronod's snapshot pipeline and may
behave differently from the picker.

`launchctl kickstart -k gui/$(id -u)/com.apple.chronod` is rejected by SIP;
use `killall chronod` instead (it auto-respawns).

## Where macOS caches widget state

| Location | Contents | Notes |
|---|---|---|
| `~/Library/Group Containers/group.com.apple.chronod/chronod/chrono.sql` | Timeline + snapshot DB | TCC-protected; can't read directly. |
| `~/Library/Caches/com.apple.chrono/widget-relevance-cache/` | Sort/relevance | Safe to delete. |
| `/var/folders/*/com.apple.chrono/` | Per-user temp / snapshot images | Safe to delete. |
| `/var/folders/*/com.apple.widgetkit.simulator/` | Picker preview cache | Safe to delete. |

Wiping `chrono.sql` resets every widget on the system, not just Bimonth, so
treat it as nuclear. In practice `ENABLE_DEBUG_DYLIB: NO` plus the reload
workflow above is enough; you should never need to touch these caches.

## Widget `kind` is a stable identity

`BimonthWidget.swift`'s `kind: String = "BimonthWidget"` is a contract with
WidgetKit. Bumping it orphans every installed instance and forces users to
re-add the widget. Only change it deliberately. (During pre-release review
it was iterated as a debug aid; the resolved name is intentional and should
not change without a migration plan.)

## Versioning

`CURRENT_PROJECT_VERSION` and `MARKETING_VERSION` live in `project.yml` base
settings (the widget's `Info.plist` substitutes via `$(...)`). Keep them in
sync to avoid the `embeddedBinaryValidationUtility` warning at build time.

**Bump `CURRENT_PROJECT_VERSION` whenever the widget's code or behavior
changes** — not just for public releases. `chronod` keys its widget descriptor
cache (`ExtensionMetadata` in `chrono.sql`) on the extension's
`CFBundleVersion`. If the version is unchanged, chronod treats the widget as
identical and never re-ingests the descriptor, so an already-installed machine
keeps rendering the old snapshot and old configuration surface — no amount of
rebuilding, `pluginkit` re-registration, or removing/re-adding the widget
helps. This bit us twice (the `StaticConfiguration` → `AppIntentConfiguration`
switch, then the navigation-button layout fix): both shipped with the version
left at `1` and were invisible on installed widgets until the version was
bumped. Verify with:

```bash
DB="$HOME/Library/Group Containers/group.com.apple.chronod/chronod/chrono.sql"
sqlite3 "file:$DB?mode=ro" "SELECT bundleIdentifier, version FROM ExtensionMetadata;"
# the version column reads like "2-2-(…)"; the leading number is CFBundleVersion.
```

## Brand palette is shared across both targets

`Shared/Colors.swift` is included by both the container app and the widget
extension via `project.yml` (`path: Shared` under each target's `sources`).
`brandBark` uses `NSColor`'s `name:dynamicProvider:` API for light/dark
adaptation; the rest are static. Source of truth for hex values is
[`DESIGN.md`](./DESIGN.md).
