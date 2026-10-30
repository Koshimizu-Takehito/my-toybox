import MyToyboxCore
import MyToyboxMedia
import Observation
import SwiftUI

// MARK: - GameBoyMosaicScreen

/// A demo screen that applies a Game Boy DMG–style circular-dot mosaic filter
/// to an image using a custom SwiftUI layer shader backed by Metal.
@Metadata(
    title: .screenGameBoyMosaicTitle,
    description: .screenGameBoyMosaicDescription,
    tags: [.metal]
)
public struct GameBoyMosaicScreen: View {
    public init() {}
    @State private var state = MosaicState()

    public var body: some View {
        VStack {
            Spacer()
            ContentView(state: state) {
                Image("waterwheel", bundle: MyToyboxMedia.bundle)
                    .resizable()
                    .scaledToFit()
            }
            Spacer()
            ControlPanel(state: $state)
        }
        .padding()
    }
}

private struct ContentView<Content: View>: View {
    var state: MosaicState
    var content: () -> Content

    var body: some View {
        VStack {
            Spacer()

            content().gameBoyMosaic(size: state.cellSize, count: state.colorCount)
            Text(verbatim: "Mosaic")

            Spacer()

            content()
            Text(verbatim: "Original")

            Spacer()
        }
        .font(.footnote)
    }
}

@Observable
@MainActor
private final class MosaicState {
    /// Grid cell side length in points. Controls mosaic coarseness.
    var cellSize: Double = 6
    /// Number of palette levels along the DMG green polyline.
    var colorCount: Int = 16

    func reset() {
        cellSize = 6
        colorCount = 16
    }
}

private struct ControlPanel: View {
    @Binding var state: MosaicState

    var body: some View {
        VStack(alignment: .trailing) {
            Grid(alignment: .leading) {
                GridRow {
                    Text(verbatim: "Size")
                    Slider(value: $state.cellSize.animation(), in: 2...12)
                    ZStack(alignment: .trailing) {
                        Text(verbatim: "\(state.cellSize.formatted(.number.precision(.fractionLength(1))))")
                        Text(verbatim: "999.9")
                            .hidden()
                    }
                }
                GridRow {
                    Text(verbatim: "Color")
                    Stepper(value: $state.colorCount, in: 4...256, label: EmptyView.init)
                        .labelsHidden()
                    ZStack(alignment: .trailing) {
                        Text(verbatim: "\(state.colorCount.formatted())")
                        Text(verbatim: "999.9")
                            .hidden()
                    }
                }
            }
            Button(action: state.reset) {
                Text(verbatim: "Reset")
            }
        }
        .fontDesign(.monospaced)
    }
}

extension View {
    func gameBoyMosaic(size: Double, count: Int) -> some View {
        layerEffect(
            .gameBoyMosaic(size: size, count: count),
            maxSampleOffset: CGSize(width: size, height: size)
        )
        .mask(Rectangle.init)
    }
}

extension Shader {
    /// Builds a SwiftUI `Shader` that invokes `GameBoyMosaic::main`.
    static func gameBoyMosaic(size: Double, count: Int) -> Self {
        let function = ShaderFunction(library: .screenModule, name: "GameBoyMosaic::main")
        return function(
            .float(Float(size)),
            .float(Float(count)),
            .boundingRect
        )
    }
}

#Preview {
    GameBoyMosaicScreen()
}
