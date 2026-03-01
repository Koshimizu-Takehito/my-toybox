import SwiftUI

// MARK: - ComplexNumberScreen

@Metadata(title: "Complex Number", description: "複素関数のドメインカラーリング", tags: [.metal])
struct ComplexNumberScreen: View {
    @State private var selection: ComplexFunction = .zSquared

    var body: some View {
        ZStack {
            Rectangle()
                .colorEffect(shader)
                .ignoresSafeArea()

            VStack {
                Spacer()
                picker
            }
            .padding()
        }
    }

    private var shader: Shader {
        ShaderFunction(library: .module, name: "ComplexNumber::main")(
            .boundingRect,
            .float(Float(selection.rawValue))
        )
    }

    private var picker: some View {
        Picker("f(z)", selection: $selection) {
            ForEach(ComplexFunction.allCases) { function in
                Text(function.label)
                    .tag(function)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - ComplexFunction

extension ComplexNumberScreen {
    enum ComplexFunction: Int, CaseIterable, Identifiable {
        case zSquared = 0
        case oneOverOnePlusZ = 1
        case zCubedMinusOne = 2
        case sinZ = 3
        case expZ = 4
        case zSquaredPlusC = 5

        var id: Int { rawValue }

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
