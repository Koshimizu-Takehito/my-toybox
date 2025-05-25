import SwiftUI

// MARK: - PipCardDemoScreen

/// A demo view showcasing a draggable card that snaps to the nearest screen corner or center.
///
/// - The card follows the user's drag gesture, moving smoothly across the screen.
/// - When released, the card automatically snaps to the closest corner or the center,
///   using a spring animation. Inertia is taken into account for a natural feel.
/// - The card's size is adaptable and defined by the `cardRect` property.
struct PipCardDemoScreen: View {
    /// Persistent offset of the card from the center of the screen.
    /// This offset accumulates over multiple drags.
    @State private var cardOffset: CGSize = .zero

    /// Temporary offset during an active drag gesture.
    /// This value is only nonzero while the user is dragging.
    @State private var dragOffset: CGSize = .zero

    /// The frame (position and size) of the draggable card.
    /// Can be customized to change the card's dimensions.
    @State private var cardRect = CGRect.zero

    var body: some View {
        GeometryReader { geometry in
            // Define the rectangle representing the full screen in local coordinates.
            let screen = geometry.frame(in: .local)

            CardView()
                .onGeometryChange(for: CGSize.self, of: \.self.size) { size in
                    cardRect.size = size
                }
                .position(
                    // Compute the card's position as the screen center plus current offset and drag.
                    CGPoint(
                        x: screen.midX + cardOffset.width + dragOffset.width,
                        y: screen.midY + cardOffset.height + dragOffset.height
                    )
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update drag offset as the gesture progresses for smooth visual feedback.
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            // Calculate the final offset based on the drag gesture's total translation.
                            let finalOffset = cardOffset + value.translation
                            cardOffset = finalOffset
                            dragOffset = .zero
                            // Estimate the velocity of the drag for an inertia (momentum) effect.
                            let velocity = value.predictedEndTranslation - value.translation
                            // Compute the snap (destination) offset using the helper method.
                            let snapped = snappedPosition(
                                for: finalOffset,
                                screen: screen,
                                velocity: velocity
                            )
                            // Animate the card snapping into position with a spring effect.
                            withAnimation(.spring()) {
                                cardOffset = snapped
                            }
                        }
                )
        }
        .padding()
    }

    /// Computes the snapped (destination) offset for the card,
    /// snapping it to the nearest screen corner or center.
    ///
    /// - Parameters:
    ///   - offset: The current offset of the card relative to screen center.
    ///   - screen: The full screen rectangle.
    ///   - velocity: The drag gesture's velocity (for inertia effect).
    /// - Returns: The snapped offset to animate the card towards.
    private func snappedPosition(for offset: CGSize, screen: CGRect, velocity: CGSize) -> CGSize {
        // Compute the card's actual center on the screen.
        var cardCenter = CGPoint(
            x: screen.midX + offset.width,
            y: screen.midY + offset.height
        )
        // Apply a portion of the gesture's velocity for natural inertia.
        let inertiaRatio = 0.4
        let x = cardCenter.x + inertiaRatio * velocity.width
        let y = cardCenter.y + inertiaRatio * velocity.height

        // Clamp the values so the card remains within the screen bounds.
        cardCenter.x = min(max(x, -screen.width), screen.width)
        cardCenter.y = min(max(y, -screen.height), screen.height)

        // Define possible snap positions: four corners and the center of the screen.
        let snapPoints: [CGPoint] = [
            CGPoint(x: cardRect.midX, y: cardRect.midY),  // Top-left
            CGPoint(x: screen.width - cardRect.midX, y: cardRect.midY),  // Top-right
            CGPoint(x: screen.midX, y: screen.midY),  // Center
            CGPoint(x: cardRect.midX, y: screen.height - cardRect.midY),  // Bottom-left
            CGPoint(x: screen.width - cardRect.midX, y: screen.height - cardRect.midY),  // Bottom-right
        ]

        // Find the closest snap point by comparing Euclidean distance.
        let nearest = snapPoints.min { abs($0 - cardCenter) < abs($1 - cardCenter) }!

        // Return the offset required to move the card to this snap point (relative to screen center).
        return CGSize(
            width: nearest.x - screen.midX,
            height: nearest.y - screen.midY
        )
    }
}

// MARK: - CardView

/// A visual representation of the draggable card.
/// Styled with rounded corners, a shadow, and instructional text.
private struct CardView: View {
    var body: some View {
        Text("Drag me!\nI snap to corners.")
            .foregroundColor(.white)
            .font(.headline)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
            .background(.blue.gradient, in: .rect(cornerRadius: 20))
            .shadow(radius: 8)
    }
}

// MARK: - CGPoint arithmetic extensions

/// Arithmetic helpers for CGPoint to enable vector addition and subtraction.
extension CGPoint {
    fileprivate static func + (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    fileprivate static func - (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

// MARK: - CGSize arithmetic extensions

/// Arithmetic helpers for CGSize to enable vector addition and subtraction.
extension CGSize {
    fileprivate static func + (lhs: Self, rhs: Self) -> Self {
        Self(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    fileprivate static func - (lhs: Self, rhs: Self) -> Self {
        Self(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
}

/// Computes the Euclidean distance (magnitude) of a CGPoint from the origin (0, 0).
///
/// - Parameter p: The CGPoint whose distance is to be calculated.
/// - Returns: The scalar distance from the origin.
private func abs(_ p: CGPoint) -> CGFloat {
    hypot(p.x, p.y)
}

// MARK: - Preview

#Preview {
    PipCardDemoScreen()
}
