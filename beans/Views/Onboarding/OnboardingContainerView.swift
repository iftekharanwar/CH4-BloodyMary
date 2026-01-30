//
//  OnboardingContainerView.swift
//  Beans
//

import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            BeansColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                switch currentPage {
                case 0:
                    WelcomeView(currentPage: $currentPage)
                case 1:
                    ExpectationsView(currentPage: $currentPage)
                default:
                    IdentityChoiceView(currentPage: $currentPage)
                }

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(i == currentPage ? BeansColor.primary : BeansColor.textSecondary.opacity(0.25))
                            .frame(width: i == currentPage ? 20 : 7)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentPage)
                    }
                }
                .padding(.bottom, BeansSpacing.xl)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // Swipe right (positive translation) = go back
                    if value.translation.width > 50 && currentPage > 0 {
                        currentPage -= 1
                        HapticFeedback.light()
                    }
                }
        )
    }
}

#Preview {
    OnboardingContainerView()
}
