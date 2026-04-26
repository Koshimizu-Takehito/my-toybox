import SwiftUI

extension ComplexNumberScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        let function = ShaderFunction(library: .module, name: "ComplexNumber::thumbnail")
        Rectangle()
            .colorEffect(function(.boundingRect))
    }
}

// MARK: - Preview

#Preview {
    RippleScreen.thumbnail
        .backgroundExtensionEffect()
}
