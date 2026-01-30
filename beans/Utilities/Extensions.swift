//
//  Extensions.swift
//  Beans
//
//  SwiftUI extensions and utilities
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "6B9BD1" or "#6B9BD1")
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions
extension View {
    /// Apply standard card styling
    func cardStyle() -> some View {
        self
            .background(BeansColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: BeansRadius.xl))
            .shadow(color: BeansShadow.card, radius: 10, x: 0, y: 4)
    }

    /// Apply primary button styling
    func primaryButton(isEnabled: Bool = true) -> some View {
        self
            .font(BeansFont.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BeansSpacing.sm)
            .background(isEnabled ? BeansColor.primary : BeansColor.textSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
            .shadow(color: isEnabled ? BeansShadow.button : .clear, radius: 8, x: 0, y: 4)
    }

    /// Apply secondary button styling
    func secondaryButton() -> some View {
        self
            .font(BeansFont.callout)
            .foregroundStyle(BeansColor.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BeansSpacing.sm)
            .background(BeansColor.background)
            .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
    }

    /// Add scale animation on tap
    func scaleOnTap() -> some View {
        self.buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - String Extensions
extension String {
    /// Limit string to specified character count
    func limited(to count: Int) -> String {
        if self.count <= count {
            return self
        }
        return String(self.prefix(count))
    }
}

// MARK: - Date Extensions
extension Date {
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Get start of day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
