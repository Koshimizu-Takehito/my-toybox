import SwiftUI

// MARK: - BadgeDemoScreen

/// A playground‑style screen that showcases `BadgeView` along with
/// interactive controls for both value and appearance.
@Metadata(title: "Badge", description: "Badge Shape Demo", tags: [.animation])
struct BadgeDemoScreen: View {
    /// The observable model that drives the badge.
    @State private var model = BadgeModel(number: -1)

    var body: some View {
        VStack {
            BadgeView(value: model.value)
                .modifier(BadgeStyleModifier(style: model.style))
                .frame(maxHeight: .infinity)
            BadgeControl(model: model)
        }
        .padding()
        .onAppear {
            model.number = 0
        }
    }
}

// MARK: - BadgeView

/// Displays the provided value inside a capsule‑shaped badge.
struct BadgeView<Value>: View {
    // The value displayed inside the badge; `nil` hides the badge.
    var value: Value?

    @State private var labelSize: CGSize = .zero
    @State private var badgeSize: CGSize = .zero

    var body: some View {
        ZStack {
            if let value = value.map(String.init(describing:)) {
                Text(value)
            }
        }
        .monospacedDigit()
        .fixedSize()
        .onGeometryChange(for: CGSize.self, of: \.size) {
            // Capture the text size
            labelSize = $0
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .onGeometryChange(for: CGSize.self, of: \.size) {
            // Capture the badge size *after* padding
            badgeSize = $0
        }
        .frame(width: badgeWidth, height: badgeHeight)
        .background(.tint)
        .clipShape(.capsule)
        .animation(.default, value: labelSize)
        .animation(.default, value: badgeSize)
    }

    /// Ensures `width ≥ height` so the capsule never pinches horizontally.
    private var badgeWidth: CGFloat { max(badgeSize.width, badgeSize.height) }
    private var badgeHeight: CGFloat { badgeSize.height }

    private var verticalPadding: CGFloat { 0.2 * labelSize.height }
    private var horizontalPadding: CGFloat { 0.4 * labelSize.height }
}

// MARK: - BadgeStyleModifier

/// Applies a `BadgeStyle` to any view, allowing reuse across the app.
struct BadgeStyleModifier: ViewModifier {
    var style: BadgeStyle

    func body(content: Content) -> some View {
        content
            .tint(style.tint)
            .font(style.font)
            .fontWeight(style.weight)
            .foregroundStyle(.white)
    }
}

// MARK: - BadgeControl

/// Hosts both the style selectors and the numeric controls.
private struct BadgeControl: View {
    @Bindable var model: BadgeModel

    var body: some View {
        VStack {
            Group {
                BadgeStyleControl(model: model)
                BadgeValueControl(model: model)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}

// MARK: - BadgeStyleControl

/// Lets the user tweak font, weight, and tint of the badge.
private struct BadgeStyleControl: View {
    @Bindable var model: BadgeModel

    var body: some View {
        VStack {
            Picker("Font", selection: $model.style.font.animation()) {
                Text("Large").tag(Font.largeTitle)
                Text("Title").tag(Font.title)
                Text("Body").tag(Font.body)
                Text("Caption").tag(Font.caption)
            }

            Picker("Font Weight", selection: $model.style.weight.animation()) {
                Text("Black").tag(Font.Weight.black)
                Text("Bold").tag(Font.Weight.bold)
                Text("Regular").tag(Font.Weight.regular)
                Text("Ultra‑Light").tag(Font.Weight.ultraLight)
            }

            Picker("Tint", selection: $model.style.tint.animation()) {
                Text("Red").tag(Color.red)
                Text("Blue").tag(Color.blue)
                Text("Yellow").tag(Color.yellow)
                Text("Purple").tag(Color.purple)
            }

            Button("Reset") {
                withAnimation { model.style.reset() }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top)
        }
    }
}

// MARK: - BadgeValueControl

/// Provides a stepper and slider to mutate the badge’s numeric value.
private struct BadgeValueControl: View {
    @Bindable var model: BadgeModel

    var body: some View {
        VStack {
            Stepper("Count \(model.number)", value: $model.number, in: -1 ... 1000)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Slider(value: $model.slider, in: -1 ... 1000)

            Button("Reset") {
                withAnimation { model.number = 0 }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    BadgeDemoScreen()
}
