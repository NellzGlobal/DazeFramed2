//
//  theme.swift
//  Dashboard
//
//  Created by Dornell Mister on 4/6/26.
//

import SwiftUI

// MARK: - Color Theme Presets

struct ColorTheme: Identifiable {
    let id: String
    let name: String
    let background: Color
    let surface: Color
    let surfaceAlt: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let accentLight: Color
    let divider: Color
    let success: Color
    let danger: Color
    let isDark: Bool

    static func preset(id: String) -> ColorTheme {
        all.first { $0.id == id } ?? goldCream
    }

    static let all: [ColorTheme] = [goldCream, midnight, forest, ocean, ember, violet]

    static let goldCream = ColorTheme(
        id: "goldCream", name: "Gold & Cream",
        background:  Color(hex: "#F7F5F0"),
        surface:     Color(hex: "#FFFFFF"),
        surfaceAlt:  Color(hex: "#F0EDE6"),
        primary:     Color(hex: "#1C1C1E"),
        secondary:   Color(hex: "#6B6463"),
        accent:      Color(hex: "#C8A96E"),
        accentLight: Color(hex: "#F0E6CB"),
        divider:     Color(hex: "#E0DDD5"),
        success:     Color(hex: "#5C8B6E"),
        danger:      Color(hex: "#C0504D"),
        isDark: false
    )

    static let midnight = ColorTheme(
        id: "midnight", name: "Midnight",
        background:  Color(hex: "#0A0A12"),
        surface:     Color(hex: "#12121E"),
        surfaceAlt:  Color(hex: "#1A1A2E"),
        primary:     Color(hex: "#EEF0FF"),
        secondary:   Color(hex: "#8888AA"),
        accent:      Color(hex: "#4D9FFF"),
        accentLight: Color(hex: "#0E1E3A"),
        divider:     Color(hex: "#252540"),
        success:     Color(hex: "#34D399"),
        danger:      Color(hex: "#FF6B6B"),
        isDark: true
    )

    static let forest = ColorTheme(
        id: "forest", name: "Forest",
        background:  Color(hex: "#F2EFE4"),
        surface:     Color(hex: "#FAFAF5"),
        surfaceAlt:  Color(hex: "#E4E8DC"),
        primary:     Color(hex: "#1A2B1A"),
        secondary:   Color(hex: "#4A6650"),
        accent:      Color(hex: "#5C8B6E"),
        accentLight: Color(hex: "#D0E8D4"),
        divider:     Color(hex: "#CCCBB8"),
        success:     Color(hex: "#5C8B6E"),
        danger:      Color(hex: "#C0504D"),
        isDark: false
    )

    static let ocean = ColorTheme(
        id: "ocean", name: "Ocean",
        background:  Color(hex: "#071520"),
        surface:     Color(hex: "#0D2030"),
        surfaceAlt:  Color(hex: "#122840"),
        primary:     Color(hex: "#E0F0FF"),
        secondary:   Color(hex: "#6A90AA"),
        accent:      Color(hex: "#38BDF8"),
        accentLight: Color(hex: "#093050"),
        divider:     Color(hex: "#1A3050"),
        success:     Color(hex: "#34D399"),
        danger:      Color(hex: "#F87171"),
        isDark: true
    )

    static let ember = ColorTheme(
        id: "ember", name: "Ember",
        background:  Color(hex: "#1C1208"),
        surface:     Color(hex: "#261A0C"),
        surfaceAlt:  Color(hex: "#302210"),
        primary:     Color(hex: "#FFF8E8"),
        secondary:   Color(hex: "#B09060"),
        accent:      Color(hex: "#F59E0B"),
        accentLight: Color(hex: "#3C2808"),
        divider:     Color(hex: "#3C2C16"),
        success:     Color(hex: "#6EBF8B"),
        danger:      Color(hex: "#EF4444"),
        isDark: true
    )

    static let violet = ColorTheme(
        id: "violet", name: "Violet",
        background:  Color(hex: "#100820"),
        surface:     Color(hex: "#180E2E"),
        surfaceAlt:  Color(hex: "#201438"),
        primary:     Color(hex: "#EEE8FF"),
        secondary:   Color(hex: "#9080B8"),
        accent:      Color(hex: "#A78BFA"),
        accentLight: Color(hex: "#28165A"),
        divider:     Color(hex: "#2A1E48"),
        success:     Color(hex: "#4ADE80"),
        danger:      Color(hex: "#F87171"),
        isDark: true
    )
}

// MARK: - GDTheme

struct GDTheme {
    // Mutable statics — updated by GDTheme.apply(_:) when the user changes theme.
    // All views read these at render time, so they pick up new values automatically
    // whenever GoalDiggerStore fires objectWillChange after a theme change.
    static var background   = Color(hex: "#F7F5F0")
    static var surface      = Color(hex: "#FFFFFF")
    static var surfaceAlt   = Color(hex: "#F0EDE6")
    static var primary      = Color(hex: "#1C1C1E")
    static var secondary    = Color(hex: "#6B6463")
    static var gold         = Color(hex: "#C8A96E")
    static var goldLight    = Color(hex: "#F0E6CB")
    static var divider      = Color(hex: "#E0DDD5")
    static var success      = Color(hex: "#5C8B6E")
    static var danger       = Color(hex: "#C0504D")

    static func apply(_ theme: ColorTheme) {
        background = theme.background
        surface    = theme.surface
        surfaceAlt = theme.surfaceAlt
        primary    = theme.primary
        secondary  = theme.secondary
        gold       = theme.accent
        goldLight  = theme.accentLight
        divider    = theme.divider
        success    = theme.success
        danger     = theme.danger
    }

    // MARK: Typography
    static func titleFont(_ size: CGFloat = 28) -> Font {
        .custom("Georgia", size: size).weight(.regular)
    }
    static func serifFont(_ size: CGFloat = 16) -> Font {
        .custom("Georgia", size: size)
    }
    static func sansFont(_ size: CGFloat = 14, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func monoFont(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}

// MARK: - Color Hex Init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8)*17, (int >> 4 & 0xF)*17, (int & 0xF)*17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r)/255,
                  green: Double(g)/255,
                  blue: Double(b)/255,
                  opacity: Double(a)/255)
    }
}

// MARK: - Reusable Components

struct GoldDivider: View {
    var body: some View {
        Rectangle()
            .fill(GDTheme.gold)
            .frame(height: 1)
    }
}

struct SectionLabel: View {
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Rectangle().fill(GDTheme.gold).frame(width: 3, height: 14)
            Text(text.uppercased())
                .font(GDTheme.sansFont(10, weight: .semibold))
                .tracking(2.5)
                .foregroundColor(GDTheme.secondary)
            Spacer()
        }
    }
}

struct GDCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .background(GDTheme.surface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Theme Swatch (used in ThemePickerContent)

struct ThemeSwatchView: View {
    let theme: ColorTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Mini color preview
                ZStack {
                    theme.background
                    VStack(alignment: .leading, spacing: 5) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(theme.surface)
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(theme.accent)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(theme.secondary.opacity(0.35))
                            .frame(height: 4)
                    }
                    .padding(10)
                }
                .frame(height: 64)

                // Name bar
                theme.surfaceAlt
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .overlay(
                        Text(theme.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.primary)
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? theme.accent : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
