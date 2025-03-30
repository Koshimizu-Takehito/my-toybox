import SwiftUI

/// A screen that displays a randomly changing color inside a circle,
/// showing its hexadecimal color code in the center.
/// The color smoothly transitions every ~1.8 seconds.
struct ColorHexAnimationScreen: View {
    /// The currently displayed color.
    @State private var currentColor: Color = .random
    /// The timestamp of the last color change.
    @State private var lastColorChangeDate: Date = .now

    @Environment(\.self) var environment

    var body: some View {
        // TimelineView(.animation) provides a time-based update mechanism
        TimelineView(.animation) { context in
            let date = context.date
            ColorCircleView(color: currentColor, environment: environment)
                .animation(.linear(duration: 1), value: currentColor)
                .ignoresSafeArea()
                .onChange(of: date, initial: true) { _, date in
                    // If 1.8 seconds have passed, update the color
                    if date.timeIntervalSince(lastColorChangeDate) > 1.8 {
                        lastColorChangeDate = date
                        currentColor = .random
                    }
                }
        }
    }
}

/// A view that draws a circle filled with a given color and displays its hex code in the center.
/// It supports animating color transitions by implementing `Animatable`.
private struct ColorCircleView: Animatable {
    /// The color to display and animate.
    var color: Color
    var environment: EnvironmentValues

    // Animate by interpolating the resolved color's components
    var animatableData: Color.Resolved.AnimatableData {
        get {
            color.resolve(in: environment).animatableData
        }
        set(value) {
            var resolved = color.resolve(in: environment)
            resolved.animatableData = value
            color = Color(resolved)
        }
    }
}

extension ColorCircleView: View {
    var body: some View {
        ZStack {
            // Background circle with the current color
            color
                .clipShape(.circle)
                .padding()
                .padding()

            // Foreground hex color label
            Text(description)
                .font(.largeTitle)
                .bold()
                .monospaced()
                .contentTransition(.numericText(countsDown: true))
                .animation(.default, value: color)
                .foregroundStyle(textColor)
        }
    }

    /// Converts the current resolved color into a `#RRGGBB` uppercase hex string.
    var description: String {
        func value(_ v: Color.Resolved, _ k: KeyPath<Color.Resolved, Float>) -> String {
            let value = min(max(Int(v[keyPath: k] * Float(UInt8.max)), 0), 255)
            return String(format: "%02x", value).uppercased()
        }
        let resolved = color.resolve(in: environment)
        let red = value(resolved, \.red)
        let green = value(resolved, \.green)
        let blue = value(resolved, \.blue)
        return "#\(red)\(green)\(blue)"
    }

    /// Dynamically chooses black or white text depending on background luminance for better readability.
    var textColor: some ShapeStyle {
        let color = color.resolve(in: environment)
        let luminance = 0.299 * color.red + 0.587 * color.green + 0.114 * color.blue
        return luminance > 0.5 ? .black : .white
    }
}

/// Provides a convenient way to generate bright, saturated random colors.
private extension Color {
    static var random: Self {
        Color(
            hue: .random(in: 0..<1),
            saturation: .random(in: 0.9..<1),
            brightness: .random(in: 0.9..<1)
        )
    }
}

/// Preview for SwiftUI canvas
#Preview {
    ColorHexAnimationScreen()
}
