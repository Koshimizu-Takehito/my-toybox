import SwiftUI

extension StrokeModifierDemoScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Image(systemName: "swift")
            .resizable()
            .scaledToFit()
            .foregroundStyle(
                .linearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
            )
            .padding(1 * 3 * 2)
            .stroke(.white, width: 1)
            .stroke(.cyan, width: 1)
            .stroke(.blue, width: 1)
            .padding(2)
            .drawingGroup()
    }
}

// MARK: - Preview

#Preview {
    StrokeModifierDemoScreen.thumbnail
}
