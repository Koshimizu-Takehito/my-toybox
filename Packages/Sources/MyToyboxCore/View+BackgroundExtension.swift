import SwiftUI

public extension View {
    @ViewBuilder
    @_disfavoredOverload
    func backgroundExtensionEffect() -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.SwiftUI::backgroundExtensionEffect()
        } else {
            ignoresSafeArea()
        }
    }
}
