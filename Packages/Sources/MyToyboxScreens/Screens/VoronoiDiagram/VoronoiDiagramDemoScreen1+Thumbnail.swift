import SwiftUI

extension VoronoiDiagramDemoScreen1 {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Rectangle().colorEffect(.voronoi1(time: 1.0))
    }
}

extension Shader {
    static func voronoi1(time: TimeInterval = 0.0) -> Self {
        let function = ShaderFunction(library: .module, name: "VoronoiDiagramShadeder1::main")
        return function(.boundingRect, .float(time))
    }
}
