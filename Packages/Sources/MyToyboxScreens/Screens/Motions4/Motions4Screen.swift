// https://x.com/okazz_/status/1870807939944243631
import SwiftUI

#if os(iOS)

// MARK: - ContentView

/// A screen that showcases four distinct animations side-by-side using a shared spring animation.
///
/// Each animated view demonstrates a different visual transformation, from geometry changes
/// to transformations and path-based drawing, all driven by a single shared progress value.
@Metadata(title: "4 motions", description: "4 motions", tags: [.animation])
struct Motions4Screen: View {
    /// The animation progress value, ranging from 0 to 1.
    /// It is updated on appear and drives all subview animations.
    @State private var progress: Double = 0

    var body: some View {
        MyGroup {
            Content01(#colorLiteral(red: 0.8549019608, green: 0.2549019608, blue: 0.4039215686, alpha: 1), #colorLiteral(red: 1, green: 0.8392156863, blue: 0.2235294118, alpha: 1), progress: progress)
            Content02(#colorLiteral(red: 0.03137254902, green: 0.2392156863, blue: 0.4666666667, alpha: 1), #colorLiteral(red: 0.9843137255, green: 0.6862745098, blue: 0, alpha: 1), progress: progress)
            Content03(#colorLiteral(red: 0.5058823529, green: 0.8117647059, blue: 0.8980392157, alpha: 1), #colorLiteral(red: 0, green: 0.6862745098, blue: 0.3294117647, alpha: 1), progress: progress)
            Content04(#colorLiteral(red: 0.03137254902, green: 0.2392156863, blue: 0.4666666667, alpha: 1), #colorLiteral(red: 0.9843137255, green: 0.6862745098, blue: 0, alpha: 1), progress: progress)
        }
        .animation(animation, value: progress)
        .onAppear { progress = 1 }
    }

    /// A repeating spring animation used to animate all subviews.
    var animation: Animation {
        .spring(duration: 1).repeatForever()
    }
}

// MARK: - MyGroup

/// A custom layout container that arranges views into a flexible grid.
///
/// - Parameters:
///   - numberOfColumns: Number of columns in the grid layout.
///   - content: The content views to be laid out.
private struct MyGroup<Content: View>: View {
    var numberOfColumns: Int
    var content: () -> Content

    init(numberOfColumns: Int = 2, @ViewBuilder content: @escaping () -> Content) {
        self.numberOfColumns = numberOfColumns
        self.content = content
    }

    var body: some View {
        Group(subviews: content()) { subviews in
            VStack(spacing: 0) {
                let (q, r) = subviews.count.quotientAndRemainder(dividingBy: numberOfColumns)
                let rows = Array(repeating: numberOfColumns, count: q) + (r == 0 ? [] : [r])
                ForEach(0 ..< rows.count, id: \.self) { i in
                    HStack(spacing: 0) {
                        Group {
                            ForEach(0 ..< rows[i], id: \.self) { j in
                                subviews[numberOfColumns * i + j]
                            }
                            ForEach(0 ..< (numberOfColumns - rows[i]), id: \.self) { _ in
                                Color.clear
                            }
                        }
                        .padding()
                        .scaledToFit()
                    }
                }
            }
        }
    }
}

// MARK: - SubContentView

/// A protocol for animated subviews that conform to both `View` and `Animatable`.
///
/// Provides a unified `progress` value that drives the animation state.
protocol SubContentView: View, Animatable {
    nonisolated var progress: Double { get set }
    nonisolated var animatableData: Double { get set }
    init(color1: Color, color2: Color, progress: Double)
}

extension SubContentView {
    nonisolated var animatableData: Double {
        get { progress }
        set { progress = min(max(newValue, 0), 1) }
    }

    init(_ color1: UIColor, _ color2: UIColor, progress: Double) {
        self.init(color1: Color(uiColor: color1), color2: Color(uiColor: color2), progress: progress)
    }
}

extension Motions4Screen {
    // MARK: - Content01

    /// A view that demonstrates three simple geometric animations:
    /// - A rectangle that slides vertically from the top
    /// - A rectangle that slides horizontally from the left
    /// - A rounded rectangle that animates both corner radius and padding
    ///
    /// All animations are driven by the `progress` value (from 0 to 1).
    struct Content01: SubContentView {
        var color1, color2: Color
        var progress: Double

        var body: some View {
            GeometryReader { geometry in
                // Get the size of the current view's container.
                let (width, height) = (geometry.size.width, geometry.size.height)

                // Compute a base radius based on the smaller dimension.
                let radius = min(width, height) / 4

                // First rectangle: slides vertically downward as `progress` increases.
                Rectangle()
                    .frame(height: height / 2)
                    .offset(y: progress * height / 2)
                    .foregroundStyle(color1)

                // Second rectangle: slides horizontally to the right.
                Rectangle()
                    .frame(width: width / 2)
                    .offset(x: progress * width / 2)
                    .foregroundStyle(color2)

                // Rounded rectangle: animates corner radius and padding.
                RoundedRectangle(cornerRadius: progress * radius)
                    .foregroundStyle(color1)
                    .padding(.all, progress * radius / 2)
                    .frame(width: 2 * radius, height: 2 * radius)
                    .offset(x: width / 2, y: height / 2)
            }
        }
    }

    // MARK: - Content02

    /// A view that animates three rectangles in distinct ways:
    /// - A center rectangle rotates 180 degrees
    /// - A bottom rectangle slides vertically upward
    /// - A top-right rectangle slides diagonally downward
    ///
    /// These animations create a dynamic, criss-crossing visual using rotation and movement.
    struct Content02: SubContentView {
        var color1, color2: Color
        var progress: Double

        var body: some View {
            GeometryReader { geometry in
                // Get width and height of the view's container.
                let (width, height) = (geometry.size.width, geometry.size.height)

                // Rotating rectangle in the center.
                Rectangle()
                    .rotationEffect(.radians(progress * .pi))
                    .frame(width: width / 3, height: height / 3)
                    .offset(x: width / 3, y: height / 3)
                    .foregroundStyle(color2)

                // Bottom rectangle: slides upward as progress increases.
                Rectangle()
                    .frame(width: width / 3, height: height / 3)
                    .offset(y: (1 - progress) * (2.0 / 3.0) * height)
                    .foregroundStyle(color1)

                // Top-right rectangle: slides diagonally downward.
                Rectangle()
                    .frame(width: width / 3, height: height / 3)
                    .offset(x: (2.0 / 3.0) * width, y: progress * (2.0 / 3.0) * height)
                    .foregroundStyle(color1)
            }
        }
    }

    // MARK: - Content03

    /// A view that demonstrates complex affine transformations:
    /// - A slanted rectangle that rotates and scales from the top-left corner
    /// - Two trapezoidal shapes constructed via multiple transforms
    ///   (including shear, flip, and mirror) that slide upward
    ///
    /// This example shows how to use CGAffineTransform to achieve custom shape deformations.
    struct Content03: SubContentView {
        var color1, color2: Color
        var progress: Double

        var body: some View {
            GeometryReader { geometry in
                let (width, height) = (geometry.size.width, geometry.size.height)

                // Compute vertical offset to align transformed shapes visually.
                let offset = (height / 2) - tan(.pi / 8) * (width / 2)

                // Slanted rectangle using rotation + scale + shear.
                Rectangle()
                    .transformEffect(CGAffineTransform(a: 1, b: 0, c: cos(.pi / 4), d: sin(.pi / 4), tx: 0, ty: 0))
                    .rotationEffect(.radians(-.pi / 8), anchor: .topLeading)
                    .scaleEffect(1 / (2 * cos(.pi / 8)), anchor: .topLeading)
                    .offset(y: offset + ((1 - progress) * (height / 2)))
                    .foregroundStyle(color1)

                // First flipped trapezoid sliding upward.
                Rectangle()
                    // skew x
                    .transformEffect(CGAffineTransform(a: 1, b: 0, c: tan(.pi / 8), d: 1, tx: 0, ty: 0))
                    // flip diagonally
                    .transformEffect(CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0))
                    .frame(width: progress * width / 2, height: height / 2)
                    .offset(y: offset + ((1 - progress) * (height / 2)))
                    .foregroundStyle(color2)

                // Second mirrored trapezoid sliding upward on the right.
                Rectangle()
                    // skew x
                    .transformEffect(CGAffineTransform(a: 1, b: 0, c: tan(.pi / 8), d: 1, tx: 0, ty: 0))
                    // flip diagonally
                    .transformEffect(CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0))
                    // mirror horizontally
                    .transformEffect(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: 0, ty: 0))
                    .frame(width: progress * width / 2, height: height / 2)
                    .offset(x: width, y: offset + ((1 - progress) * (height / 2)))
                    .foregroundStyle(color2)
            }
        }
    }

    // MARK: - Content04

    /// A view that builds a symmetrical motion using arcs and circles:
    /// - The left and right halves each draw a semi-circular arc and a moving circle
    /// - As `progress` increases, the arcs expand outward and the circles move diagonally
    ///
    /// This creates a flower-like blooming animation with two mirrored sides.
    struct Content04: SubContentView {
        var color1, color2: Color
        var progress: Double

        var body: some View {
            GeometryReader { geometry in
                let (width, height) = (geometry.size.width, geometry.size.height)

                Group {
                    // Left arc and circle moving up and left.
                    Path { path in
                        path.addArc(
                            center: CGPoint(x: width / 2 - progress * width / 4, y: height / 2),
                            radius: width / 4,
                            startAngle: .radians(.pi),
                            endAngle: .radians(0),
                            clockwise: false
                        )
                        path.closeSubpath()
                    }

                    Circle()
                        .frame(width: progress * width / 4, height: progress * height / 4)
                        .offset(x: progress * width / 4, y: progress * -height / 4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .foregroundStyle(color1)

                Group {
                    // Right arc and circle moving down and right.
                    Path { path in
                        path.addArc(
                            center: CGPoint(x: width / 2 + progress * width / 4, y: height / 2),
                            radius: width / 4,
                            startAngle: .radians(0),
                            endAngle: .radians(.pi),
                            clockwise: false
                        )
                        path.closeSubpath()
                    }

                    Circle()
                        .frame(width: progress * width / 4, height: progress * height / 4)
                        .offset(x: progress * -width / 4, y: progress * height / 4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .foregroundStyle(color2)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Motions4Screen()
}

#elseif os(macOS)
@Metadata(title: "4 motions", description: "4 motions", tags: [.animation])
struct Motions4Screen: View {
    var body: some View {
        Text("This feature is not available on macOS")
            .foregroundStyle(.secondary)
    }
}
#endif
