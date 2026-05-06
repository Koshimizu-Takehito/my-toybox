import MyToyboxCore
import SwiftUI

public extension ComplexNumberScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        let function = ShaderFunction(library: .screenModule, name: "ComplexNumber::thumbnail")
        Rectangle()
            .colorEffect(function(.boundingRect))
    }
}

// MARK: - Preview

#Preview {
    ComplexNumberScreen.thumbnail
        .backgroundExtensionEffect()
}
