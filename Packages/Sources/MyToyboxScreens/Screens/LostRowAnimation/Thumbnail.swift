import SwiftUI

extension LostRowAnimationScreen {
    @ViewBuilder
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            Thumbnail(size: size, isScrolling: isScrolling, time: time)
        }
    }

    struct Thumbnail: View {
        var size: CGFloat, isScrolling: Bool, time: TimeInterval

        @State private var item: [Color] = .colors
        @State private var show = false
        @State private var refreshID = 0

        var body: some View {
            ScrollView {
                LazyVStack(spacing: 0.04 * size) {
                    ForEach(item.indices, id: \.self) { index in
                        let offset = Double(min(index, 20) + 1)
                        Capsule()
                            .foregroundStyle(item[index].gradient)
                            .offset(y: show ? 0 : offset * 50)
                            .opacity(show ? 1 : 0)
                            .animation(!isScrolling ? .spring(duration: offset * 0.26) : nil, value: show)
                    }
                }
            }
            .contentMargins(0.08 * size, for: .scrollContent)
            .scrollIndicators(.hidden)
            .onChange(of: Int(time / 4.0)) { _, refreshID in
                self.refreshID = refreshID
            }
            .task(id: refreshID) {
                await fetch()
            }
        }

        func fetch() {
            show = false
            Task.detached {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                Task { @MainActor in
                    item = .colors
                    show = true
                }
            }
        }
    }
}

private extension [Color] {
    static let colors: Self = [
        .orange,
        .mint,
        .cyan,
        .purple,
    ]
}
