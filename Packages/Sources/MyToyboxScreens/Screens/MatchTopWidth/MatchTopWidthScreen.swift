import SwiftUI

// MARK: - MatchTopWidthScreen

/// A screen that visually demonstrates how `.frame(maxWidth: .infinity)`
/// and `.fixedSize()` affect layout behavior in SwiftUI.
///
/// Users can toggle these modifiers and observe how they affect
/// the width of components in a stacked layout.
struct MatchTopWidthScreen: View {
    // Whether to apply `.frame(maxWidth: .infinity)` to a label in the layout.
    @State private var isInfinityWidth = false

    // Whether to apply `.fixedSize()` to the vertical stack.
    @State private var isFixedSize = false

    var body: some View {
        Form {
            Section {
                Toggle("maxWidth: .infinity", isOn: $isInfinityWidth.animation())
                Toggle("fixedSize", isOn: $isFixedSize.animation())
            }

            Section {
                Sample(isInfinityWidth: isInfinityWidth, isFixedSize: isFixedSize)
                    .backgroundStyle(gradientStyle)
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            }
        }
        .tint(.blue)
    }

    /// Returns a dynamic gradient background that changes depending on layout flags.
    var gradientStyle: some ShapeStyle {
        .linearGradient(
            colors: [
                isInfinityWidth ? blue : isFixedSize ? purple : .gray,
                isFixedSize ? purple : isInfinityWidth ? blue : .gray,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// A bright blue used when `.infinity` is active.
    var blue: Color {
        Color(hue: 207 / 360, saturation: 0.88, brightness: 0.88)
    }

    /// A vivid purple used when `.fixedSize` is active.
    var purple: Color {
        Color(hue: 302 / 360, saturation: 1.00, brightness: 1.00)
    }
}

// MARK: - Sample

/// A view that demonstrates how layout modifiers affect width alignment.
///
/// It contains two major rows:
/// - The top row is a `HStack` with logos and labels, always using `.fixedSize()`
/// - The bottom row is a label whose width is optionally expanded using `.frame(maxWidth: .infinity)`
private struct Sample: View {
    let isInfinityWidth: Bool
    let isFixedSize: Bool

    var body: some View {
        VStack {
            HStack {
                Group {
                    Label("PS", systemImage: "playstation.logo")
                    Label("XBox", systemImage: "xbox.logo")
                    Image(systemName: "gamecontroller.fill")
                }
                .frame(maxHeight: .infinity)
                .modifier(MyStyle())
            }
            .fixedSize()

            Label("message", systemImage: "message.badge.filled.fill")
                .frame(maxWidth: isInfinityWidth ? .infinity : nil)
                .modifier(MyStyle())
        }
        .fontWeight(.bold)
        .fixedSize(horizontal: isFixedSize, vertical: true)
        .border(.red, width: 1)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - MyStyle

/// A simple style used to apply consistent padding, background, and text color to content.
private struct MyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.background, in: .capsule)
            .foregroundStyle(.white)
    }
}

// MARK: - Preview

#Preview {
    MatchTopWidthScreen()
}
