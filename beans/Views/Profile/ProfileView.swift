//
//  ProfileView.swift
//  Beans
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var userProgress: [UserProgress]
    @Query(sort: \Attempt.date, order: .reverse) private var attempts: [Attempt]
    @Query private var challenges: [Challenge]

    private var progress: UserProgress? { userProgress.first }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: BeansColor.gradientSoft,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                Text("Me")
                    .font(BeansFont.title2)
                    .foregroundStyle(BeansColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, BeansSpacing.lg)
                    .padding(.top, BeansSpacing.md)
                    .padding(.bottom, BeansSpacing.sm)

                ScrollView {
                    VStack(spacing: BeansSpacing.md) {
                        // Avatar + name
                        avatarSection()

                        // Streak card
                        streakCard()

                        // Stats row
                        HStack(spacing: BeansSpacing.sm) {
                            StatCard(
                                value: "\(progress?.totalAttempts ?? 0)",
                                label: "Tried"
                            )
                            StatCard(
                                value: "\(attempts.filter { $0.didTry }.count)",
                                label: "Done"
                            )
                            StatCard(
                                value: "\(progress?.longestStreak ?? 0)",
                                label: "Best streak"
                            )
                        }

                        // Recent activity
                        recentActivity()
                    }
                    .padding(.horizontal, BeansSpacing.lg)
                    .padding(.bottom, BeansSpacing.xl)
                }
            }
        }
    }

    // MARK: - Avatar

    private func avatarSection() -> some View {
        VStack(spacing: BeansSpacing.xs) {
            let isAnon = progress?.isAnonymous ?? true

            ZStack {
                Circle()
                    .fill(
                        isAnon
                            ? BeansColor.primary.opacity(0.12)
                            : BeansColor.secondary.opacity(0.12)
                    )
                    .frame(width: 72, height: 72)

                Text(isAnon ? "🕶" : "🧑")
                    .font(.system(size: 32))
            }

            Text(progress?.displayName ?? "Anonymous")
                .font(BeansFont.headline)
                .foregroundStyle(isAnon ? BeansColor.textSecondary : BeansColor.textPrimary)
        }
        .padding(.top, BeansSpacing.sm)
    }

    // MARK: - Streak Card

    private func streakCard() -> some View {
        let streak = progress?.currentStreak ?? 0

        return VStack(spacing: BeansSpacing.xs) {
            HStack(spacing: 6) {
                Text("🔥")
                    .font(.system(size: 32))
                Text("\(streak)")
                    .font(BeansFont.largeTitle)
                    .foregroundStyle(BeansColor.secondary)
            }

            Text(streak > 0 ? "day streak" : "Start your streak today")
                .font(BeansFont.callout)
                .foregroundStyle(BeansColor.textSecondary)
        }
        .padding(.vertical, BeansSpacing.md)
        .frame(maxWidth: .infinity)
        .background(BeansColor.secondary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: BeansRadius.lg))
        .shadow(color: BeansShadow.card, radius: 8, y: 3)
    }

    // MARK: - Recent Activity

    private func recentActivity() -> some View {
        VStack(alignment: .leading, spacing: BeansSpacing.sm) {
            Text("Recent")
                .font(BeansFont.headline)
                .foregroundStyle(BeansColor.textPrimary)

            if attempts.isEmpty {
                Text("Nothing yet — try today's challenge!")
                    .font(BeansFont.callout)
                    .foregroundStyle(BeansColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(BeansSpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(BeansColor.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: BeansRadius.lg))
                    .shadow(color: BeansShadow.card, radius: 8, y: 3)
            } else {
                ForEach(attempts.prefix(7), id: \.id) { attempt in
                    let challenge = challenges.first(where: { $0.id == attempt.challengeId })
                    ActivityRow(attempt: attempt, challenge: challenge)
                }
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(BeansFont.title2)
                .foregroundStyle(BeansColor.primary)

            Text(label)
                .font(BeansFont.caption)
                .foregroundStyle(BeansColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, BeansSpacing.sm)
        .frame(maxWidth: .infinity)
        .background(BeansColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: BeansRadius.lg))
        .shadow(color: BeansShadow.card, radius: 8, y: 3)
    }
}

// MARK: - Activity Row

struct ActivityRow: View {
    let attempt: Attempt
    let challenge: Challenge?

    var body: some View {
        HStack(spacing: BeansSpacing.sm) {
            // Illustration thumbnail or emoji fallback
            if let illustration = challenge?.illustration {
                Image(illustration)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: BeansRadius.sm))
                    .background(BeansColor.background)
            } else {
                Text(challenge?.emoji ?? "❓")
                    .font(.system(size: 20))
                    .frame(width: 44, height: 44)
                    .background(BeansColor.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: BeansRadius.sm))
            }

            // Challenge title + note
            VStack(alignment: .leading, spacing: 2) {
                Text(challenge?.title ?? "Unknown")
                    .font(BeansFont.callout)
                    .foregroundStyle(BeansColor.textPrimary)

                if let note = attempt.note, !note.isEmpty {
                    Text(note)
                        .font(BeansFont.caption)
                        .foregroundStyle(BeansColor.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Feeling or skip indicator
            if let feeling = attempt.feeling {
                Text(feeling.rawValue)
                    .font(.system(size: 24))
            } else if !attempt.didTry {
                Text("⏭")
                    .font(.system(size: 20))
                    .foregroundStyle(BeansColor.textSecondary)
            }
        }
        .padding(BeansSpacing.sm)
        .background(BeansColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
        .shadow(color: BeansShadow.card, radius: 6, y: 2)
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [UserProgress.self, Attempt.self, Challenge.self])
}
