//
//  ExpectationsView.swift
//  Beans
//

import SwiftUI

struct ExpectationsView: View {
    @Binding var currentPage: Int
    @State private var acceptedDiscomfort = false
    @State private var visibleEmoji = 0

    private let emojis: [(String, String)] = [
        ("😬", "Awkward"),
        ("😐", "Meh"),
        ("🙂", "Nice"),
        ("😄", "Amazing")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Emoji row with labels
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    ForEach(0..<emojis.count, id: \.self) { i in
                        HStack(spacing: 0) {
                            Text(emojis[i].0)
                                .font(.system(size: 40))
                                .scaleEffect(visibleEmoji > i ? 1.0 : 0.3)
                                .opacity(visibleEmoji > i ? 1.0 : 0.0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(i) * 0.25), value: visibleEmoji)
                                .frame(width: 52)

                            if i < emojis.count - 1 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(BeansColor.primary.opacity(0.4))
                                    .opacity(visibleEmoji > i + 1 ? 1.0 : 0.0)
                                    .animation(.easeIn(duration: 0.3).delay(Double(i + 1) * 0.25), value: visibleEmoji)
                                    .frame(width: 16)
                            }
                        }
                    }
                }

                // Labels — each one matches its emoji's frame width
                HStack(spacing: 0) {
                    ForEach(0..<emojis.count, id: \.self) { i in
                        HStack(spacing: 0) {
                            Text(emojis[i].1)
                                .font(BeansFont.caption)
                                .foregroundStyle(BeansColor.textSecondary)
                                .frame(width: 52)
                                .opacity(visibleEmoji > i ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.3).delay(Double(i) * 0.25 + 0.15), value: visibleEmoji)

                            if i < emojis.count - 1 {
                                Spacer().frame(width: 16)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, BeansSpacing.lg)
            .onAppear {
                for i in 1...emojis.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.28) {
                        withAnimation {
                            visibleEmoji = i
                        }
                    }
                }
            }

            // Copy
            VStack(spacing: BeansSpacing.xs) {
                Text("Some tries will be awkward.")
                    .font(BeansFont.title2)
                    .foregroundStyle(BeansColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("That's how courage works.")
                    .font(BeansFont.title3)
                    .foregroundStyle(BeansColor.secondary)
                    .multilineTextAlignment(.center)

                Text("You don't need to be good.\nYou just need to try.")
                    .font(BeansFont.callout)
                    .foregroundStyle(BeansColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.top, BeansSpacing.sm)
            }
            .padding(.horizontal, BeansSpacing.lg)

            Spacer()

            // Checkbox + CTA
            VStack(spacing: BeansSpacing.sm) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        acceptedDiscomfort.toggle()
                    }
                    HapticFeedback.selection()
                } label: {
                    HStack(spacing: BeansSpacing.xs) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(acceptedDiscomfort ? BeansColor.primary : BeansColor.textSecondary, lineWidth: 2)
                                .frame(width: 22, height: 22)

                            if acceptedDiscomfort {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(BeansColor.primary)
                                    .frame(width: 22, height: 22)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }

                        Text("I'm ready to try")
                            .font(BeansFont.callout)
                            .foregroundStyle(BeansColor.textPrimary)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    currentPage = 2
                    HapticFeedback.light()
                } label: {
                    Text("Continue")
                        .font(BeansFont.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(acceptedDiscomfort ? BeansColor.primary : BeansColor.textSecondary.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: BeansRadius.md))
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(!acceptedDiscomfort)
                .padding(.horizontal, BeansSpacing.lg)
                .padding(.bottom, BeansSpacing.sm)
            }
        }
    }
}

#Preview {
    @Previewable @State var page = 1
    ZStack {
        BeansColor.background.ignoresSafeArea()
        ExpectationsView(currentPage: $page)
    }
}
