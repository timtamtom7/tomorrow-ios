import SwiftUI
import UIKit

// MARK: - HapticsManager
// iOS 26 Liquid Glass haptic feedback for interactive elements

/// Haptic feedback intensity levels
enum HapticStyle {
    case light
    case medium
    case heavy
    case selection
}

@MainActor
final class HapticsManager: ObservableObject {
    static let shared = HapticsManager()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        prepareAll()
    }

    private func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    // MARK: - Impact

    /// Light impact - subtle UI interactions (toggles, small buttons)
    func light() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }

    /// Medium impact - primary button presses, card interactions
    func medium() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    /// Heavy impact - major actions, destructive buttons, important moments
    func heavy() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }

    // MARK: - Selection

    /// Selection change - tab switching, picker changes
    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    // MARK: - Notification

    /// Success - action completed, letter delivered
    func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    /// Warning - caution states
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    /// Error - failed actions, validation errors
    func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }

    // MARK: - Contextual

    /// Button tap feedback
    func buttonTap() {
        light()
    }

    /// Toggle change feedback
    func toggle() {
        light()
    }

    /// Card tap feedback
    func cardTap() {
        medium()
    }

    /// Save/action success
    func saveSuccess() {
        success()
    }

    /// Delete/destructive action
    func deleteAction() {
        heavy()
    }

    /// Tab selection change
    func tabChange() {
        selection()
    }

    /// Recording start/stop
    func recording() {
        medium()
    }
}

// MARK: - View Modifier for Haptic Buttons

struct HapticButton<Label: View>: View {
    let style: HapticStyle
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: {
            triggerHaptic()
            action()
        }, label: label)
    }

    private func triggerHaptic() {
        let manager = HapticsManager.shared
        switch style {
        case .light: manager.light()
        case .medium: manager.medium()
        case .heavy: manager.heavy()
        case .selection: manager.selection()
        }
    }
}

// MARK: - Convenience View Extensions

extension View {
    /// Adds haptic feedback on tap
    func hapticOnTap(_ style: HapticStyle = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { HapticsManager.shared.medium() }
        )
    }
}
