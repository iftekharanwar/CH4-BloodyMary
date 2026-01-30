//
//  FeedView.swift
//  Beans
//

import SwiftUI
import SwiftData

struct FeedView: View {
    @Query(sort: \Attempt.date, order: .reverse) private var attempts: [Attempt]
    @Query private var challenges: [Challenge]

    private var feedAttempts: [Attempt] {
        attempts.filter { $0.didTry && $0.feeling != nil }
    }

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
                Text("Feed")
                    .font(BeansFont.title2)
                    .foregroundStyle(BeansColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, BeansSpacing.lg)
                    .padding(.top, BeansSpacing.md)
                    .padding(.bottom, BeansSpacing.sm)

                if feedAttempts.isEmpty {
                    Spacer()
                    emptyState()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: BeansSpacing.sm) {
                            ForEach(feedAttempts, id: \.id) { attempt in
                                if let challenge = challenges.first(where: { $0.id == attempt.challengeId }) {
                                    FeedCardView(attempt: attempt, challenge: challenge)
                                }
                            }
                        }
                        .padding(.horizontal, BeansSpacing.lg)
                        .padding(.bottom, BeansSpacing.xl)
                    }
                }
            }
        }
    }

    private func emptyState() -> some View {
        VStack(spacing: BeansSpacing.md) {
            Image(systemName: "globe")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(BeansColor.primary)

            Text("Nothing here yet")
                .font(BeansFont.title3)
                .foregroundStyle(BeansColor.textPrimary)

            Text("Complete a challenge and your experience will show up here.")
                .font(BeansFont.callout)
                .foregroundStyle(BeansColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeansSpacing.lg)
        }
    }
}

#Preview {
    FeedView()
        .modelContainer(for: [Attempt.self, Challenge.self])
}
