import MyToyboxCore
import SwiftUI

public extension CountdownAnimationScreen {
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            CountdownAnimationView(count: 10 - time.truncatingRemainder(dividingBy: 10))
                .padding(size / 10.0)
        }
    }
}
