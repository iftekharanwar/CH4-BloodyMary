//
//  ReflectionView.swift
//  Beans
//

import SwiftUI
import SwiftData
import Lottie

struct ReflectionView: View {
    let challenge: Challenge
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var attempts: [Attempt]
    @Query private var userProgress: [UserProgress]

    @State private var selectedFeeling: Attempt.Feeling? = nil
    @State private var note: String = ""
    @State private var showConfetti = false
    @State private var submitted = false

    private let maxNoteLength = 120

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [BeansColor.background, BeansColor.accent.opacity(0.07)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Small illustration thumbnail
                if let name = challenge.illustration {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(.bottom, BeansSpacing.md)
                }

                // Casual question
                Text("How'd it go?")
                    .font(BeansFont.title2)
                    .foregroundStyle(BeansColor.textPrimary)
                    .padding(.bottom, BeansSpacing.md)

                // Emoji picker — large, tappable
                HStack(spacing: BeansSpacing.md) {
                    ForEach(Attempt.Feeling.allCases, id: \.self) { feeling in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                                selectedFeeling = feeling
                            }
                            HapticFeedback.selection()

                            // Confetti on good feelings
                            if feeling == .nice || feeling == .amazing {
                                showConfetti = true
                            }
                        } label: {
                            Text(feeling.rawValue)
                                .font(.system(size: selectedFeeling == feeling ? 56 : 44))
                                .scaleEffect(selectedFeeling == feeling ? 1.15 : 1.0)
                                .opacity(selectedFeeling == nil || selectedFeeling == feeling ? 1.0 : 0.3)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedFeeling)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, BeansSpacing.md)

                // Label for selected feeling
                if let feeling = selectedFeeling {
                    Text(feeling.displayName)
                        .font(BeansFont.headline)
                        .foregroundStyle(BeansColor.secondary)
                        .transition(.opacity.combined(with: .scale))
                        .padding(.bottom, BeansSpacing.sm)
                }

                // Optional note
                VStack(alignment: .leading, spacing: 4) {
                    TextField("What happened? (optional)", text: $note, axis: .vertical)
                        .font(BeansFont.callout)
                        .foregroundStyle(BeansColor.textPrimary)
                        .lineLimit(3)
                        .padding(BeansSpacing.sm)
                        .background(BeansColor.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
                        .shadow(color: BeansShadow.card, radius: 6, y: 2)
                        .onChange(of: note) { _, newValue in
                            if newValue.count > maxNoteLength {
                                note = String(newValue.prefix(maxNoteLength))
                            }
                        }

                    Text("\(note.count)/\(maxNoteLength)")
                        .font(BeansFont.caption2)
                        .foregroundStyle(BeansColor.textSecondary)
                }
                .padding(.horizontal, BeansSpacing.lg)

                Spacer()

                // CTA buttons
                VStack(spacing: BeansSpacing.xs) {
                    Button {
                        saveReflection(didTry: true)
                    } label: {
                        Text("Done")
                            .font(BeansFont.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedFeeling != nil ? BeansColor.secondary : BeansColor.textSecondary.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
                            .shadow(color: selectedFeeling != nil ? BeansShadow.button : .clear, radius: 8, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(selectedFeeling == nil)

                    Button {
                        saveReflection(didTry: false)
                    } label: {
                        Text("Maybe tomorrow")
                            .font(BeansFont.caption)
                            .foregroundStyle(BeansColor.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
                .padding(.horizontal, BeansSpacing.lg)
                .padding(.bottom, BeansSpacing.xl)
            }

            // Lottie confetti overlay
            if showConfetti {
                LottieView {
                    try await DotLottieFile.named("confetti-celebration")
                }
                .playing()
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
        }
    }

    private func saveReflection(didTry: Bool) {
        let today = Date().startOfDay
        var attempt = attempts.first { $0.date.startOfDay == today && $0.challengeId == challenge.id }

        if attempt == nil {
            attempt = Attempt(challengeId: challenge.id)
            modelContext.insert(attempt!)
        }

        attempt?.didTry = didTry
        attempt?.feeling = didTry ? selectedFeeling : nil
        attempt?.note = note.isEmpty ? nil : note

        // Update streak
        if let progress = userProgress.first {
            progress.totalAttempts += 1

            if let lastDate = progress.lastAttemptDate?.startOfDay {
                if lastDate == Date().startOfDay.addingTimeInterval(-86400) {
                    progress.currentStreak += 1
                } else if lastDate != Date().startOfDay {
                    progress.currentStreak = 1
                }
            } else {
                progress.currentStreak = 1
            }
            progress.longestStreak = max(progress.longestStreak, progress.currentStreak)
            progress.lastAttemptDate = Date()
        }

        try? modelContext.save()
        HapticFeedback.success()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            onComplete()
        }
    }
}

#Preview {
    let sample = Challenge(
        title: "Board Game Trap",
        description: "Sit in a public place with a board game.",
        difficulty: .easy,
        estimatedTime: "10-30 min",
        emoji: "🎲",
        illustration: "challenge-boardgame",
        category: "Passive Invitation"
    )
    ReflectionView(challenge: sample, onComplete: {})
        .modelContainer(for: [Attempt.self, UserProgress.self])
}
