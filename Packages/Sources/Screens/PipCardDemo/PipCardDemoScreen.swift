import MyToyboxCore
import SwiftUI

// MARK: - PipCardDemoScreen

/// A demo view showcasing a draggable card that snaps to the nearest screen corner or center.
///
/// - The card follows the user's drag gesture, moving smoothly across the screen.
/// - When released, the card automatically snaps to the closest corner or the center,
///   using a spring animation. Inertia is taken into account for a natural feel.
/// - The card's size is adaptable and defined by the `cardRect` property.
@Metadata(title: .screenPipCardDemoTitle, description: .screenPipCardDemoDescription, tags: [.animation])
public struct PipCardDemoScreen: View {
    public init() {}

    /// The snap destination the card currently rests at.
    ///
    /// The anchor (not a point offset) is persisted so that the card stays
    /// pinned to the same corner when the container is resized.
    @State private var anchor: SnapAnchor = .center

    /// Temporary offset during an active drag gesture.
    /// This value is only nonzero while the user is dragging.
    @State private var dragOffset: CGSize = .zero

    /// The frame (position and size) of the draggable card.
    /// Can be customized to change the card's dimensions.
    @State private var cardRect = CGRect.zero

    public var body: some View {
        GeometryReader { geometry in
            // Define the rectangle representing the full screen in local coordinates.
            let screen = geometry.frame(in: .local)
            // Recompute the resting offset from the anchor for the current screen size.
            let cardOffset = offset(for: anchor, in: screen)

            CardView()
                .onGeometryChange(for: CGSize.self, of: \.size) { size in
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
                            // Estimate the velocity of the drag for an inertia (momentum) effect.
                            let velocity = value.predictedEndTranslation - value.translation
                            // Compute the snap destination using the helper method.
                            let snapped = snappedAnchor(
                                for: finalOffset,
                                screen: screen,
                                velocity: velocity
                            )
                            // Animate the card snapping into position with a spring effect.
                            withAnimation(.spring()) {
                                anchor = snapped
                                dragOffset = .zero
                            }
                        }
                )
        }
        .padding()
    }

    /// Computes the snap destination for the card,
    /// choosing the nearest screen corner or center.
    ///
    /// - Parameters:
    ///   - offset: The current offset of the card relative to screen center.
    ///   - screen: The full screen rectangle.
    ///   - velocity: The drag gesture's velocity (for inertia effect).
    /// - Returns: The anchor to animate the card towards.
    private func snappedAnchor(for offset: CGSize, screen: CGRect, velocity: CGSize) -> SnapAnchor {
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

        // Find the closest snap point by comparing Euclidean distance.
        return SnapAnchor.allCases.min {
            abs(point(for: $0, in: screen) - cardCenter) < abs(point(for: $1, in: screen) - cardCenter)
        }!
    }

    /// Returns the card center for the given anchor in the screen's local coordinates.
    private func point(for anchor: SnapAnchor, in screen: CGRect) -> CGPoint {
        switch anchor {
        case .topLeading:
            CGPoint(x: cardRect.midX, y: cardRect.midY)
        case .topTrailing:
            CGPoint(x: screen.width - cardRect.midX, y: cardRect.midY)
        case .center:
            CGPoint(x: screen.midX, y: screen.midY)
        case .bottomLeading:
            CGPoint(x: cardRect.midX, y: screen.height - cardRect.midY)
        case .bottomTrailing:
            CGPoint(x: screen.width - cardRect.midX, y: screen.height - cardRect.midY)
        }
    }

    /// Returns the offset from the screen center that places the card at the given anchor.
    private func offset(for anchor: SnapAnchor, in screen: CGRect) -> CGSize {
        let point = point(for: anchor, in: screen)
        return CGSize(width: point.x - screen.midX, height: point.y - screen.midY)
    }
}

// MARK: - SnapAnchor

/// The positions the card can snap to: the four corners and the center of the screen.
private enum SnapAnchor: CaseIterable {
    case topLeading
    case topTrailing
    case center
    case bottomLeading
    case bottomTrailing
}

// MARK: - CardView

/// A visual representation of the draggable card.
/// Styled with rounded corners, a shadow, and instructional text.
private struct CardView: View {
    var body: some View {
        Text(verbatim: "Drag me!\nI snap to corners.")
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
private extension CGPoint {
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

// MARK: - CGSize arithmetic extensions

/// Arithmetic helpers for CGSize to enable vector addition and subtraction.
private extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func - (lhs: Self, rhs: Self) -> Self {
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
