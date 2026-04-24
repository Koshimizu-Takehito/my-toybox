import SwiftUI

// MARK: - BadgeDemoScreen

/// A playground‑style screen that showcases `BadgeView` along with
/// interactive controls for both value and appearance.
@Metadata(title: .screenBadgeDemoTitle, description: .screenBadgeDemoDescription, tags: [.animation])
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
            Picker(selection: $model.style.font.animation()) {
                Text(verbatim: "Large").tag(Font.largeTitle)
                Text(verbatim: "Title").tag(Font.title)
                Text(verbatim: "Body").tag(Font.body)
                Text(verbatim: "Caption").tag(Font.caption)
            } label: {
                Text(verbatim: "Font")
            }

            Picker(selection: $model.style.weight.animation()) {
                Text(verbatim: "Black").tag(Font.Weight.black)
                Text(verbatim: "Bold").tag(Font.Weight.bold)
                Text(verbatim: "Regular").tag(Font.Weight.regular)
                Text(verbatim: "Ultra‑Light").tag(Font.Weight.ultraLight)
            } label: {
                Text(verbatim: "Font Weight")
            }

            Picker(selection: $model.style.tint.animation()) {
                Text(verbatim: "Red").tag(Color.red)
                Text(verbatim: "Blue").tag(Color.blue)
                Text(verbatim: "Yellow").tag(Color.yellow)
                Text(verbatim: "Purple").tag(Color.purple)
            } label: {
                Text(verbatim: "Tint")
            }

            Button {
                withAnimation { model.style.reset() }
            } label: {
                Text(verbatim: "Reset")
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
            Stepper(value: $model.number, in: -1 ... 1000) {
                Text(verbatim: "Count \(model.number)")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            Slider(value: $model.slider, in: -1 ... 1000)

            Button {
                withAnimation { model.number = 0 }
            } label: {
                Text(verbatim: "Reset")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    BadgeDemoScreen()
}
