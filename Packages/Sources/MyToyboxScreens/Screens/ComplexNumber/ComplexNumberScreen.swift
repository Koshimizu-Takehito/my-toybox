import SwiftUI

// MARK: - ComplexNumberScreen

@Metadata(title: .screenComplexNumberTitle, description: .screenComplexNumberDescription, tags: [.metal, .animation])
struct ComplexNumberScreen: View {
    @State private var selection: ComplexFunction = .zSquared
    @State private var shaderMode: ShaderMode = .domainColoring

    var body: some View {
        ComplexShaderView(shaderMode: shaderMode, functionIndex: selection.rawValue)
            .backgroundExtensionEffect()
            .overlay(content: picker)
            .toolbar(content: menu)
    }

    @ViewBuilder
    private func picker() -> some View {
        Picker(selection: $selection.animation()) {
            ForEach(ComplexFunction.allCases) { function in
                Text(function.label)
                    .tag(function)
            }
        } label: {
            Text(verbatim: "f(z)")
        }
        .pickerStyle(.segmented)
        .colorScheme(.light)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding()
    }

    @ToolbarContentBuilder
    private func menu() -> some ToolbarContent {
        ToolbarItem {
            Menu {
                ForEach(ShaderMode.allCases) { mode in
                    Button {
                        shaderMode = mode
                    } label: {
                        if mode == shaderMode {
                            Label(mode.label, systemImage: "checkmark")
                        } else {
                            Text(mode.label)
                        }
                    }
                }
            } label: {
                Image(systemName: "paintpalette")
            }
        }
    }
}

// MARK: - ComplexShaderView

@Animatable
private struct ComplexShaderView: View, Animatable {
    @AnimatableIgnored var shaderMode: ShaderMode
    var functionIndex: Double

    var body: some View {
        Rectangle()
            .colorEffect(function(.boundingRect, .float(functionIndex)))
    }

    var function: ShaderFunction {
        ShaderFunction(library: .module, name: shaderMode.shaderName)
    }
}

// MARK: - ShaderMode

private enum ShaderMode: String, CaseIterable, Identifiable {
    case domainColoring
    case gridTransform

    var id: String { rawValue }

    var label: String {
        switch self {
        case .domainColoring: "Domain Coloring"
        case .gridTransform: "Grid Transform"
        }
    }

    var shaderName: String {
        switch self {
        case .domainColoring: "ComplexNumber::main"
        case .gridTransform: "ComplexTransform::main"
        }
    }
}

// MARK: - ComplexNumberScreen.ComplexFunction

extension ComplexNumberScreen {
    enum ComplexFunction: Double, CaseIterable, Identifiable {
        case zSquared = 0
        case oneOverOnePlusZ = 1
        case zCubedMinusOne = 2
        case sinZ = 3
        case expZ = 4
        case zSquaredPlusC = 5

        var id: Double { rawValue }

        var label: String {
            switch self {
            case .zSquared: "z²"
            case .oneOverOnePlusZ: "1/(1+z)"
            case .zCubedMinusOne: "z³-1"
            case .sinZ: "sin(z)"
            case .expZ: "exp(z)"
            case .zSquaredPlusC: "z²+c"
            }
        }
    }
}

#Preview {
    NavigationStack {
        ComplexNumberScreen()
    }
}
