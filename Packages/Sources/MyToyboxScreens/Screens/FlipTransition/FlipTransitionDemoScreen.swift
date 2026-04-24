import SwiftUI

// MARK: - FlipTransitionDemoScreen

/// A demo screen that showcases how to use a custom flip transition in SwiftUI.
///
/// This screen displays a vocabulary card that can be flipped by tapping.
/// The front side shows the word; the back side shows its meaning.
@Metadata(title: .screenFlipTransitionDemoTitle, description: .screenFlipTransitionDemoDescription, tags: [.animation])
struct FlipTransitionDemoScreen: View {
    var body: some View {
        VStack {
            Card(
                word: "Hello, World!",
                meaning: "こんにちは世界"
            )
            Text(verbatim: "Tap card to flip.")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Card

/// A view representing a two-sided vocabulary card.
///
/// When tapped, the card flips with an animated transition,
/// toggling between the front (word) and back (meaning) sides.
private struct Card: View {
    /// Indicates whether the card is showing the back side.
    @State private var isFlipped = false
    /// Unique ID used to force SwiftUI to treat front and back as separate views,
    /// ensuring the transition animation is triggered each time.
    @State private var id = UUID()
    /// The word to display on the front side.
    var word: String
    /// The meaning to display on the back side.
    var meaning: String

    var body: some View {
        Group {
            if !isFlipped {
                CardSide(text: word)
            } else {
                CardSide(text: meaning)
            }
        }
        .id(id)
        .transition(.flip)
        .onTapGesture {
            withAnimation {
                id = UUID()
                isFlipped.toggle()
            }
        }
    }
}

// MARK: - CardSide

/// Displays one side of the card, styled as a rounded rectangle with centered text.
private struct CardSide: View {
    /// The text to display on this side of the card.
    var text: String

    var body: some View {
        Rectangle()
            // Create a rounded rectangle shape for the card
            .clipShape(.rect(cornerSize: CGSize(width: 30, height: 30 / 0.6)))
            // Slightly flatten the card for a card-like aspect ratio
            .scaleEffect(y: 0.6)
            .foregroundStyle(.background)
            .overlay {
                Text(text)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.foreground)
            }
            .shadow(color: .gray, radius: 10)
            .scaledToFit()
            .padding()
            .frame(maxWidth: 500)
    }
}

// MARK: - FlipTransition

/// A custom transition that animates a view flipping around the Y axis,
/// simulating a card flip effect.
struct FlipTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle(for: phase)),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .opacity(opacity(for: phase))
    }

    /// Determines the rotation angle for each phase of the transition.
    private func angle(for phase: TransitionPhase) -> Double {
        switch phase {
        case .identity:
            0

        case .willAppear:
            -180

        case .didDisappear:
            180
        }
    }

    /// Controls the opacity during the transition phases to hide the card as it flips.
    private func opacity(for phase: TransitionPhase) -> Double {
        switch phase {
        case .identity:
            1

        case .willAppear, .didDisappear:
            0
        }
    }
}

// MARK: - Transition Extension

extension Transition where Self == FlipTransition {
    /// A convenient static property for the custom flip transition.
    static var flip: Self { FlipTransition() }
}

// MARK: - Preview

#Preview {
    FlipTransitionDemoScreen()
}
