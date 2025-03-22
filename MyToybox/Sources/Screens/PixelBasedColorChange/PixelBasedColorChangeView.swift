import SwiftUI

#if os(macOS)
struct PixelBasedColorChangeView: View {
    var body: some View {
        EmptyView()
    }
}
#else
struct PixelBasedColorChangeView: View {
    @State private var image = UIImage()
    @State private var buttonRect = CGRect()
    @State private var contentRect = CGRect()
    @State private var isBrightBackground = false
    @State private var viewID = UUID()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    MyScrollView(image: $image)
                    Color.clear
                        .frame(width: 100, height: 200)
                        .overlay {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        }
                }
                .ignoresSafeArea()
                .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                .toolbar(content: button)
                .onChange(of: image, initial: true) { _, image in
                    var buttonRect = buttonRect
                    buttonRect.origin.x -= contentRect.origin.x
                    let (isBright, bounds) = (isBrightBackground, buttonRect)
                    Task.detached {
                        let isBright = image.isBrightArea(in: bounds) ?? isBright
                        Task { @MainActor in
                            self.isBrightBackground = isBright
                        }
                    }
                }
            }
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                contentRect = $0
            }
        }
        .id(viewID)
    }

    func button() -> some View {
        MyButton(isBrightBackground: isBrightBackground) {
            withAnimation {
                viewID = UUID()
            }
        }
        .onGeometryChange(for: CGRect.self) {
            $0.frame(in: .global)
        } action: { buttonRect in
            self.buttonRect = buttonRect
        }
    }
}

private struct MyButton: View {
    var isBrightBackground: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .frame(width: 44)
                .foregroundStyle(.thinMaterial)
                .overlay {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 22.0 / sqrt(2))
                }
        }
        .environment(\.colorScheme, isBrightBackground ? .dark : .light)
    }
}

private struct ItemView: View, Hashable {
    var body: some View {
        Color(
            hue: random,
            saturation: Bool.random() ? random * random : random,
            brightness: 1 - random * random
        )
    }

    var random: Double {
        Double((0..<0xFF).randomElement()!) / Double(0xFF)
    }
}

private struct MyScrollView: View {
    @State private var offset: CGPoint = .zero
    @Binding var image: UIImage

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                ForEach(0..<300, id: \.self) { index in
                    ItemView()
                        .frame(height: 120)
                        .id(index)
                }
            }
        }
        .onScrollGeometryChange(for: CGPoint.self, of: \.contentOffset) {
            offset = $1
        }
        .background {
            UIScrollViewImageRenderer(offset: offset, image: $image)
        }
    }
}

private struct UIScrollViewImageRenderer: UIViewControllerRepresentable {
    var offset: CGPoint = .zero
    @Binding var image: UIImage

    func makeUIViewController(context: Context) -> AnonymousViewController {
        AnonymousViewController()
    }

    func updateUIViewController(_ controller: AnonymousViewController, context: Context) {
        controller.coordinator = context.coordinator
        controller.offset = offset
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(image: $image)
    }

    final class Coordinator: AnyObject {
        @Binding var image: UIImage

        init(image: Binding<UIImage>) {
            _image = image
        }
    }

    final class AnonymousViewController: UIViewController {
        weak var coordinator: Coordinator?
        var offset: CGPoint = .zero {
            didSet {
                if isViewLoaded, oldValue != offset {
                    drawScrollView()
                }
            }
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            drawScrollView()
        }

        func drawScrollView() {
            if let window = view.window, let scrollView: UIScrollView = find(ancestor: window) {
                let bounds = view.bounds
                let offset = scrollView.contentOffset
                let layer = scrollView.layer
                Task.detached {
                    let renderer = UIGraphicsImageRenderer(size: bounds.size)
                    var image = renderer.image { context in
                        context.cgContext.translateBy(x: -offset.x, y: -offset.y)
                        layer.render(in: context.cgContext)
                    }
                    image = image.preparingForDisplay() ?? image
                    Task { @MainActor in
                        self.coordinator?.image = image
                    }
                }
            }
        }

        func find<View: UIView>(ancestor: UIView?) -> View? {
            switch ancestor {
            case nil:
                return nil
            case let target as View:
                return target
            case let target?:
                return target.subviews.lazy.map(find).compactMap(\.self).first
            }
        }
    }
}

extension UIImage {

    /// 指定した矩形領域のピクセルを読み込み、平均輝度を求める
    /// - Parameter cropRect: 切り抜く領域（画像内座標）
    /// - Returns: ピクセルの平均輝度（0.0〜255.0）
    fileprivate func averageLuminance(in cropRect: CGRect) -> Double? {

        // 画像の CGImage を取り出す
        guard let cgImage = self.cgImage else {
            return nil
        }

        // 座標系・サイズが正しく指定されているかを確認しつつクロップ
        let scale = self.scale
        let adjustedRect = CGRect(
            x: cropRect.origin.x * scale,
            y: cropRect.origin.y * scale,
            width: cropRect.size.width * scale,
            height: cropRect.size.height * scale)

        guard let croppedCGImage = cgImage.cropping(to: adjustedRect) else {
            return nil
        }

        let width = Int(adjustedRect.width)
        let height = Int(adjustedRect.height)

        // RGBA（4バイト）でピクセルデータを格納するバッファを用意
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * width

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        guard let rawData = calloc(width * height, MemoryLayout<UInt8>.size * bytesPerPixel) else {
            return nil
        }

        // CGContext を生成し、クロップした CGImage を (0,0) に描画
        guard
            let context = CGContext(
                data: rawData,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else {
            free(rawData)
            return nil
        }

        let drawRect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(croppedCGImage, in: drawRect)

        // 輝度を合計して最後に平均をとる
        var totalLuminance: Double = 0.0

        // UnsafeRawPointer を UInt8 の配列のように扱う
        let pixelBuffer = rawData.bindMemory(to: UInt8.self, capacity: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let r = Double(pixelBuffer[offset + 0])
                let g = Double(pixelBuffer[offset + 1])
                let b = Double(pixelBuffer[offset + 2])
                // 輝度の近似式
                let luminance = 0.299 * r + 0.587 * g + 0.114 * b
                totalLuminance += luminance
            }
        }

        free(rawData)

        let count = Double(width * height)
        let averageLuminance = totalLuminance / count
        return averageLuminance
    }

    /// 指定した矩形領域が「明るい」と判定できるか
    /// - Parameters:
    ///   - cropRect: 切り抜く領域
    ///   - threshold: 平均輝度がこの値を超えたら「明るい」とみなす。0〜255の範囲で設定。
    /// - Returns: 平均輝度が閾値を超えるかどうか
    fileprivate func isBrightArea(in cropRect: CGRect, threshold: Double = 128.0) -> Bool? {
        guard let avgLum = averageLuminance(in: cropRect) else {
            return nil
        }
        return avgLum > threshold
    }
}
#endif

#Preview {
    PixelBasedColorChangeView()
}
