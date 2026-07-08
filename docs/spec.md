# macOS Bimonthly Calendar Widget — Spec

## 1. Overview

A clean calendar widget for the macOS desktop and Notification Center showing
two months side by side. The displayed range shifts automatically with the
current date and configured switch day, while chevron controls let users browse
nearby months manually.

### 1.1 Goals

- See the date layout for the two surrounding months at a glance
- Auto-shift the visible range based on a configurable switch day
- Let users manually browse the previous or next displayed month pair from the widget
- Visually clean, consistent with the macOS native style
- Light/dark mode support

### 1.2 Non-goals (out of scope for this version)

- Calendar events, reminders, period markers, or other dot indicators
- Week or year views
- Tap-to-open a date in the system Calendar app
- Full settings beyond the month switch day (theme color, custom calendar system, etc.)

## 2. Functional spec

### 2.1 What is shown

Two months rendered side by side. Each month contains:

- Month title (e.g. `APRIL`, fully uppercased month name with no year — matches the system Calendar widget)
- Weekday header row (S M T W T F S, reordered to match the system first-day-of-week)
- Day grid (6 rows × 7 cols = 42 cells)
  - In-month weekdays render in the primary text color; in-month weekends in the secondary color
  - Out-of-month leading/trailing cells render blank (no number) but keep their slot for grid alignment, matching the system Calendar widget
  - Today renders with a solid sage circle background and high-contrast digit
- Previous/next chevron buttons sit at the widget's left and right edges and
  shift the displayed pair by one month backward or forward.

### 2.2 Display range switching

Decided by today's day-of-month (`day` is 1–31) and the widget's configured
`switchDay`. `switchDay` is configurable from Edit Widget, defaults to 7, and
accepts values 1–31. If the configured day does not exist in the current month
(for example 31 in February), the effective switch day is clamped to that
month's last day.

| Condition            | Left month | Right month |
|----------------------|------------|-------------|
| `day < switchDay`    | Previous   | Current     |
| `day >= switchDay`   | Current    | Next        |

**Default switch day:** the 7th flips to "current + next." On the 7th, more
than three weeks of the current month still lie ahead, so showing the next
month is more useful.

### 2.3 Manual month navigation

The widget has left and right chevron buttons:

| Button | Behavior |
|--------|----------|
| Left chevron | Decrease the shared month offset by 1 |
| Right chevron | Increase the shared month offset by 1 |

The offset is applied after the automatic range is resolved. For example, on a
date that resolves to April + May, tapping the right chevron once shows May +
June. The offset is shared across all installed Bimonth widget instances; the
Edit Widget switch day remains per widget instance. The shared offset is bounded
to 24 months backward or forward from the automatic range.

### 2.4 Auto-update

The widget needs to refresh at:

- Daily 00:00 — the today highlight moves to the new date
- Configured switch day 00:00 — switch from "previous + current" to "current + next"
- 1st of each month 00:00 — within "current + next," the current month becomes the new month
- Any manual chevron tap — the App Intent updates the shared month offset and
  requests a widget timeline reload

Implementation: each `timeline(for:in:)` call generates 7 entries (one per day
at midnight) with `policy = .atEnd`; the system schedules them automatically.

## 3. Technical spec

### 3.1 Stack

- **Language:** Swift
- **Frameworks:** WidgetKit + SwiftUI + App Intents
- **Minimum OS:** macOS 14 (Sonoma)
- **Widget size:** `.systemMedium` only

### 3.2 Display range switching logic

See `BimonthWidget/Logic/MonthResolver.swift`. Pure function, easy to unit-test.
The resolver accepts `switchDay` and `monthOffset`, clamps impossible switch
days to the current month's last day, and keeps the resulting months adjacent.

### 3.3 Timeline strategy

`Provider.timeline(for:in:)` produces 7 entries (one per day at 00:00) with
`policy = .atEnd`. The system requests a fresh timeline after the last entry.
The provider is an `AppIntentTimelineProvider`, so each entry receives the
widget's `BimonthConfigurationIntent` values.

### 3.4 Widget configuration and interaction

- `BimonthConfigurationIntent` powers Edit Widget and stores the per-instance
  switch day.
- `ChangeMonthOffsetIntent` powers the left/right chevron buttons.
- `MonthNavigationStore` stores one shared month offset for the Bimonth widget
  kind using the widget extension's defaults.

## 4. Visual design

### 4.1 Layout

- Outer corner radius: WidgetKit default (`.containerBackground`)
- Outer padding: handled by `.containerBackground` — no extra padding
- Left/right navigation gutters: 18pt each, with the chevron buttons overlaid
  on them (buttons never participate in the month content's width negotiation)
- Chevron button hit area: full gutter width × full content height
- Spacing between the two months: 16pt

### 4.2 Typography

Fixed pt sizes rather than Dynamic Type, to match the compact grid density of the system Calendar widget; widget text doesn't fully scale with Dynamic Type anyway. Specific pt sizes and tracking values evolve during visual iteration — treat the source as the source of truth (see `MonthView.swift` / `DayCell.swift`). Structural decisions:

- Month title: bold, with letter tracking (specific value in source)
- Weekday header: medium
- Day numbers: medium; weekday vs. weekend differentiated by **color**, not weight, to avoid rendering jitter at small sizes
- Day grid row spacing: 3pt — gives the grid breathing room similar to the system Calendar widget

Note: an earlier version used `.monospacedDigit()` and weekday-conditional weight; switched to uniform weight + color contrast for visual stability.

### 4.3 Colors

Brand-mapped where the palette asserts identity (month title, today highlight); system semantic everywhere else so light/dark mode adapts automatically without a custom dark palette. The full palette and design rationale live in `DESIGN.md` at the repo root; the table below only documents how those tokens map to widget elements.

| Element                       | Color                                          |
|-------------------------------|------------------------------------------------|
| Month title                   | `.brandBark` (#585142, warm brown)             |
| Weekday header (weekday cols) | `.primary`                                     |
| Weekday header (weekend cols) | `.secondary`                                   |
| In-month weekday              | `.primary`                                     |
| In-month weekend              | `.secondary`                                   |
| Out-of-month days             | Blank (`Color.clear` placeholder)              |
| Today background circle       | `.brandSage` (#8AAB94, muted green)            |
| Today digit                   | `.brandInk` (#161600, olive-black; ≈ 7.6:1 on sage) |

Brand tokens are defined in `Shared/Colors.swift` and shared by both the container app and the widget extension via `project.yml`. `brandBark` is dynamic per system appearance (light #585142 / dark #B5AD99 via `NSColor`'s `name:dynamicProvider:` API), so the month title stays legible on both bright and dark widget backgrounds. The remaining tokens are static and either work in both modes (`brandSage`, `brandParchment`) or aren't yet used on a dark surface.

### 4.4 First-day-of-week

Follows `Calendar.current.firstWeekday`. Defaults vary by region: Sunday (1) in many regions, Monday (2) in much of Europe. Both the weekday header and the day grid adjust accordingly.

## 5. Edge cases

### 5.1 Year crossover

- After the effective switch day in December: show December + January of next year
- Before the effective switch day in January: show December of last year + January

The month title doesn't show the year (matches the system Calendar widget). When months span a year boundary, the order distinguishes them (left = earlier month). Month names are produced via `DateFormatter` with locale-appropriate formatting — never hard-coded.

### 5.2 Time zone change

`Provider` builds the timeline with `Calendar.current`, so it follows the system time zone. When the user travels, the system requests a fresh timeline.

### 5.3 Daylight saving time

Use `calendar.date(byAdding: .day, value:)` instead of adding/subtracting seconds — this handles DST transitions correctly.

### 5.4 Non-Gregorian calendars

`Calendar.current` may not be Gregorian. This version uses `Calendar.current` and follows the user's preference.

## 6. Test focus

### 6.1 Unit tests (MonthResolver)

- `2026-04-06` (day=6) → `(2026-03, 2026-04)`
- `2026-04-07` (day=7) → `(2026-04, 2026-05)`
- custom `switchDay=15`: `2026-04-14` → `(2026-03, 2026-04)`
- custom `switchDay=15`: `2026-04-15` → `(2026-04, 2026-05)`
- `switchDay=31` in February clamps to the last day of February
- custom `switchDay=15` + `monthOffset=-1` resolves the switch-day range first,
  then shifts the pair backward
- `monthOffset=-1` shifts the resolved pair one month backward
- `monthOffset=+2` shifts the resolved pair two months forward
- month navigation offset clamps to the supported -24...24 range
- `2026-01-03` (day=3) → `(2025-12, 2026-01)`
- `2025-12-15` (day=15) → `(2025-12, 2026-01)`
- Month-end `2026-04-30` → `(2026-04, 2026-05)`

### 6.2 Visual checks

- Today highlight lands on the correct cell
- Out-of-month days render blank (no digit)
- Year-crossover months render in the correct left-to-right order (year is not shown, but order must be right)
- Chevron buttons appear at the left/right edges without overlapping day cells
- Light/dark mode switching
- Different first-day-of-week settings

## 7. Future directions (out of scope for this version)

- `.systemLarge` support: four months in a 2×2 layout
- EventKit integration to render event dots
- User-configurable first-day-of-week and theme color via Widget configuration
- Tap-to-open in the system Calendar app at the tapped date via `widgetURL`
