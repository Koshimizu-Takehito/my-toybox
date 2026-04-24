import SwiftUI

extension FlipTransitionDemoScreen {
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> Thumbnail {
        Thumbnail(isScrolling: isScrolling, time: time)
    }

    struct Thumbnail: View {
        var isScrolling: Bool, time: TimeInterval

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    if isFlipped {
                        Text(verbatim: "こんにちは!")
                            .transition(.flip)
                    } else {
                        Text(verbatim: "Hello!")
                            .transition(.flip)
                    }
                }
                .font(.system(size: 0.16 * geometry.size.width, weight: .bold))
                .lineLimit(1)
                .foregroundStyle(.foreground)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .animation(!isScrolling ? .default : nil, value: isFlipped)
        }

        var isFlipped: Bool {
            Int((time / 2.0).truncatingRemainder(dividingBy: 2.0)) == 0
        }
    }
}

// MARK: - Preview

#Preview {
    FlipTransitionDemoScreen.thumbnail
}
