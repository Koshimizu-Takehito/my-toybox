import SwiftUI

extension RippleScreen {
    @ViewBuilder
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> some View {
        let trigger = Int((time / 2.0).truncatingRemainder(dividingBy: 10.0))

        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            Color.clear.overlay {
                Image("waterwheel", bundle: .module)
                    .resizable()
                    .scaledToFill()
                    .modifier(
                        RippleEffect(at: center, trigger: trigger)
                            .isEnabled(!isScrolling)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scaledToFit()
        .clipped()
    }
}

extension ViewModifier {
    func isEnabled(_ isEnabled: Bool) -> some ViewModifier {
        IsEnabledModifier(isEnabled: isEnabled, modifier: self)
    }
}

// MARK: - IsEnabledModifier

private struct IsEnabledModifier<M: ViewModifier>: ViewModifier {
    var isEnabled: Bool
    var modifier: M

    func body(content: Content) -> some View {
        if isEnabled {
            content.modifier(modifier)
        } else {
            content
        }
    }
}

// MARK: - Preview

#Preview {
    RippleScreen.thumbnail
        .backgroundExtensionEffect()
}
