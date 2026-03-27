import SwiftUI

// MARK: - Theme.swift
// iOS 26 Liquid Glass Design System
// Centralized design tokens for the Tomorrow app

enum Theme {

    // MARK: - Corner Radius Tokens

    enum CornerRadius {
        /// 4pt - smallest spacing elements
        static let xs: CGFloat = 4
        /// 8pt - input fields, small cards
        static let sm: CGFloat = 8
        /// 12pt - cards, buttons, list items
        static let md: CGFloat = 12
        /// 16pt - large cards, sheets, modals
        static let lg: CGFloat = 16
        /// 24pt - featured cards, hero elements
        static let xl: CGFloat = 24
        /// Fully rounded - pills, avatars
        static let full: CGFloat = 9999
    }

    // MARK: - Spacing Tokens (8pt grid)

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Font Size Tokens (min 11pt for iOS 26)

    enum FontSize {
        /// 11pt - minimum size for iOS 26 accessibility
        static let caption2: CGFloat = 11
        /// 13pt - captions, timestamps
        static let caption: CGFloat = 13
        /// 15pt - secondary body text
        static let bodySmall: CGFloat = 15
        /// 17pt - primary body text
        static let body: CGFloat = 17
        /// 18pt - headings
        static let heading3: CGFloat = 18
        /// 22pt - section headings
        static let heading2: CGFloat = 22
        /// 28pt - page titles
        static let heading1: CGFloat = 28
        /// 34pt - display text
        static let display: CGFloat = 34
    }

    // MARK: - Animation Tokens

    enum Animation {
        static let quick: Double = 0.1
        static let standard: Double = 0.25
        static let slow: Double = 0.35
        static let sheet: Double = 0.4
    }

    // MARK: - Shadow

    enum Shadow {
        static let card = Color.black.opacity(0.15)
        static let elevated = Color.black.opacity(0.25)
        static let glow = Color.tomorrowPrimary.opacity(0.3)
    }
}

// MARK: - Font Extensions

extension Font {
    static let display = Font.system(size: Theme.FontSize.display, weight: .bold)
    static let heading1 = Font.system(size: Theme.FontSize.heading1, weight: .bold)
    static let heading2 = Font.system(size: Theme.FontSize.heading2, weight: .semibold)
    static let heading3 = Font.system(size: Theme.FontSize.heading3, weight: .semibold)
    static let bodyLarge = Font.system(size: Theme.FontSize.body, weight: .regular)
    static let bodyMedium = Font.system(size: Theme.FontSize.bodySmall, weight: .regular)
    static let caption = Font.system(size: Theme.FontSize.caption, weight: .regular)
    static let caption2 = Font.system(size: Theme.FontSize.caption2, weight: .regular)
    static let mono = Font.system(size: 14, weight: .regular, design: .monospaced)
}

// MARK: - RoundedRectangle Helpers

extension RoundedRectangle {
    /// Creates a rounded rectangle with Theme corner radius tokens
    static func card() -> some Shape {
        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
    }

    static func sheet() -> some Shape {
        RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
    }

    static func input() -> some Shape {
        RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
    }

    static func chip() -> some Shape {
        RoundedRectangle(cornerRadius: Theme.CornerRadius.full)
    }

    static func button() -> some Shape {
        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
    }

    static func timeline() -> some Shape {
        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
    }
}
