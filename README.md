# Bimonth

A macOS desktop bimonthly-calendar widget. Shows two months side by side and shifts the displayed range based on the current date so you can see both "the recent past" and "the upcoming future" at a glance.

<img src="docs/screenshot.png" width="448" alt="Bimonth container app — vintage tear-off calendar icon above a live two-month preview (April and May with today highlighted) and instructions for adding the widget to the desktop">


Full spec: [`docs/spec.md`](docs/spec.md).

## Display range

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

Paste this into Claude Code, Cursor, Codex, or any AI coding agent that can run commands in this repo to automate the setup above:

> You are helping me set up Bimonth on this macOS machine. First read `README.md` and `CLAUDE.md` for context, then:
>
> 1. Confirm Xcode 16+ is installed (`xcodebuild -version`). If not, stop and tell me to install it from the Mac App Store.
> 2. Install `xcodegen` if it's missing (`brew install xcodegen`).
> 3. Ask me for a reverse-DNS bundle prefix (e.g. `com.alice.bimonth`) and replace every occurrence of `com.example` in `project.yml` with it.
> 4. Run `xcodegen generate`.
> 5. Build the Debug `Bimonth` scheme for macOS with `xcodebuild`.
> 6. On a successful build, open the produced `Bimonth.app` and walk me through the widget reload steps from `CLAUDE.md` so `chronod` picks up the fresh extension.
> 7. Tell me to add the widget via right-click desktop → Edit Widgets.
>
> If any step fails, stop and ask before proceeding. Do not commit, push, or modify anything outside this repo.

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
│   ├── Provider.swift              # TimelineProvider
│   ├── CalendarEntry.swift         # TimelineEntry model
│   ├── Info.plist
│   ├── BimonthWidget.entitlements
│   ├── Logic/
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
