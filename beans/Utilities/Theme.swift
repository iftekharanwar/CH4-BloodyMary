//
//  Theme.swift
//  Beans
//

import SwiftUI

// MARK: - Colors
enum BeansColor {
    // Palette pulled from the illustration art style
    static let primary      = Color(red: 0.482, green: 0.651, blue: 0.545)   // #7BA78B — dusty sage
    static let secondary    = Color(red: 0.831, green: 0.471, blue: 0.353)   // #D4785A — warm terracotta
    static let accent       = Color(red: 0.906, green: 0.722, blue: 0.427)   // #E8B86D — soft gold
    static let background   = Color(red: 0.969, green: 0.949, blue: 0.933)   // #F7F3EE — warm cream
    static let textPrimary  = Color(red: 0.239, green: 0.180, blue: 0.165)   // #3D2E2A — warm dark brown
    static let textSecondary = Color(red: 0.588, green: 0.529, blue: 0.502)  // #96877E — warm gray

    // Semantic
    static let cardBackground = Color(red: 1.0, green: 0.992, blue: 0.976)   // #FFFDF9 — warm white

    // Soft background gradients
    static let gradientSoft = [background, primary.opacity(0.06)]
}

// MARK: - Fonts
enum BeansFont {
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title      = Font.system(.title,      design: .rounded, weight: .semibold)
    static let title2     = Font.system(.title2,     design: .rounded, weight: .semibold)
    static let title3     = Font.system(.title3,     design: .rounded, weight: .medium)
    static let headline   = Font.system(.headline,   design: .rounded, weight: .semibold)
    static let body       = Font.system(.body,       design: .rounded)
    static let callout    = Font.system(.callout,    design: .rounded)
    static let caption    = Font.system(.caption,    design: .rounded)
    static let caption2   = Font.system(.caption2,   design: .rounded)
}

// MARK: - Spacing
enum BeansSpacing {
    static let xs:  CGFloat = 6
    static let sm:  CGFloat = 12
    static let md:  CGFloat = 20
    static let lg:  CGFloat = 28
    static let xl:  CGFloat = 40
    static let xxl: CGFloat = 56
}

// MARK: - Corner Radius
enum BeansRadius {
    static let sm:  CGFloat = 10
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 20
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Shadows
enum BeansShadow {
    static let card   = Color(red: 0.239, green: 0.180, blue: 0.165).opacity(0.08)
    static let button = Color(red: 0.239, green: 0.180, blue: 0.165).opacity(0.15)
    static let lifted = Color(red: 0.239, green: 0.180, blue: 0.165).opacity(0.12)
}
