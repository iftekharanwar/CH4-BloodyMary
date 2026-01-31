//
//  ChallengeCardView.swift
//  Beans
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
    let onAccept: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: BeansSpacing.lg) {

            // Challenge card — image + description unified
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                ZStack(alignment: .bottom) {
                    Group {
                        if let name = challenge.illustration {
                            Image(name)
                                .resizable()
                                .scaledToFill()
                        } else {
                            BeansColor.primary.opacity(0.15)
                                .overlay {
                                    Text(challenge.emoji)
                                        .font(.system(size: 72))
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()

                    // Bottom scrim
                    LinearGradient(
                        colors: [Color.black.opacity(0), Color.black.opacity(0.45)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)

                    // Badges overlay at the bottom of the image
                    HStack(spacing: BeansSpacing.xs) {
                        Badge(text: challenge.difficulty.displayName, systemIcon: challenge.difficulty.icon, color: difficultyColor)
                        Badge(text: challenge.estimatedTime, systemIcon: "clock", color: BeansColor.secondary.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, BeansSpacing.md)
                    .padding(.bottom, BeansSpacing.sm)
                }

                // Title + description on warm white, below the image
                VStack(alignment: .leading, spacing: BeansSpacing.xs) {
                    Text(challenge.title)
                        .font(BeansFont.title2)
                        .foregroundStyle(BeansColor.textPrimary)

                    Text(challenge.challengeDescription)
                        .font(BeansFont.callout)
                        .foregroundStyle(BeansColor.textSecondary)
                        .lineSpacing(3)
                }
                .padding(BeansSpacing.md)
                .background(BeansColor.cardBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: BeansRadius.xl))
            .shadow(color: BeansShadow.lifted, radius: 14, y: 8)

            // CTA
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
                    onSkip()
                } label: {
                    Text("Skip today")
                        .font(BeansFont.caption)
                        .foregroundStyle(BeansColor.textSecondary)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, BeansSpacing.lg)
    }

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
