import SwiftUI

@main
struct TomorrowApp: App {
    @State private var libraryViewModel = LibraryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(libraryViewModel)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Color Extensions

extension Color {
    // Primary Colors
    static let tomorrowPrimary = Color(hex: "F5A623")
    static let tomorrowSecondary = Color(hex: "C77B30")
    static let tomorrowAccent = Color(hex: "FFCB8E")

    // Background Colors
    static let tomorrowBackground = Color(hex: "1A1614")
    static let tomorrowSurface = Color(hex: "252220")
    static let tomorrowSurfaceElevated = Color(hex: "2E2A27")

    // Text Colors
    static let tomorrowTextPrimary = Color(hex: "FAF7F2")
    static let tomorrowTextSecondary = Color(hex: "A89F94")
    static let tomorrowTextTertiary = Color(hex: "6B6560")

    // Utility Colors
    static let tomorrowDivider = Color(hex: "3A3633")
    static let tomorrowError = Color(hex: "E57373")
    static let tomorrowSuccess = Color(hex: "7BA05B")
    static let tomorrowGlow = Color(hex: "F5A623").opacity(0.2)

    // Initializer from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - ShapeStyle Extensions

extension ShapeStyle where Self == Color {
    static var tomorrowPrimary: Color { Color.tomorrowPrimary }
    static var tomorrowSecondary: Color { Color.tomorrowSecondary }
    static var tomorrowAccent: Color { Color.tomorrowAccent }
    static var tomorrowBackground: Color { Color.tomorrowBackground }
    static var tomorrowSurface: Color { Color.tomorrowSurface }
    static var tomorrowSurfaceElevated: Color { Color.tomorrowSurfaceElevated }
    static var tomorrowTextPrimary: Color { Color.tomorrowTextPrimary }
    static var tomorrowTextSecondary: Color { Color.tomorrowTextSecondary }
    static var tomorrowTextTertiary: Color { Color.tomorrowTextTertiary }
    static var tomorrowDivider: Color { Color.tomorrowDivider }
    static var tomorrowError: Color { Color.tomorrowError }
    static var tomorrowSuccess: Color { Color.tomorrowSuccess }
    static var tomorrowGlow: Color { Color.tomorrowGlow }
}

// MARK: - Font Extensions

extension Font {
    static let heading1 = Font.system(size: 28, weight: .bold)
    static let heading2 = Font.system(size: 22, weight: .semibold)
    static let heading3 = Font.system(size: 18, weight: .semibold)
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 13, weight: .regular)
    static let mono = Font.system(size: 14, weight: .regular, design: .monospaced)
}
