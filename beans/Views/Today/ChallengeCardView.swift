//
//  ChallengeCardView.swift
//  Beans
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
    let onAccept: () -> Void
    let onSkip: () -> Void

    @State private var bobOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: BeansSpacing.lg) {

            // Hero card
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
                                    .font(.system(size: 80))
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .padding(-10)
                .offset(y: bobOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                        bobOffset = -5
                    }
                }
                .clipped()

                // Bottom scrim
                LinearGradient(
                    colors: [Color.black.opacity(0), Color.black.opacity(0.5)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(maxWidth: .infinity)
                .frame(height: 280)

                // Title + badges overlay
                VStack(alignment: .leading, spacing: BeansSpacing.xs) {
                    HStack(spacing: BeansSpacing.xs) {
                        Badge(text: challenge.difficulty.displayName, systemIcon: challenge.difficulty.icon, color: difficultyColor)
                        Badge(text: challenge.estimatedTime, systemIcon: "clock", color: BeansColor.secondary.opacity(0.85))
                    }

                    Text(challenge.title)
                        .font(BeansFont.title)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(BeansSpacing.md)
            }
            .clipShape(RoundedRectangle(cornerRadius: BeansRadius.xl))
            .shadow(color: BeansShadow.lifted, radius: 14, y: 8)

            // Description
            Text(challenge.challengeDescription)
                .font(BeansFont.callout)
                .foregroundStyle(BeansColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, BeansSpacing.sm)

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
