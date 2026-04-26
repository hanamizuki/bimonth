# macOS Bimonthly Calendar Widget — Spec

## 1. Overview

A clean calendar widget for the macOS desktop and Notification Center showing two months side by side. The displayed range shifts automatically with the current date, so users see both "the recent past" and "the upcoming future" without manual switching.

### 1.1 Goals

- See the date layout for the two surrounding months at a glance
- Auto-shift the visible range based on date — no manual switching
- Visually clean, consistent with the macOS native style
- Light/dark mode support

### 1.2 Non-goals (out of scope for this version)

- Calendar events, reminders, period markers, or other dot indicators
- Week or year views
- Tap-to-open a date in the system Calendar app
- User settings (first-day-of-week, theme color, etc.)

## 2. Functional spec

### 2.1 What is shown

Two months rendered side by side. Each month contains:

- Month title (e.g. `APRIL`, fully uppercased month name with no year — matches the system Calendar widget)
- Weekday header row (S M T W T F S, reordered to match the system first-day-of-week)
- Day grid (6 rows × 7 cols = 42 cells)
  - In-month weekdays render in the primary text color; in-month weekends in the secondary color
  - Out-of-month leading/trailing cells render blank (no number) but keep their slot for grid alignment, matching the system Calendar widget
  - Today renders with a solid red circle background and white digit

### 2.2 Display range switching

Decided by today's day-of-month (`day` is 1–31):

| Condition          | Left month | Right month |
|--------------------|------------|-------------|
| `day < 7` (1–6)    | Previous   | Current     |
| `day >= 7` (7–31)  | Current    | Next        |

**Switch day:** the 7th flips to "current + next." On the 7th, more than three weeks of the current month still lie ahead, so showing the next month is more useful.

### 2.3 Auto-update

The widget needs to refresh at:

- Daily 00:00 — the today highlight moves to the new date
- Switch day (7th of each month) 00:00 — switch from "previous + current" to "current + next"
- 1st of each month 00:00 — within "current + next," the current month becomes the new month

Implementation: each `getTimeline` call generates 7 entries (one per day at midnight) with `policy = .atEnd`; the system schedules them automatically.

## 3. Technical spec

### 3.1 Stack

- **Language:** Swift
- **Frameworks:** WidgetKit + SwiftUI
- **Minimum OS:** macOS 14 (Sonoma)
- **Widget size:** `.systemMedium` only

### 3.2 Display range switching logic

See `BimonthWidget/Logic/MonthResolver.swift`. Pure function, easy to unit-test.

### 3.3 Timeline strategy

`Provider.getTimeline` produces 7 entries (one per day at 00:00) with `policy = .atEnd`. The system requests a fresh timeline after the last entry.

## 4. Visual design

### 4.1 Layout

- Outer corner radius: WidgetKit default (`.containerBackground`)
- Outer padding: handled by `.containerBackground` — no extra padding
- Spacing between the two months: 16pt

### 4.2 Typography

Fixed pt sizes rather than Dynamic Type, to match the compact grid density of the system Calendar widget; widget text doesn't fully scale with Dynamic Type anyway. Specific pt sizes and tracking values evolve during visual iteration — treat the source as the source of truth (see `MonthView.swift` / `DayCell.swift`). Structural decisions:

- Month title: bold, with letter tracking (specific value in source)
- Weekday header: medium
- Day numbers: medium; weekday vs. weekend differentiated by **color**, not weight, to avoid rendering jitter at small sizes
- Day grid row spacing: 3pt — gives the grid breathing room similar to the system Calendar widget

Note: an earlier version used `.monospacedDigit()` and weekday-conditional weight; switched to uniform weight + color contrast for visual stability.

### 4.3 Colors

Brand-mapped where the palette asserts identity (month title, today highlight); system semantic everywhere else so light/dark mode adapts automatically without a custom dark palette. The full palette and design rationale live in `.impeccable.md` at the repo root; the table below only documents how those tokens map to widget elements.

| Element                       | Color                                          |
|-------------------------------|------------------------------------------------|
| Month title                   | `.brandBark` (#585142, warm brown)             |
| Weekday header (weekday cols) | `.primary`                                     |
| Weekday header (weekend cols) | `.secondary`                                   |
| In-month weekday              | `.primary`                                     |
| In-month weekend              | `.secondary`                                   |
| Out-of-month days             | Blank (`Color.clear` placeholder)              |
| Today background circle       | `.brandSage` (#8AAB94, muted green)            |
| Today digit                   | `.brandParchment` (#EBDAB2, warm cream)        |

Brand tokens are defined in `Shared/Colors.swift` and shared by both the container app and the widget extension via `project.yml`.

**Dark-mode caveat (follow-up):** `brandBark` is a dark warm brown and will read poorly on a dark widget background. The current implementation defines only light-mode hex values; migrating `Shared/Colors.swift` to Asset Catalog Color Sets with explicit light/dark pairs is the next step. `brandSage` and `brandParchment` (the today highlight) read in both modes and do not need adjustment.

### 4.4 First-day-of-week

Follows `Calendar.current.firstWeekday`. Defaults vary by region: Sunday (1) in many regions, Monday (2) in much of Europe. Both the weekday header and the day grid adjust accordingly.

## 5. Edge cases

### 5.1 Year crossover

- After Dec 7: show December + January of next year
- Jan 1–6: show December of last year + January

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
- `2026-01-03` (day=3) → `(2025-12, 2026-01)`
- `2025-12-15` (day=15) → `(2025-12, 2026-01)`
- Month-end `2026-04-30` → `(2026-04, 2026-05)`

### 6.2 Visual checks

- Today highlight lands on the correct cell
- Out-of-month days render blank (no digit)
- Year-crossover months render in the correct left-to-right order (year is not shown, but order must be right)
- Light/dark mode switching
- Different first-day-of-week settings

## 7. Future directions (out of scope for this version)

- `.systemLarge` support: four months in a 2×2 layout
- EventKit integration to render event dots
- User-configurable first-day-of-week and theme color via Widget configuration
- Tap-to-open in the system Calendar app at the tapped date via `widgetURL`
