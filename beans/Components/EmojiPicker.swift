//
//  EmojiPicker.swift
//  Beans
//
//  Interactive emoji selector for reflection
//

import SwiftUI

struct EmojiPicker: View {
    @Binding var selection: Attempt.Feeling?
    let feelings: [Attempt.Feeling] = Attempt.Feeling.allCases

    @State private var bounceStates: [Attempt.Feeling: Bool] = [:]

    var body: some View {
        HStack(spacing: BeansSpacing.md) {
            ForEach(feelings, id: \.self) { feeling in
                Button {
                    // Trigger bounce animation
                    bounceStates[feeling] = true

                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        selection = feeling
                    }

                    HapticFeedback.selection()

                    // Reset bounce after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        bounceStates[feeling] = false
                    }
                } label: {
                    Text(feeling.rawValue)
                        .font(.system(size: selection == feeling ? 64 : 48))
                        .scaleEffect(getBounceScale(for: feeling))
                        .opacity(selection == nil || selection == feeling ? 1.0 : 0.4)
                        .rotationEffect(.degrees(selection == feeling ? 0 : (bounceStates[feeling] == true ? 5 : 0)))
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: selection)
                        .animation(.spring(response: 0.2, dampingFraction: 0.4), value: bounceStates[feeling])
                }
                .buttonStyle(.plain)
            }
        }
        .padding(BeansSpacing.sm)
    }

    private func getBounceScale(for feeling: Attempt.Feeling) -> CGFloat {
        if bounceStates[feeling] == true {
            return 1.3
        }
        return selection == feeling ? 1.1 : 1.0
    }
}

#Preview {
    @Previewable @State var selectedFeeling: Attempt.Feeling? = .nice

    VStack(spacing: BeansSpacing.lg) {
        Text("How did it go?")
            .font(BeansFont.title2)

        EmojiPicker(selection: $selectedFeeling)

        if let feeling = selectedFeeling {
            Text(feeling.displayName)
                .font(BeansFont.headline)
                .foregroundStyle(BeansColor.textSecondary)
        }
    }
    .padding()
}
