// Bimonth brand palette tokens.
//
// Source of truth for hex values and roles is `DESIGN.md` at the repo root.
// Both targets — the container app (Bimonth) and the widget extension
// (BimonthWidget) — link this file via `project.yml`.
//
// `brandBark` and `brandInk` shift between modes and use NSColor's
// dynamic-provider API so the same `Color.brandX` reference resolves
// correctly per system appearance. Sage and parchment read in both modes;
// stone is reserved for surfaces where the system semantic colors don't
// suffice.

import AppKit
import SwiftUI

extension Color {
    /// Light #161600 (olive-black) / Dark #EFE8D2 (warm cream).
    /// Used as the today digit on the sage circle (light ≈ 7.6:1, AAA).
    /// Dynamic per system appearance so the digit stays legible on both
    /// light and dark widget backgrounds.
    static let brandInk = Color(nsColor: NSColor(name: "brandInk") { appearance in
        let isDark = appearance.bestMatch(from: [
            .darkAqua,
            .vibrantDark,
            .accessibilityHighContrastDarkAqua,
            .accessibilityHighContrastVibrantDark,
        ]) != nil
        return isDark
            ? NSColor(srgbRed: 0xEF / 255.0, green: 0xE8 / 255.0, blue: 0xD2 / 255.0, alpha: 1)
            : NSColor(srgbRed: 0x16 / 255.0, green: 0x16 / 255.0, blue: 0x00 / 255.0, alpha: 1)
    })

    /// Light #585142 (warm brown) / Dark #B5AD99 (lifted taupe).
    /// Drives the widget's uppercase month title and the container app's icon.
    /// Dynamic per system appearance so the brown stays legible on both the
    /// bright and dark widget backgrounds without a separate Asset Catalog.
    static let brandBark = Color(nsColor: NSColor(name: "brandBark") { appearance in
        let isDark = appearance.bestMatch(from: [
            .darkAqua,
            .vibrantDark,
            .accessibilityHighContrastDarkAqua,
            .accessibilityHighContrastVibrantDark,
        ]) != nil
        return isDark
            ? NSColor(srgbRed: 0xB5 / 255.0, green: 0xAD / 255.0, blue: 0x99 / 255.0, alpha: 1)
            : NSColor(srgbRed: 0x58 / 255.0, green: 0x51 / 255.0, blue: 0x42 / 255.0, alpha: 1)
    })

    /// #938A76 — mid-tone, dividers, tertiary text (warm gray). Reserved.
    static let brandStone = Color(red: 0x93 / 255.0, green: 0x8A / 255.0, blue: 0x76 / 255.0)

    /// #8AAB94 — the single chromatic accent (muted green).
    /// Reserved for the today highlight; do not use elsewhere without revisiting
    /// the brand principle of "use sage sparingly, for a single emphasis at a time."
    /// Reads in both modes; no dark variant needed.
    static let brandSage = Color(red: 0x8A / 255.0, green: 0xAB / 255.0, blue: 0x94 / 255.0)

    /// #EBDAB2 — warm surface / background highlight (cream).
    /// Reserved for warm cream surfaces; no dark variant needed.
    static let brandParchment = Color(red: 0xEB / 255.0, green: 0xDA / 255.0, blue: 0xB2 / 255.0)
}
