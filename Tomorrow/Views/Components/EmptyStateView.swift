import SwiftUI

// MARK: - EmptyStateView

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                Color.tomorrowTextTertiary

            Text(title)
                .font(.heading2)
                Color.tomorrowTextPrimary

            Text(message)
                .font(.body)
                Color.tomorrowTextSecondary
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.body)
                        .fontWeight(.semibold)
                        Color.tomorrowBackground
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.tomorrowPrimary)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - GlowButton

struct GlowButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.body)
            .fontWeight(.semibold)
            Color.tomorrowBackground
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    Color.tomorrowPrimary

                    if !isPressed {
                        Color.tomorrowPrimary
                            .blur(radius: 8)
                            .opacity(0.5)
                    }
                }
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - PulsingGlow

struct PulsingGlow: View {
    @State private var isAnimating = false

    let color: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: isAnimating ? size / 2 : size / 4)
            .opacity(isAnimating ? 0.6 : 0.3)
            .animation(
                .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - LoadingView

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            PulsingGlow(color: .tomorrowPrimary, size: 60)

            Text("Loading...")
                .font(.body)
                Color.tomorrowTextSecondary
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.tomorrowBackground)
    }
}

// MARK: - SectionHeader

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)?
    var actionTitle: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.heading2)
                Color.tomorrowTextPrimary

            Spacer()

            if let action, let actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.body)
                        Color.tomorrowPrimary
                }
            }
        }
    }
}

#Preview("EmptyState") {
    ZStack {
        Color.tomorrowBackground.ignoresSafeArea()

        EmptyStateView(
            icon: "doc.text",
            title: "No Letters Yet",
            message: "Write your first letter to the future.",
            actionTitle: "Start Writing"
        ) {
            print("Action tapped")
        }
    }
}

#Preview("GlowButton") {
    ZStack {
        Color.tomorrowBackground.ignoresSafeArea()

        GlowButton(title: "Create Letter", icon: "plus") {
            print("Tapped")
        }
    }
}

#Preview("Loading") {
    LoadingView()
}
