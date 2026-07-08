# Bimonth

A macOS desktop bimonthly-calendar widget. Shows two months side by side, shifts the displayed range based on the current date, and lets you browse nearby months with inline controls.

<img src="docs/screenshot.png" width="448" alt="Bimonth container app — vintage tear-off calendar icon above a live two-month preview (April and May with today highlighted) and instructions for adding the widget to the desktop">


Full spec: [`docs/spec.md`](docs/spec.md).

## Default display range

By default, Bimonth switches on day 7. You can change the switch day from Edit
Widget; values 1-31 are supported, and short months clamp to their last day.

| Condition | Left month | Right month |
|-----------|------------|-------------|
| Day 1–6   | Previous   | Current     |
| Day 7–31  | Current    | Next        |

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 16 or later (unit tests use Swift Testing)
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## First-time setup

1. Edit `project.yml` and replace every occurrence of `com.example` with your own reverse-DNS prefix (the `bundleIdPrefix` plus the three `PRODUCT_BUNDLE_IDENTIFIER` values), so Xcode can sign the targets against your Apple ID.
2. Generate the Xcode project and open it:

   ```bash
   cd path/to/bimonth
   xcodegen generate
   open Bimonth.xcodeproj
   ```

3. On first launch, Xcode prompts for a Development Team for both targets (`Bimonth` and `BimonthWidget`); a personal Apple ID works.

## Prompt for Claude Code or other coding agents

Paste this into Claude Code, Cursor, Codex, or any AI coding agent that can run shell commands. It clones the repo and walks all the way through to a working desktop widget — you don't need to download anything yourself first.

```
You are helping me install Bimonth on this macOS machine. The repo
is at https://github.com/hanamizuki/bimonth.

1. Clone the repo into the current directory and `cd` into it:
   `git clone https://github.com/hanamizuki/bimonth.git && cd bimonth`.
   (If I say I want to contribute back, fork first with
   `gh repo fork --clone` instead.)
2. Read `README.md` and `CLAUDE.md` for context.
3. Confirm Xcode 16+ is installed (`xcodebuild -version`). If not,
   stop and tell me to install it from the Mac App Store.
4. Install `xcodegen` if it's missing (`brew install xcodegen`).
5. Ask me for a reverse-DNS bundle prefix (e.g. `com.alice.bimonth`)
   and replace every occurrence of `com.example` in `project.yml`
   with it.
6. Run `xcodegen generate`.
7. Build the Debug `Bimonth` scheme for macOS with `xcodebuild`.
8. On a successful build, open the produced `Bimonth.app` and walk
   me through the widget reload steps from `CLAUDE.md` so `chronod`
   picks up the fresh extension.
9. Tell me to add the widget via right-click desktop → Edit Widgets.

If any step fails, stop and ask before proceeding. Do not commit or
push anything without my explicit say-so.
```

## Running the widget

1. In Xcode, select the `Bimonth` scheme and Build & Run (this launches the container app).
2. Right-click the desktop → Edit Widgets → find `Bimonth` → drag it onto the desktop or Notification Center.

## Running unit tests

```bash
xcodebuild test -project Bimonth.xcodeproj -scheme Bimonth -destination 'platform=macOS'
```

Or press ⌘U in Xcode.

## Project layout

```
bimonth/
├── project.yml                     # xcodegen config; .xcodeproj is generated from this
├── Bimonth/                        # Container app (minimal — exists only to host the widget extension)
│   ├── BimonthApp.swift
│   ├── ContentView.swift
│   ├── Bimonth.entitlements
│   └── Assets.xcassets/
├── BimonthWidget/                  # Widget extension (the widget itself)
│   ├── BimonthWidgetBundle.swift   # @main WidgetBundle
│   ├── BimonthWidget.swift         # Widget configuration
│   ├── Provider.swift              # AppIntentTimelineProvider
│   ├── CalendarEntry.swift         # TimelineEntry model
│   ├── Info.plist
│   ├── BimonthWidget.entitlements
│   ├── Configuration/
│   │   └── BimonthConfigurationIntent.swift
│   ├── Intents/
│   │   └── ChangeMonthOffsetIntent.swift
│   ├── Logic/
│   │   ├── BimonthWidgetConstants.swift
│   │   ├── MonthNavigationStore.swift
│   │   └── MonthResolver.swift     # Pure function deciding which two months to show
│   ├── Views/
│   │   ├── CalendarWidgetView.swift
│   │   ├── MonthView.swift
│   │   └── DayCell.swift
│   └── Assets.xcassets/
└── BimonthTests/
    └── MonthResolverTests.swift    # Edge-case coverage for MonthResolver
```

## Contributing

Issues and pull requests are welcome. Please read [`docs/spec.md`](docs/spec.md) first so changes stay aligned with the design intent.

## License

[MIT](LICENSE) © Hana Chang
