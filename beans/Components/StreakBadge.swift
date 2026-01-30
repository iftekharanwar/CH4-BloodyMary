//
//  StreakBadge.swift
//  Beans
//
//  Streak display component
//

import SwiftUI

struct StreakBadge: View {
    let streak: Int
    let size: Size
    @State private var isPulsing = false

    enum Size {
        case small, medium, large

        var fontSize: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 32
            case .large: return 48
            }
        }

        var numberFont: Font {
            switch self {
            case .small: return BeansFont.headline
            case .medium: return BeansFont.title2
            case .large: return BeansFont.largeTitle
            }
        }
    }

    init(streak: Int, size: Size = .medium) {
        self.streak = streak
        self.size = size
    }

    var body: some View {
        HStack(spacing: size == .small ? 4 : 8) {
            Text("🔥")
                .font(.system(size: size.fontSize))
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5).repeatCount(3, autoreverses: true), value: isPulsing)

            Text("\(streak)")
                .font(size.numberFont)
                .foregroundStyle(BeansColor.textPrimary)
        }
        .onAppear {
            if streak > 0 {
                isPulsing = true
            }
        }
    }
}

#Preview {
    VStack(spacing: BeansSpacing.lg) {
        StreakBadge(streak: 7, size: .small)
        StreakBadge(streak: 7, size: .medium)
        StreakBadge(streak: 7, size: .large)
    }
    .padding()
}
