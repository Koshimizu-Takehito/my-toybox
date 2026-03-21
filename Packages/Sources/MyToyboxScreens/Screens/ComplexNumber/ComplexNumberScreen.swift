import SwiftUI

// MARK: - ComplexNumberScreen

@Metadata(title: "Complex Number", description: "複素関数の可視化", tags: [.metal, .animation])
struct ComplexNumberScreen: View {
    @State private var selection: ComplexFunction = .zSquared

    var body: some View {
        ComplexNumberShaderView(functionIndex: selection.rawValue)
            .ignoresSafeArea()
            .overlay {
                picker
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding()
            }
    }

    private var picker: some View {
        Picker("f(z)", selection: $selection.animation()) {
            ForEach(ComplexFunction.allCases) { function in
                Text(function.label).tag(function)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - ComplexNumberShaderView

@Animatable
private struct ComplexNumberShaderView: View, Animatable {
    var functionIndex: Double

    var body: some View {
        Rectangle()
            .colorEffect(function(.boundingRect, .float(functionIndex)))
    }

    var function: ShaderFunction {
        ShaderFunction(library: .module, name: "ComplexNumber::main")
    }
}

// MARK: - ComplexFunction

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
    ComplexNumberScreen()
}
