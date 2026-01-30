//
//  IdentityChoiceView.swift
//  Beans
//

import SwiftUI
import SwiftData

struct IdentityChoiceView: View {
    @Binding var currentPage: Int

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext

    @State private var isAnonymous = true
    @State private var nickname = ""

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Emoji avatar
            ZStack {
                Circle()
                    .fill(
                        isAnonymous
                            ? BeansColor.primary.opacity(0.1)
                            : BeansColor.secondary.opacity(0.1)
                    )
                    .frame(width: 120, height: 120)

                Text(isAnonymous ? "🕶" : "🧑")
                    .font(.system(size: 56))
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isAnonymous)
            }
            .animation(.easeInOut(duration: 0.3), value: isAnonymous)
            .padding(.bottom, BeansSpacing.lg)

            // Question
            Text("Who are you today?")
                .font(BeansFont.title2)
                .foregroundStyle(BeansColor.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, BeansSpacing.md)

            // Segmented toggle: primary-colored track, white sliding pill
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: BeansRadius.md)
                    .fill(BeansColor.primary)
                    .frame(height: 52)

                // Sliding white pill
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: BeansRadius.md - 3)
                        .fill(.white)
                        .frame(width: geo.size.width / 2, height: geo.size.height)
                        .offset(x: isAnonymous ? 0 : geo.size.width / 2)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isAnonymous)
                }

                // Labels on top
                HStack(spacing: 0) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            isAnonymous = true
                        }
                        HapticFeedback.selection()
                    } label: {
                        Text("Anonymous")
                            .font(BeansFont.headline)
                            .foregroundStyle(isAnonymous ? BeansColor.textPrimary : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .animation(.easeInOut(duration: 0.25), value: isAnonymous)
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            isAnonymous = false
                        }
                        HapticFeedback.selection()
                    } label: {
                        Text("Nickname")
                            .font(BeansFont.headline)
                            .foregroundStyle(!isAnonymous ? BeansColor.textPrimary : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .animation(.easeInOut(duration: 0.25), value: isAnonymous)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 52)
            .padding(.horizontal, BeansSpacing.lg)

            // Nickname field
            if !isAnonymous {
                TextField("Pick a nickname", text: $nickname)
                    .font(BeansFont.body)
                    .foregroundStyle(BeansColor.textPrimary)
                    .padding(.vertical, 14)
                    .padding(.horizontal, BeansSpacing.sm)
                    .background(BeansColor.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
                    .shadow(color: BeansShadow.card, radius: 6, y: 2)
                    .padding(.horizontal, BeansSpacing.lg)
                    .padding(.top, BeansSpacing.sm)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Text(isAnonymous ? "No one needs to know who you are." : "You can change this anytime.")
                .font(BeansFont.caption)
                .foregroundStyle(BeansColor.textSecondary)
                .padding(.top, BeansSpacing.sm)

            Spacer()

            // CTA
            Button {
                completeOnboarding()
            } label: {
                Text("Get started")
                    .font(BeansFont.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(BeansColor.primary)
                    .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, BeansSpacing.lg)
            .padding(.bottom, BeansSpacing.sm)
        }
    }

    private func completeOnboarding() {
        let progress = UserProgress(
            displayName: isAnonymous || nickname.isEmpty ? nil : nickname,
            isAnonymous: isAnonymous,
            hasCompletedOnboarding: true
        )
        modelContext.insert(progress)
        try? modelContext.save()

        HapticFeedback.success()
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    @Previewable @State var page = 2
    IdentityChoiceView(currentPage: $page)
        .modelContainer(for: [UserProgress.self])
}
