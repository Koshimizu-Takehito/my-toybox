import MyToyboxCore
import SwiftUI

public extension ColorSegmentedControlDemoScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            Text(verbatim: "Apple")
                .foregroundStyle(.white)
                .fixedSize()
                .font(.system(size: 0.2 * size, weight: .semibold))
                .padding(.vertical, 0.05 * size)
                .padding(.horizontal, 0.1 * size)
                .background(.red, in: .capsule)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(.red.opacity(0.2).gradient)
        .background(.white)
        .scaledToFit()
    }
}

// MARK: - Preview

#Preview {
    ColorSegmentedControlDemoScreen.thumbnail
}
