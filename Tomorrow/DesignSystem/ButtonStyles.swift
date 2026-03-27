import SwiftUI

// MARK: - TomorrowButtonStyle
// iOS 26 Liquid Glass button styles

/// Primary action button - amber filled
struct TomorrowPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyMedium)
            .fontWeight(.semibold)
            .foregroundStyle(Color.tomorrowBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(isEnabled ? Color.tomorrowPrimary : Color.tomorrowTextTertiary)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: Theme.Animation.quick), value: configuration.isPressed)
    }
}

/// Secondary action button - outlined
struct TomorrowSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyMedium)
            .fontWeight(.medium)
            .foregroundStyle(isEnabled ? Color.tomorrowPrimary : Color.tomorrowTextTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(isEnabled ? Color.tomorrowPrimary : Color.tomorrowTextTertiary, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: Theme.Animation.quick), value: configuration.isPressed)
    }
}

/// Ghost/text button - no background
struct TomorrowGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyMedium)
            .foregroundStyle(Color.tomorrowPrimary)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeOut(duration: Theme.Animation.quick), value: configuration.isPressed)
    }
}

/// Destructive button - red filled
struct TomorrowDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyMedium)
            .fontWeight(.semibold)
            .foregroundStyle(Color.tomorrowBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(isEnabled ? Color.tomorrowError : Color.tomorrowTextTertiary)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: Theme.Animation.quick), value: configuration.isPressed)
    }
}

/// Icon button style
struct TomorrowIconButtonStyle: ButtonStyle {
    let size: CGFloat

    init(size: CGFloat = 44) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.tomorrowPrimary)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(Color.tomorrowSurface)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: Theme.Animation.quick), value: configuration.isPressed)
    }
}

// MARK: - ButtonStyle Extensions

extension ButtonStyle where Self == TomorrowPrimaryButtonStyle {
    static var tomorrowPrimary: TomorrowPrimaryButtonStyle {
        TomorrowPrimaryButtonStyle()
    }
}

extension ButtonStyle where Self == TomorrowSecondaryButtonStyle {
    static var tomorrowSecondary: TomorrowSecondaryButtonStyle {
        TomorrowSecondaryButtonStyle()
    }
}

extension ButtonStyle where Self == TomorrowGhostButtonStyle {
    static var tomorrowGhost: TomorrowGhostButtonStyle {
        TomorrowGhostButtonStyle()
    }
}

extension ButtonStyle where Self == TomorrowDestructiveButtonStyle {
    static var tomorrowDestructive: TomorrowDestructiveButtonStyle {
        TomorrowDestructiveButtonStyle()
    }
}

// MARK: - View Modifier for Automatic Haptics

struct HapticButtonStyle: ButtonStyle {
    let hapticStyle: HapticStyle

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    Task { @MainActor in
                        switch hapticStyle {
                        case .light: HapticsManager.shared.light()
                        case .medium: HapticsManager.shared.medium()
                        case .heavy: HapticsManager.shared.heavy()
                        case .selection: HapticsManager.shared.selection()
                        }
                    }
                }
            }
    }
}

extension ButtonStyle where Self == HapticButtonStyle {
    static func haptic(_ style: HapticStyle = .medium) -> HapticButtonStyle {
        HapticButtonStyle(hapticStyle: style)
    }
}
