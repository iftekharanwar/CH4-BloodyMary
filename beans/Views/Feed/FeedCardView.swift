//
//  FeedCardView.swift
//  Beans
//

import SwiftUI

struct FeedCardView: View {
    let attempt: Attempt
    let challenge: Challenge

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top row: illustration thumbnail + feeling emoji
            HStack(alignment: .center, spacing: BeansSpacing.sm) {
                // Illustration thumbnail
                if let name = challenge.illustration {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: BeansRadius.sm))
                        .background(BeansColor.background)
                } else {
                    // Fallback: emoji in a colored circle
                    Text(challenge.emoji)
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(BeansColor.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: BeansRadius.sm))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(challenge.title)
                        .font(BeansFont.headline)
                        .foregroundStyle(BeansColor.textPrimary)

                    Text(attempt.date.formatted(date: .abbreviated, time: .omitted))
                        .font(BeansFont.caption)
                        .foregroundStyle(BeansColor.textSecondary)
                }

                Spacer()

                // Feeling emoji — the headline of the card
                if let feeling = attempt.feeling {
                    Text(feeling.rawValue)
                        .font(.system(size: 36))
                }
            }
            .padding(.bottom, BeansSpacing.sm)

            // Note (if provided)
            if let note = attempt.note, !note.isEmpty {
                Text(note)
                    .font(BeansFont.callout)
                    .foregroundStyle(BeansColor.textPrimary)
                    .lineSpacing(3)
                    .padding(.bottom, BeansSpacing.sm)
            }

            // Divider
            Rectangle()
                .fill(BeansColor.textSecondary.opacity(0.12))
                .frame(height: 1)
                .padding(.bottom, BeansSpacing.sm)

            // Reactions
            HStack(spacing: BeansSpacing.sm) {
                ReactionPill(emoji: "❤️", count: 0)
                ReactionPill(emoji: "💪", count: 0)
                ReactionPill(emoji: "😂", count: 0)
            }
        }
        .padding(BeansSpacing.md)
        .background(BeansColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: BeansRadius.lg))
        .shadow(color: BeansShadow.card, radius: 8, y: 3)
    }
}

struct ReactionPill: View {
    let emoji: String
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 14))

            if count > 0 {
                Text("\(count)")
                    .font(BeansFont.caption2)
                    .foregroundStyle(BeansColor.textSecondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(BeansColor.background)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    let sampleChallenge = Challenge(
        title: "Board Game Trap",
        description: "Sit in a public place with a multiplayer game set up.",
        difficulty: .easy,
        estimatedTime: "10-30 min",
        emoji: "🎲",
        illustration: "challenge-boardgame",
        category: "Passive Invitation"
    )

    let sampleAttempt = Attempt(
        challengeId: sampleChallenge.id,
        didTry: true,
        feeling: .amazing,
        note: "Someone actually sat down to play! We ended up talking about board game cafes."
    )

    ZStack {
        BeansColor.background.ignoresSafeArea()
        FeedCardView(attempt: sampleAttempt, challenge: sampleChallenge)
            .padding()
    }
}
