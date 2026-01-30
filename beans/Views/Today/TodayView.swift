//
//  TodayView.swift
//  Beans
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Challenge.createdAt) private var challenges: [Challenge]
    @Query private var attempts: [Attempt]
    @Query private var userProgress: [UserProgress]

    @State private var todayChallenge: Challenge?
    @State private var todayAttempt: Attempt?
    @State private var showingReflection = false
    @State private var completedToday = false

    var body: some View {
        ZStack {
            // Soft background
            LinearGradient(
                colors: BeansColor.gradientSoft,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header — streak + date
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today")
                            .font(BeansFont.title2)
                            .foregroundStyle(BeansColor.textPrimary)

                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(BeansFont.caption)
                            .foregroundStyle(BeansColor.textSecondary)
                    }

                    Spacer()

                    // Streak badge
                    let streak = userProgress.first?.currentStreak ?? 0
                    if streak > 0 {
                        HStack(spacing: 4) {
                            Text("🔥")
                                .font(.system(size: 18))
                            Text("\(streak)")
                                .font(BeansFont.headline)
                                .foregroundStyle(BeansColor.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(BeansColor.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding(.horizontal, BeansSpacing.lg)
                .padding(.top, BeansSpacing.md)
                .padding(.bottom, BeansSpacing.sm)

                Spacer()

                // Main content
                if completedToday {
                    completedState()
                } else if showingReflection, let challenge = todayChallenge {
                    ReflectionView(challenge: challenge, onComplete: handleReflectionComplete)
                        .transition(.opacity)
                } else if let challenge = todayChallenge {
                    ChallengeCardView(challenge: challenge, onAccept: acceptChallenge, onSkip: skipChallenge)
                        .transition(.opacity)
                } else {
                    // Loading
                    VStack(spacing: BeansSpacing.sm) {
                        Text("🌱")
                            .font(.system(size: 48))
                        Text("Loading...")
                            .font(BeansFont.callout)
                            .foregroundStyle(BeansColor.textSecondary)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            loadTodayChallenge()
        }
    }

    // Shown after completing today's reflection
    private func completedState() -> some View {
        VStack(spacing: BeansSpacing.md) {
            Text("🎉")
                .font(.system(size: 64))

            Text("You did it!")
                .font(BeansFont.title2)
                .foregroundStyle(BeansColor.textPrimary)

            Text("Come back tomorrow for your next challenge.")
                .font(BeansFont.callout)
                .foregroundStyle(BeansColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeansSpacing.lg)
        }
    }

    private func loadTodayChallenge() {
        let today = Date().startOfDay
        todayAttempt = attempts.first { $0.date.startOfDay == today }

        if let attempt = todayAttempt {
            todayChallenge = challenges.first { $0.id == attempt.challengeId }
            // Already reflected today
            if attempt.feeling != nil || (!attempt.didTry && attempt.note != nil) {
                completedToday = true
            }
        } else {
            todayChallenge = challenges.filter({ $0.isActive }).randomElement()
        }
    }

    private func acceptChallenge() {
        guard let challenge = todayChallenge else { return }

        if todayAttempt == nil {
            let attempt = Attempt(challengeId: challenge.id)
            modelContext.insert(attempt)
            todayAttempt = attempt
            try? modelContext.save()
        }

        HapticFeedback.success()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingReflection = true
        }
    }

    private func skipChallenge() {
        let available = challenges.filter { $0.isActive && $0.id != todayChallenge?.id }
        if let next = available.randomElement() {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                todayChallenge = next
            }
            HapticFeedback.light()
        }
    }

    private func handleReflectionComplete() {
        withAnimation {
            showingReflection = false
            completedToday = true
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [Challenge.self, Attempt.self, UserProgress.self])
}
