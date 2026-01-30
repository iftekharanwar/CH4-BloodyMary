//
//  ConfettiView.swift
//  Beans
//
//  Confetti particle effect for success moments
//

import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let duration: Double = 3.0

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .rotationEffect(.degrees(particle.rotation))
            }
        }
        .onAppear {
            generateParticles()
        }
    }

    private func generateParticles() {
        let colors = [
            BeansColor.primary,
            BeansColor.secondary,
            BeansColor.accent,
            BeansColor.success,
            Color.pink,
            Color.purple
        ]

        for i in 0..<50 {
            let particle = ConfettiParticle(
                id: UUID(),
                x: CGFloat.random(in: -150...150),
                y: -200,
                size: CGFloat.random(in: 6...12),
                color: colors.randomElement() ?? BeansColor.primary,
                opacity: 1.0,
                rotation: Double.random(in: 0...360)
            )

            particles.append(particle)

            // Animate each particle
            withAnimation(
                .easeOut(duration: duration)
                .delay(Double(i) * 0.01)
            ) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].y = CGFloat.random(in: 400...600)
                    particles[index].x += CGFloat.random(in: -100...100)
                    particles[index].opacity = 0
                    particles[index].rotation += Double.random(in: 360...720)
                }
            }
        }

        // Clean up particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            particles.removeAll()
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
    var rotation: Double
}

struct ConfettiModifier: ViewModifier {
    @Binding var isActive: Bool

    func body(content: Content) -> some View {
        ZStack {
            content

            if isActive {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
    }
}

extension View {
    func confetti(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isActive: isActive))
    }
}

#Preview {
    ZStack {
        BeansColor.background
            .ignoresSafeArea()

        ConfettiView()
    }
}
