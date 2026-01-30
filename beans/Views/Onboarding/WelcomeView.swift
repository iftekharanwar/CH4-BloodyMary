//
//  WelcomeView.swift
//  Beans
//

import SwiftUI
import Lottie

struct WelcomeView: View {
    @Binding var currentPage: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Lottie animation — looping
            LottieView {
                try await DotLottieFile.named("welcome-friends")
            }
            .playing(loopMode: .loop)
            .frame(width: 320, height: 320)

            // Copy — tight to the animation, no gap
            VStack(spacing: BeansSpacing.sm) {
                Text("Meet people\nwithout the awkward part")
                    .font(BeansFont.largeTitle)
                    .foregroundStyle(BeansColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("One tiny challenge a day.\nZero pressure.")
                    .font(BeansFont.callout)
                    .foregroundStyle(BeansColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.horizontal, BeansSpacing.lg)

            Spacer()

            // CTA — solid sage
            Button {
                currentPage = 1
                HapticFeedback.light()
            } label: {
                Text("Let's go")
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
}

#Preview {
    @Previewable @State var page = 0
    ZStack {
        BeansColor.background.ignoresSafeArea()
        WelcomeView(currentPage: $page)
    }
}
