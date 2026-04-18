import SwiftUI

extension ScrollYRotationScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        let rowCount = 8
        let rows = [Color].scrollYRotationRainbow(count: rowCount).enumerated().map(\.self)
        GeometryReader { geometry in
            let size = geometry.size.height
            let frame = geometry.frame(in: .local)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(rows, id: \.offset) { row in
                        ScrollYRotationRow(containerFrame: frame) { _ in
                            row.element
                                .frame(height: 0.1 * size)
                                .padding(0.01 * size)
                                .padding(.horizontal, 0.08 * size)
                        }
                    }
                }
            }
            .scrollDisabled(true)
            .padding(0.05 * size)
        }
    }
}

#Preview {
    ScrollYRotationScreen.thumbnail
        .frame(width: 50, height: 50)
}
