import MyToyboxCore
import SwiftUI

// MARK: - CircleSDF1Screen

/// A SwiftUI view that renders a dynamic circle animation using a Metal shader.
///
/// The view uses `TimelineView` with `.animation` schedule to update the shader in sync with time.
/// The shader renders animated signed distance fields (SDFs) of two moving circles
/// that blend together using a smooth minimum function.
@Metadata(title: .screenCircleSDF1Title, description: .screenCircleSDF1Description, tags: [.animation, .metal])
public struct CircleSDF1Screen: View {
    public init() {}

    /// The reference time when the view appears. Used to calculate elapsed seconds.
    private let startTime = Date()

    public var body: some View {
        GeometryReader { geometry in
            // The visible area, in the coordinates of the full-bleed rectangle below.
            // A floating sidebar or the home indicator only adds to the leading and
            // bottom insets, so this keeps the circles centered on what is visible.
            let visibleRect = CGRect(
                origin: CGPoint(x: geometry.safeAreaInsets.leading, y: 0),
                size: geometry.size
            )
            TimelineView(.animation) { context in
                Rectangle()
                    .colorEffect(.circleSDF1(
                        seconds: context.date.timeIntervalSince(startTime),
                        in: visibleRect
                    ))
            }
            .ignoresSafeArea(edges: .all.subtracting(.top))
        }
    }
}

extension Shader {
    /// Constructs a shader using the elapsed time in seconds as input.
    /// - Parameters:
    ///   - seconds: The time interval since the view first appeared.
    ///   - rect: The area the circles are laid out in, or `nil` for the view's bounds.
    /// - Returns: A `Shader` that applies a Metal function to the view's color.
    static func circleSDF1(seconds: TimeInterval, in rect: CGRect? = nil) -> Shader {
        let function = ShaderFunction(library: .screenModule, name: "CircleSDF1Shader::main")
        let box: Shader.Argument = rect.map { .float4($0.minX, $0.minY, $0.width, $0.height) } ?? .boundingRect
        return function(box, .float(seconds))
    }
}

#Preview {
    CircleSDF1Screen()
}
