import SwiftUI

// MARK: - GameOfLifeScreen

/// Conway のライフゲーム画面（メタル描画 + コントロール）。
@Metadata(title: .screenGameOfLifeTitle, description: .screenGameOfLifeDescription, tags: [.animation, .metal])
struct GameOfLifeScreen: View {
    @State private var viewModel = GameOfLifeViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text(verbatim: "Number of Cycles: \(viewModel.numberOfCycles)")
                .font(.headline)
                .foregroundStyle(.secondary)

            GeometryReader { geometry in
                // Metal 描画
                MetalGameOfLifeView(viewModel: viewModel)
                    .animation(.default, value: viewModel.scale)
                    .scaledToFit()
                    .overlay(alignment: .topLeading) {
                        // デバッグ表示
                        HStack(spacing: 12) {
                            Text(verbatim: "Size: \(viewModel.size)×\(viewModel.size)")
                            Text(verbatim: "Interval: \(Int(viewModel.cycleIntervalMS)) ms")
                            Text(verbatim: viewModel.isRunning ? "Running" : "Stopped")
                        }
                        .monospaced()
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(8)
                        .background(.thinMaterial, in: .rect(cornerRadius: 8))
                        .padding(8)
                    }
                    .simultaneousGesture(magnifyGesture)
                    .simultaneousGesture(panGesture(size: geometry.size))
            }
            .scaledToFit()

            // 操作パネル
            controls
                .padding()
        }
        .monospacedDigit()
        .navigationTitle(Text(verbatim: "Conway's Game of Life"))
        .toolbar(content: toolbar)
        .toolbarTitleDisplayMode(.inlineLarge)
        .tint(.blue)
    }

    // MARK: Gestures (継続点を考慮)

    /// ピンチズーム用ジェスチャ（継続点: `lastScale`）。
    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                // 継続点: lastScale * magnification
                viewModel.scale = max(1.0, viewModel.lastScale * value.magnification)
                viewModel.clampLocation()
            }
            .onEnded { _ in
                viewModel.lastScale = viewModel.scale
            }
    }

    /// ドラッグ（パン）用ジェスチャ（継続点: `lastLocation`）。
    /// - Parameter size: ジオメトリ（ピクセル幅・高さ）。
    private func panGesture(size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let s = max(1.0, viewModel.scale)
                let dx = (value.translation.width / size.width) / s
                let dy = (value.translation.height / size.height) / s
                viewModel.location = CGPoint(
                    x: viewModel.lastLocation.x + dx,
                    y: viewModel.lastLocation.y - dy
                )
                viewModel.clampLocation()
            }
            .onEnded { _ in
                viewModel.lastLocation = viewModel.location
            }
    }

    // MARK: Controls

    /// 操作パネルビュー。
    @ViewBuilder
    private var controls: some View {
        VStack(spacing: 12) {
            Picker(selection: $viewModel.size) {
                ForEach([64, 128, 256, 512, 1024], id: \.self) { n in
                    Text(verbatim: "\(n)").tag(n)
                }
            } label: {
                Text(verbatim: "Grid Size")
            }
            .disabled(viewModel.isRunning)

            Slider(value: $viewModel.cycleIntervalMS, in: 3 ... 100, step: 1)

            HStack(spacing: 16) {
                Button {
                    viewModel.isRunning = true
                } label: {
                    Label {
                        Text(verbatim: "Start")
                    } icon: {
                        Image(systemName: "play.fill")
                    }
                }
                .disabled(viewModel.isRunning)

                Button {
                    viewModel.isRunning = false
                } label: {
                    Label {
                        Text(verbatim: "Stop")
                    } icon: {
                        Image(systemName: "pause.fill")
                    }
                }
                .disabled(!viewModel.isRunning)

                Button {
                    viewModel.isRunning = false
                    viewModel.resetStats()
                    viewModel.resetView()
                    let s = viewModel.size // 再初期化
                    viewModel.size = s
                } label: {
                    Label {
                        Text(verbatim: "Reset")
                    } icon: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
        }
        .pickerStyle(.segmented)
        .buttonStyle(.borderedProminent)
        .font(.body.weight(.semibold))
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        #if os(iOS) || os(tvOS)
        let placement: ToolbarItemPlacement = .bottomBar
        #elseif os(macOS)
        let placement: ToolbarItemPlacement = .automatic
        #endif
        // ズーム用コントロール
        ToolbarItemGroup(placement: placement) {
            Button {
                viewModel.decrementScale()
            } label: {
                Image(systemName: "minus.magnifyingglass")
            }
            .disabled(viewModel.scale == 1)

            Button {
                viewModel.resetView()
            } label: {
                Image(systemName: "1.magnifyingglass")
            }
            .disabled(viewModel.scale == 1)

            Button {
                viewModel.incrementScale()
            } label: {
                Image(systemName: "plus.magnifyingglass")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GameOfLifeScreen()
    }
    .colorScheme(.dark)
}
