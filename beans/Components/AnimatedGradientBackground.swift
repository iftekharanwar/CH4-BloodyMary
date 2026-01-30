//
//  AnimatedGradientBackground.swift
//  Beans
//
//  Animated gradient background component
//

import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    let colors: [Color]

    init(colors: [Color] = [BeansColor.background, BeansColor.primary.opacity(0.1), BeansColor.secondary.opacity(0.1)]) {
        self.colors = colors
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

#Preview {
    AnimatedGradientBackground()
}
