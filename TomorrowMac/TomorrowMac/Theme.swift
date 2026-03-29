import SwiftUI

// MARK: - Theme: Horizon / Forward-Looking Aesthetic
enum Theme {
    // MARK: - Colors
    static let horizonBlue = Color(hex: "3B82F6")
    static let sunsetOrange = Color(hex: "F97316")
    static let twilight = Color(hex: "4C1D95")
    static let surface = Color(hex: "F8FAFC")
    static let cardBg = Color(hex: "FFFFFF")
    static let textPrimary = Color(hex: "1E293B")
    static let textSecondary = Color(hex: "64748B")
    static let textMuted = Color(hex: "94A3B8")
    static let divider = Color(hex: "E2E8F0")
    static let success = Color(hex: "10B981")
    static let declined = Color(hex: "EF4444")
    static let glowAmber = Color(hex: "F59E0B")

    // MARK: - Gradients
    static let sunriseGradient = LinearGradient(
        colors: [horizonBlue, sunsetOrange],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let horizonGradient = LinearGradient(
        colors: [horizonBlue.opacity(0.8), sunsetOrange.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [Color.white, Color(hex: "F1F5F9")],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Spacing
    static let spacing_xs: CGFloat = 4
    static let spacing_sm: CGFloat = 8
    static let spacing_md: CGFloat = 16
    static let spacing_lg: CGFloat = 24
    static let spacing_xl: CGFloat = 32

    // MARK: - Corner Radius
    static let radius_sm: CGFloat = 8
    static let radius_md: CGFloat = 12
    static let radius_lg: CGFloat = 16
    static let radius_xl: CGFloat = 20

    // MARK: - Shadows
    static func cardShadow() -> some View {
        Color.black.opacity(0.08)
    }

    // MARK: - Animation
    static let springAnimation = Animation.spring(response: 0.35, dampingFraction: 0.75)
    static let easeOut = Animation.easeOut(duration: 0.25)
}

// MARK: - Color Extension
extension Color {
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
            (a, r, g, b) = (1, 1, 1, 0)
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
