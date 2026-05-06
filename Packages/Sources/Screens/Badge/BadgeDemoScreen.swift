import MyToyboxCore
import SwiftUI

// MARK: - BadgeDemoScreen

@Metadata(title: .screenBadgeDemoTitle, description: .screenBadgeDemoDescription, tags: [.animation])
public struct BadgeDemoScreen: View {
    @State private var model = BadgeModel(number: -1)

    public init() {}

    public var body: some View {
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

struct BadgeView<Value>: View {
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
            labelSize = $0
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .onGeometryChange(for: CGSize.self, of: \.size) {
            badgeSize = $0
        }
        .frame(width: badgeWidth, height: badgeHeight)
        .background(.tint)
        .clipShape(.capsule)
        .animation(.default, value: labelSize)
        .animation(.default, value: badgeSize)
    }

    private var badgeWidth: CGFloat { max(badgeSize.width, badgeSize.height) }
    private var badgeHeight: CGFloat { badgeSize.height }
    private var verticalPadding: CGFloat { 0.2 * labelSize.height }
    private var horizontalPadding: CGFloat { 0.4 * labelSize.height }
}

// MARK: - BadgeStyleModifier

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
