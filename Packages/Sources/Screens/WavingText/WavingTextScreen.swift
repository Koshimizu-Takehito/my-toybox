import MyToyboxCore
import SwiftUI

// MARK: - WavingTextScreen

@Metadata(title: .screenWavingTextTitle, description: .screenWavingTextDescription, tags: [.animation])
public struct WavingTextScreen: View {
    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            WavingText()
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Keeps the whole line on screen in narrow columns.
                .font(.system(size: min(40, geometry.size.width / 9), weight: .bold))
        }
        .background(Color(hue: 220 / 360, saturation: 0.3, brightness: 0.9))
    }
}

// MARK: - WavingText

struct WavingText: View {
    @State private var progress: Double = 0

    var body: some View {
        WavingTextSnapshot(fullText: "Now Loading ...", progress: progress)
            .animation(animation, value: progress)
            .onAppear { progress = 1.0 }
    }

    var animation: Animation {
        Animation.timingCurve(0, 1.13, 1, -0.13, duration: 3.0)
            .repeatForever(autoreverses: false)
    }
}

// MARK: - WavingTextSnapshot

struct WavingTextSnapshot: View {
    var fullText: String
    var progress: Double

    var body: some View {
        HStack(spacing: 0) {
            let count = Double(fullText.count)
            ForEach(Array(fullText.enumerated()), id: \.offset) { pair in
                let delay = Double(pair.offset) / count
                let offset = 3 * (progress - 0.5) * 50
                Text(String(pair.element))
                    .offset(y: offset)
                    .transaction { transaction in
                        transaction.animation = transaction.animation?.delay(delay)
                    }
            }
        }
        .clipped()
    }
}

#Preview {
    WavingTextScreen()
}
