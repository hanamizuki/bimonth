// Bimonth brand palette tokens.
//
// Source of truth for hex values and roles is `.impeccable.md` at the repo
// root. Both targets — the container app (Bimonth) and the widget extension
// (BimonthWidget) — link this file via `project.yml`.
//
// NOTE: only light-mode values are defined here. Dark-mode variants are not
// yet decided; in dark mode `brandInk` / `brandBark` will read poorly. The
// follow-up is to migrate this file to Asset Catalog Color Sets with explicit
// light/dark pairs once the dark palette is finalized.

import SwiftUI

extension Color {
    /// #161600 — primary text, deepest contrast (olive-black).
    static let brandInk = Color(red: 0x16 / 255.0, green: 0x16 / 255.0, blue: 0x00 / 255.0)

    /// #585142 — secondary text/surface, dark accent (warm brown).
    /// Currently used for the widget's month title and the container app's icon.
    static let brandBark = Color(red: 0x58 / 255.0, green: 0x51 / 255.0, blue: 0x42 / 255.0)

    /// #938A76 — mid-tone, dividers, tertiary text (warm gray).
    static let brandStone = Color(red: 0x93 / 255.0, green: 0x8A / 255.0, blue: 0x76 / 255.0)

    /// #8AAB94 — the single chromatic accent (muted green).
    /// Reserved for the today highlight; do not use elsewhere without revisiting
    /// the brand principle of "use sage sparingly, for a single emphasis at a time."
    static let brandSage = Color(red: 0x8A / 255.0, green: 0xAB / 255.0, blue: 0x94 / 255.0)

    /// #EBDAB2 — warm surface / background highlight (cream).
    /// Currently used as the digit color on the today highlight (cream on sage).
    static let brandParchment = Color(red: 0xEB / 255.0, green: 0xDA / 255.0, blue: 0xB2 / 255.0)
}
