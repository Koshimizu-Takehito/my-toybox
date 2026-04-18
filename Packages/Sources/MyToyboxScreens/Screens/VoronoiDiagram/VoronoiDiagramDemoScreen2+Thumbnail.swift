import SwiftUI

extension VoronoiDiagramDemoScreen2 {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Rectangle().colorEffect(.voronoi2(time: 1.0))
    }
}

extension Shader {
    static func voronoi2(time: TimeInterval = 0.0) -> Self {
        let function = ShaderFunction(library: .module, name: "VoronoiDiagramShadeder2::main")
        return function(.boundingRect, .float(time))
    }
}
