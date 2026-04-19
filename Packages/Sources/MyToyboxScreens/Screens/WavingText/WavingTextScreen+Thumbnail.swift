import SwiftUI

extension WavingTextScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Text("Loading...")
                .minimumScaleFactor(0.1)
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(0.1 * geometry.size.width)
                .background(Color(hue: 220 / 360, saturation: 0.5, brightness: 0.9).gradient)
        }
    }
}

#Preview {
    WavingTextScreen.thumbnail
}
