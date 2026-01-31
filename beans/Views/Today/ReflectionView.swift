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
    @FocusState private var noteFieldFocused: Bool

    private let maxNoteLength = 120

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Background — tappable to dismiss keyboard
                LinearGradient(
                    colors: [BeansColor.background, BeansColor.accent.opacity(0.07)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    noteFieldFocused = false
                }

                VStack(spacing: 0) {
                    // Top section — collapses when keyboard is up
                    if !noteFieldFocused {
                        Spacer()

                        if let name = challenge.illustration {
                            Image(name)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .padding(.bottom, BeansSpacing.md)
                        }

                        Text("How'd it go?")
                            .font(BeansFont.title2)
                            .foregroundStyle(BeansColor.textPrimary)
                            .padding(.bottom, BeansSpacing.md)

                        EmojiPicker(selection: $selectedFeeling)
                            .padding(.bottom, BeansSpacing.sm)

                        if let feeling = selectedFeeling {
                            Text(feeling.displayName)
                                .font(BeansFont.headline)
                                .foregroundStyle(BeansColor.secondary)
                                .transition(.opacity.combined(with: .scale))
                        }

                        Spacer()
                    } else {
                        // Compact header when typing — just show the selected feeling
                        Spacer(minLength: 0)

                        HStack(spacing: BeansSpacing.xs) {
                            if let feeling = selectedFeeling {
                                Text(feeling.rawValue)
                                    .font(.system(size: 28))
                                Text(feeling.displayName)
                                    .font(BeansFont.headline)
                                    .foregroundStyle(BeansColor.secondary)
                            }
                        }
                        .padding(.top, BeansSpacing.md)
                        .padding(.bottom, BeansSpacing.sm)
                    }

                    // Note field
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("What happened? (optional)", text: $note, axis: .vertical)
                            .font(BeansFont.callout)
                            .foregroundStyle(BeansColor.textPrimary)
                            .lineLimit(3)
                            .padding(BeansSpacing.sm)
                            .background(BeansColor.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
                            .shadow(color: BeansShadow.card, radius: 6, y: 2)
                            .focused($noteFieldFocused)
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

                    Spacer(minLength: BeansSpacing.md)

                    // CTA buttons — always visible above keyboard
                    VStack(spacing: BeansSpacing.xs) {
                        Button {
                            noteFieldFocused = false
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
                            noteFieldFocused = false
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
                .ignoresSafeArea(edges: .bottom)

                // Lottie confetti — fires after Done is tapped, not on feeling selection
                if showConfetti {
                    LottieView {
                        try await DotLottieFile.named("confetti-celebration")
                    }
                    .playing(loopMode: .playOnce)
                    .allowsHitTesting(false)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
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

        // Confetti on positive feelings — fires here, after save, not on selection
        if didTry && (selectedFeeling == .nice || selectedFeeling == .amazing) {
            showConfetti = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
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
