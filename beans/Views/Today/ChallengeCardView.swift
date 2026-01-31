//
//  ChallengeCardView.swift
//  Beans
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
    let onAccept: () -> Void
    let onSkip: () -> Void

    @State private var revealed = false
    @State private var bowlBurst = false
    @State private var shakeOffset: CGFloat = 0
    @State private var breathe = false

    var body: some View {
        ZStack {
            if !revealed {
                bowlView
            } else {
                challengeRevealView
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: revealed)
    }

    // MARK: - Bowl (pre-reveal)

    private var bowlView: some View {
        VStack(spacing: BeansSpacing.lg) {
            Spacer()

            Text("Ready for a challenge?")
                .font(BeansFont.title2)
                .foregroundStyle(BeansColor.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeansSpacing.lg)

            Spacer(minLength: BeansSpacing.md)

            // Bowl illustration
            Image("bowl")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
                .scaleEffect(bowlBurst ? 1.5 : (breathe ? 1.03 : 1.0))
                .opacity(bowlBurst ? 0.0 : 1.0)
                .rotationEffect(.degrees(shakeOffset))
                .animation(.spring(response: 0.35, dampingFraction: 0.5), value: bowlBurst)
                .animation(.easeInOut(duration: 0.1), value: shakeOffset)
                .animation(
                    .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                    value: breathe
                )
                .onAppear {
                    breathe = true
                }

            Spacer(minLength: BeansSpacing.md)

            // Shake button
            Button {
                HapticFeedback.success()

                // Shake wiggle sequence: left → right → left → right → center
                withAnimation(.easeInOut(duration: 0.08)) { shakeOffset = -10 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.easeInOut(duration: 0.08)) { shakeOffset = 10 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    withAnimation(.easeInOut(duration: 0.08)) { shakeOffset = -7 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                    withAnimation(.easeInOut(duration: 0.08)) { shakeOffset = 5 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                    withAnimation(.easeInOut(duration: 0.08)) { shakeOffset = 0 }
                }

                // Burst after wiggle settles
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                        bowlBurst = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        revealed = true
                    }
                }
            } label: {
                Text("Shake it")
                    .font(BeansFont.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(BeansColor.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
                    .shadow(color: BeansShadow.button, radius: 8, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, BeansSpacing.lg)

            Spacer()
        }
    }

    // MARK: - Challenge reveal (post-burst)

    private var challengeRevealView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Illustration at the top with spring scale-in
            if let name = challenge.illustration {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .scaleEffect(revealed ? 1.0 : 0.4)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: revealed)
            }

            Spacer(minLength: BeansSpacing.md)

            // Title
            Text(challenge.title)
                .font(BeansFont.title)
                .foregroundStyle(BeansColor.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeansSpacing.lg)

            // Description
            Text(challenge.challengeDescription)
                .font(BeansFont.callout)
                .foregroundStyle(BeansColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, BeansSpacing.xl)
                .padding(.top, BeansSpacing.xs)

            // Badges
            HStack(spacing: BeansSpacing.xs) {
                Badge(text: challenge.difficulty.displayName, systemIcon: challenge.difficulty.icon, color: difficultyColor)
                Badge(text: challenge.estimatedTime, systemIcon: "clock", color: BeansColor.secondary.opacity(0.85))
            }
            .padding(.top, BeansSpacing.md)

            Spacer()

            // CTA buttons
            VStack(spacing: BeansSpacing.xs) {
                Button {
                    onAccept()
                } label: {
                    Text("I'll try this")
                        .font(BeansFont.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(BeansColor.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
                        .shadow(color: BeansShadow.button, radius: 8, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())

                Button {
                    // Reset back to bowl with a new challenge
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        revealed = false
                        bowlBurst = false
                        shakeOffset = 0
                        breathe = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        onSkip()
                        breathe = true
                    }
                } label: {
                    Text("Skip, show another")
                        .font(BeansFont.caption)
                        .foregroundStyle(BeansColor.textSecondary)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            .padding(.horizontal, BeansSpacing.lg)
            .padding(.bottom, BeansSpacing.xl)
        }
    }

    // MARK: - Helpers

    private var difficultyColor: Color {
        switch challenge.difficulty {
        case .easy:   return BeansColor.primary.opacity(0.85)
        case .medium: return BeansColor.accent.opacity(0.9)
        case .hard:   return BeansColor.secondary.opacity(0.9)
        }
    }
}

struct Badge: View {
    let text: String
    let systemIcon: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemIcon).font(.system(size: 11, weight: .medium))
            Text(text).font(BeansFont.caption)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    let sample = Challenge(
        title: "Board Game Trap",
        description: "Sit in a public place with a multiplayer board game set up. Don't invite anyone. Just wait.",
        difficulty: .easy,
        estimatedTime: "10-30 min",
        emoji: "🎲",
        illustration: "challenge-boardgame",
        category: "Passive Invitation"
    )
    ZStack {
        BeansColor.background.ignoresSafeArea()
        ChallengeCardView(challenge: sample, onAccept: {}, onSkip: {})
    }
}
