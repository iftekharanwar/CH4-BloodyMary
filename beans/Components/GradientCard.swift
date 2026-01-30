//
//  GradientCard.swift
//  Beans
//
//  Reusable card component with gradient background
//

import SwiftUI

struct GradientCard<Content: View>: View {
    let colors: [Color]
    let content: Content

    init(colors: [Color], @ViewBuilder content: () -> Content) {
        self.colors = colors
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            content
        }
        .clipShape(RoundedRectangle(cornerRadius: BeansRadius.xl))
        .shadow(color: BeansShadow.card, radius: 10, x: 0, y: 5)
    }
}

#Preview {
    GradientCard(colors: [BeansColor.primary, BeansColor.secondary]) {
        VStack(spacing: BeansSpacing.md) {
            Text("🎲")
                .font(.system(size: 64))

            Text("Sample Challenge")
                .font(BeansFont.title2)
                .foregroundStyle(.white)
        }
        .padding(BeansSpacing.lg)
    }
    .padding()
}
