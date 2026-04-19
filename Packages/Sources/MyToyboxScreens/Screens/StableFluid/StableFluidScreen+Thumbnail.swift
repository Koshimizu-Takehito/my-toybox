import SwiftUI

extension StableFluidScreen {
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> some View {
        GeometryReader { geometry in
            Thumbnail(isScrolling: isScrolling, time: time, size: geometry.size.width)
        }
    }

    struct Thumbnail: View {
        @State private var viewModel = StableFluidViewModel(imageContentMode: .aspectFill)
        var isScrolling: Bool, time: TimeInterval, size: CGFloat

        var body: some View {
            let time = time.truncatingRemainder(dividingBy: 2.0 * .pi)
            MetalStableFluidView(viewModel: viewModel)
                .onChange(of: time) { _, time in
                    let location = CGPoint(x: (size * (1.0 - sin(time))) / 2.0, y: (size * (1.0 - cos(time))) / 2.0)
                    let gridN = Float(viewModel.gridSize)
                    let x = Float(location.x / size) * gridN
                    let y = Float(1.0 - location.y / size) * gridN
                    let newPos = SIMD2(Int32(x), Int32(y))

                    if let lastLoc = viewModel.lastDragLocation {
                        let lastX = Float(lastLoc.x / size) * gridN
                        let lastY = Float(1.0 - lastLoc.y / size) * gridN
                        viewModel.brush.delta = SIMD2<Float>(x - lastX, y - lastY)
                    } else {
                        viewModel.brush.delta = .zero
                    }
                    viewModel.brush.pos = newPos
                    viewModel.brush.isDown = true
                    viewModel.lastDragLocation = location
                }
                .onChange(of: isScrolling) { _, isScrolling in
                    viewModel.paused = isScrolling
                }
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        }
    }
}
