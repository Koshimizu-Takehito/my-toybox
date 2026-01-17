import SwiftUI

// MARK: - WavingTextScreen

@Metadata(title: "Waving Text", description: "Waving Text", tags: [.animation])
struct WavingTextScreen: View {
    var body: some View {
        WavingText()
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hue: 220 / 360, saturation: 0.3, brightness: 0.9))
    }
}

// MARK: - WavingText

struct WavingText: View {
    var fullText = "Now Loading ..."
    @State private var progress: Double = 0

    var body: some View {
        HStack(spacing: 0) {
            let count = Double(fullText.count)
            ForEach(Array(fullText.enumerated()), id: \.offset) { pair in
                let delay = Double(pair.offset) / count
                let offset = 3 * (progress - 0.5) * 50
                Text(String(pair.element))
                    .offset(y: offset)
                    .animation(animation?.delay(delay), value: progress)
            }
        }
        .font(.system(size: 40, weight: .bold))
        .clipped()
        .task { await repeatAnimation() }
    }

    var animation: Animation? {
        if progress == 1 {
            Animation.timingCurve(0, 1.13, 1, -0.13, duration: 3.0)
        } else {
            Animation?.none
        }
    }

    func repeatAnimation() async {
        progress = 1
        try? await Task.sleep(for: .seconds(3.6))
        Task {
            progress = 0
            Task {
                await repeatAnimation()
            }
        }
    }
}

#Preview {
    WavingTextScreen()
}
