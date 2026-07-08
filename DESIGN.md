---
version: alpha
name: Bimonth
description: A glanceable two-month macOS calendar widget. Minimal, quiet, warm-earth-toned.
colors:
  ink: "#161600"
  bark: "#585142"
  stone: "#938A76"
  sage: "#8AAB94"
  parchment: "#EBDAB2"
typography:
  month-title:
    fontFamily: SF Pro
    fontSize: 9px
    fontWeight: 700
  weekday-header:
    fontFamily: SF Pro
    fontSize: 8px
    fontWeight: 500
  day-number:
    fontFamily: SF Pro
    fontSize: 10px
    fontWeight: 500
rounded:
  none: 0px
  full: 9999px
spacing:
  xs: 3px
  sm: 6px
  md: 16px
  lg: 32px
components:
  month-title:
    typography: "{typography.month-title}"
    textColor: "{colors.bark}"
  day-cell:
    typography: "{typography.day-number}"
    size: 17px
  day-cell-today:
    typography: "{typography.day-number}"
    size: 17px
    backgroundColor: "{colors.sage}"
    textColor: "{colors.ink}"
    rounded: "{rounded.full}"
  navigation-button:
    width: 16px
    textColor: system-secondary
---

> **Unit convention.** All dimensions in this document are SwiftUI **points (pt)**.
> The YAML uses `px` to satisfy the DESIGN.md spec; on macOS @1x, 1px ≈ 1pt.
> Treat every numeric value as a SwiftUI `CGFloat`, not a CSS pixel.

## Overview

Bimonth is a macOS desktop / Notification Center widget that shows two adjacent
months side by side — "the recent past and the upcoming future" — for a one-second
glance. The widget should feel like **a well-made small object**: present when
looked at, invisible when ignored. Microcopy is plainspoken; no marketing tone,
no exclamation, no productivity pressure.

The aesthetic is **Notion-influenced minimalism with occasional illustrative
warmth.** The widget surface itself stays deliberately restrained — clean
typography, restrained color, no chrome — so the illustrated app icon (a vintage
tear-off calendar in earth tones, seen in Dock and Finder) carries the brand
personality. The widget is the quiet host, not the loud guest.

Three guiding feelings: **minimal, quiet, clear.** If a design choice feels
"modern SaaS," "productivity-tool maximalism," or skeuomorphic beyond the icon,
it has drifted off-brand.

## Colors

The palette is intentionally narrow: four warm-neutral tones plus one chromatic
accent. **Sage is the only chromatic color and is reserved for a single point of
emphasis at a time** — currently the today highlight. Saturation is the drift
signal: if a color feels bright or vibrant, it does not belong here. The palette
caps at parchment on the light end and ink on the dark end. **No pure white, no
pure black.**

- **Ink (#161600):** Olive-black. Deepest contrast. Used as the today digit
  on the sage circle (≈ 7.6:1 contrast — the cream-on-sage alternative reads
  at only 1.8:1, well below WCAG AA, so ink is the legible choice). Body text
  uses system `.primary` so light/dark adapts automatically.
- **Bark (#585142):** Warm brown. Secondary text and dark accents. Drives the
  uppercase month title in the widget.
- **Stone (#938A76):** Warm gray. Mid-tone for dividers, captions, tertiary text.
  Reserved; currently unused in the widget.
- **Sage (#8AAB94):** Muted green. The single chromatic accent. Reserved for the
  today highlight background. Use sparingly, for a single emphasis at a time.
- **Parchment (#EBDAB2):** Warm cream. Reserved for warm cream surfaces; not
  used in the current widget (it failed contrast against sage and was replaced
  by ink for the today digit).

### Light & Dark

Both modes are first-class. The YAML tokens above carry the **light** values.
Dark variants are below; only `bark` actually shifts on a real used surface
today, but all tokens declare both modes for future use:

| Token | Light | Dark | Notes |
|---|---|---|---|
| `ink` | `#161600` | `#EFE8D2` | Inverts toward warm cream; never pure white. |
| `bark` | `#585142` | `#B5AD99` | Warm taupe; legible on dark widget background. |
| `stone` | `#938A76` | `#8E866F` | Slight lift only; mid-gray reads in both modes. |
| `sage` | `#8AAB94` | `#8AAB94` | Unchanged; the single accent reads in both modes. |
| `parchment` | `#EBDAB2` | `#EBDAB2` | Unchanged; today digit on sage works in both. |

Implementation note: brand tokens live in a Swift `Color` extension.
`brandBark` uses `NSColor`'s dynamic-provider API so the same `Color.brandBark`
reference resolves to the warm brown on light and the lifted taupe on dark.
The other tokens are static `Color` literals; their dark hexes above are
documented for future reference (e.g. if `brandInk` ever appears on a dark
surface), not currently wired.

## Typography

System font (SF Pro) only. **Fixed point sizes, no Dynamic Type** — widget text
doesn't fully scale with Dynamic Type, and the compact grid density of a
calendar widget needs predictable measurements. Typography choices are
structural, not decorative:

- **Month title:** 9pt **bold**, uppercase, locale-aware (`APRIL` / `四月` /
  `AVRIL`). Letter-leading aligned with two-digit day numbers in column 1.
- **Weekday header:** 8pt **medium**. One letter per column (`S M T W T F S`,
  reordered by `firstWeekday`). Height pinned to 12pt to match the row rhythm.
- **Day number:** 10pt **medium**. **Weekday vs. weekend differs by color, not
  by weight**, to avoid sub-pixel rendering jitter at small sizes. The same
  weight applies to today's digit; today is signaled by background, not weight.

The container app uses system text styles (`.title` semibold for the app name,
`.callout` for description) — these are intentionally not tokenized because the
container app is just the host for the widget extension and should read as a
plain native macOS view, not as a branded surface.

## Layout

Two months render **side by side** between slim previous/next chevron buttons.
The outer row is: left chevron -> two-month content -> right chevron. The
month content uses an `HStack` with **12pt** between the months. Each month is
a `VStack` of: month title → weekday header row → 6 × 7 day grid.
The grid is one `LazyVGrid` (header and dates share columns) so column widths
are guaranteed identical between the header and the date rows.

**Spacing scale** (the rhythm the widget actually uses):

- `xs` (3pt) — grid row spacing; gap between title and grid; title bottom padding.
- `sm` (6pt) — title leading padding (visually aligns title with two-digit day
  numbers in the first column).
- `md` (16pt) — container-app `VStack` spacing and other non-widget preview gaps.
- `lg` (32pt) — container-app horizontal padding.

Grid math: `firstWeekday` rotates the weekday-header letters and offsets the
leading days; the grid always renders 42 cells (6 rows × 7 cols). Out-of-month
leading and trailing cells render blank but keep their slot for alignment —
matching the system Calendar widget. Outer corner radius and outer padding
belong to WidgetKit's `.containerBackground`; the layout never adds its own.

## Elevation & Depth

**Flat. No shadows, no blurs, no glassmorphism.** Hierarchy is conveyed
exclusively through:

- **Color contrast** — primary vs. secondary text via system semantic colors
  for everything except the brand-asserting elements (month title, today).
- **Tonal grouping** — the today cell sits on a solid sage circle; everything
  else sits on the WidgetKit container background.
- **Whitespace** — the `xs` rhythm gives the grid breathing room without
  introducing visual layers.

If a design temptation reaches for a drop shadow, a frosted-glass overlay, or
an inset border, it is wrong for this widget. Refuse and use whitespace or
color instead.

## Shapes

The shape language is **flat, with one exception**:

- **Today highlight:** full circle (`rounded.full`, 9999px effectively renders
  a circle on the 17×17pt cell). This is the only chromatic, the only round,
  and the only filled shape in the entire widget.
- **Everything else:** rectangular, no border radius. Day cells, weekday header,
  month title — none of them have visible corners or borders.
- **Widget outer corner:** WidgetKit `.containerBackground` default. Do not
  override.

This restraint is intentional: a single round element on a flat grid reads as
a deliberate accent, not as decoration.

## Components

The widget has five atom-level components. Every variant is documented;
nothing else should be invented without revisiting the brand principles.

- **`month-title`** — uppercase month name. Bark on widget background. Bold 9pt.
  Padded `sm` from leading edge so it visually aligns with column-1 digits.
- **`weekday-header` cell** — single weekday letter. 8pt medium. **Weekday
  columns** use system `.primary`; **weekend columns** use system `.secondary`
  (which weekend day is determined by `Calendar.isDateInWeekend`, so locales
  with non-Sat/Sun weekends tint correctly). Height 12pt.
- **`day-cell`** — day number in a 17×17pt cell. 10pt medium. **Weekday days**
  use `.primary`; **weekend days** use `.secondary`. Out-of-month days render
  as `Color.clear` placeholders to preserve grid alignment, and are hidden
  from VoiceOver.
- **`day-cell-today`** — variant of `day-cell`. Background: a `sage` filled
  circle (full radius). Digit: `ink` (≈ 7.6:1 contrast on sage). Same 17×17pt
  size, same 10pt medium weight. Today is signaled by **color and shape**,
  never by font weight or size.
- **`navigation-button`** — left/right SF Symbol chevrons. 16pt wide, no
  background, no border, no fill, system `.secondary` foreground. The buttons
  are functional controls, not decorative accents, so they do not spend the
  widget's single sage emphasis.

The container app (`ContentView`) deliberately has no branded components —
just an SF Symbol calendar icon (48pt, in `bark`) and two system-styled text
labels. It exists only to host the widget extension; it should never grow
into a destination.

## Do's and Don'ts

- **Do** keep sage as a single point of emphasis. There must be exactly one
  sage element on screen at a time.
- **Do** match macOS Calendar widget conventions (uppercase month, S M T W T
  F S header, blank out-of-month cells, 6×7 grid, 3pt row spacing) so the
  widget reads as native first, branded second.
- **Do** follow the user's locale for first-day-of-week, weekend tinting,
  month names, and VoiceOver labels.
- **Do** meet WCAG AA contrast (≥4.5:1 for body text) in both light and dark.

- **Don't** add dot indicators, event chips, color-coded categories, or
  multi-calendar overlays. These belong to productivity-tool maximalism.
- **Don't** use saturated blues, vibrant gradients, neon accents, or any
  color outside the five-token palette. Bright color is the drift signal.
- **Don't** apply skeuomorphism — shadows, frosted glass, inset borders,
  paper textures — to the widget surface. The illustrated app icon is the
  only place skeuomorphic warmth belongs.
- **Don't** introduce a second round shape, a second filled background, or a
  second chromatic accent. The today circle is the entire visual budget for
  emphasis.
- **Don't** differentiate weekdays and weekends by font weight. Color only.
- **Don't** scale widget text with Dynamic Type. Sizes are fixed.
- **Don't** override WidgetKit's outer corner radius or `.containerBackground`
  padding.
