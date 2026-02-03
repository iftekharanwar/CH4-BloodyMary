//
//  TodayView.swift
//  Beans
//

import SwiftUI
import SwiftData
import Lottie

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Challenge.createdAt) private var challenges: [Challenge]
    @Query private var attempts: [Attempt]
    @Query private var userProgress: [UserProgress]

    @State private var todayChallenge: Challenge?
    @State private var todayAttempt: Attempt?
    @State private var showingReflection = false
    @State private var completedToday = false

    @State private var showCompleted = false

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
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(BeansColor.secondary)
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
                        Image(systemName: "leaf")
                            .font(.system(size: 40, weight: .light))
                            .foregroundStyle(BeansColor.primary)
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
        let attempt = attempts.first { $0.date.startOfDay == Date().startOfDay }

        return ZStack {
            VStack(spacing: 0) {
                Spacer()

                // Header
                Text("You did it!")
                    .font(BeansFont.title)
                    .foregroundStyle(BeansColor.textPrimary)

                if let challenge = todayChallenge {
                    Text(challenge.title)
                        .font(BeansFont.headline)
                        .foregroundStyle(BeansColor.textSecondary)
                        .padding(.top, BeansSpacing.xs)
                }

                Spacer(minLength: BeansSpacing.lg)

                // Hero card — illustration + feeling + quote
                VStack(spacing: 0) {
                    // Illustration inside the card
                    if let challenge = todayChallenge {
                        if let name = challenge.illustration {
                            Image(name)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipped()
                        } else {
                            Text(challenge.emoji)
                                .font(.system(size: 64))
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .background(BeansColor.primary.opacity(0.08))
                        }
                    }

                    // Feeling emoji + quote below illustration
                    if let feeling = attempt?.feeling {
                        VStack(spacing: BeansSpacing.sm) {
                            Text(feeling.rawValue)
                                .font(.system(size: 48))

                            Text(quoteFor(feeling))
                                .font(BeansFont.callout)
                                .foregroundStyle(BeansColor.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, BeansSpacing.md)
                        .padding(.horizontal, BeansSpacing.lg)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(BeansColor.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: BeansRadius.xl))
                .shadow(color: BeansShadow.lifted, radius: 14, y: 8)
                .padding(.horizontal, BeansSpacing.lg)

                Spacer()
            }
            .opacity(showCompleted ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.4), value: showCompleted)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    showCompleted = true
                }
            }
        }
    }

    private func quoteFor(_ feeling: Attempt.Feeling) -> String {
        switch feeling {
        case .awkward:
            return "Awkward moments are just courage in disguise. You showed up — that's everything."
        case .neutral:
            return "Not every try feels amazing. The fact that you did it anyway says a lot about you."
        case .nice:
            return "That's the sweet spot. A little uncomfortable, a little rewarding. Keep going."
        case .amazing:
            return "This is what happens when you step outside your comfort zone. Remember this feeling."
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
