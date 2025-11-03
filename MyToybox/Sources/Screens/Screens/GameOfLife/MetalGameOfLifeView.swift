import Metal
import MetalKit
import Observation
import SwiftUI
import simd

// MARK: - MTKView Representable

/// Metal による Game of Life の描画ビュー（`UIViewRepresentable`）。
struct MetalGameOfLifeView: UIViewRepresentable {
    // MARK: Coordinator

    /// `MTKViewDelegate` 実装と Metal パイプラインの管理。
    @MainActor
    final class Coordinator: NSObject, MTKViewDelegate {
        // MARK: Types

        /// フラグメントシェーダへ送る表示用ユニフォーム。
        struct ViewUniforms {
            var width: UInt32
            var height: UInt32
            var scale: Float
            var location: SIMD2<Float> // (-0.5...0.5)
            var offset: SIMD2<Float>
            var foreground: SIMD4<Float> // RGBA
            var background: SIMD4<Float>
            var pad: Float = 0.05
        }

        // MARK: Stored Properties

        private let viewModel: GameOfLifeViewModel
        let device: any MTLDevice
        private let queue: any MTLCommandQueue
        private var computePSO: (any MTLComputePipelineState)!
        private var renderPSO: (any MTLRenderPipelineState)!
        private var srcTex: (any MTLTexture)!
        private var dstTex: (any MTLTexture)!
        private var lastStepTime: CFTimeInterval = CACurrentMediaTime()

        // MARK: Init

        init(viewModel: GameOfLifeViewModel, device: any MTLDevice) {
            self.viewModel = viewModel
            self.device = device
            self.queue = device.makeCommandQueue()!

            super.init()
            buildPipelines()
            makeTextures(size: viewModel.size)

            // VM フック
            viewModel.onSizeChanged = { [weak self] new in
                self?.makeTextures(size: new)
            }
        }

        // MARK: Setup

        /// コンピュート／レンダーの各パイプラインを構築する。
        private func buildPipelines() {
            let library = try! device.makeDefaultLibrary(bundle: .main)

            // Compute
            let cs = library.makeFunction(name: "lifeStep")!
            computePSO = try! device.makeComputePipelineState(function: cs)

            // Render
            let vs = library.makeFunction(name: "fullscreenQuadVS")!
            let fs = library.makeFunction(name: "lifeBlitFS")!

            let desc = MTLRenderPipelineDescriptor()
            desc.vertexFunction = vs
            desc.fragmentFunction = fs
            desc.colorAttachments[0].pixelFormat = .bgra8Unorm
            renderPSO = try! device.makeRenderPipelineState(descriptor: desc)
        }

        /// 指定サイズでピンポン用テクスチャを生成し、乱数初期化する。
        /// - Parameter size: 一辺セル数。
        private func makeTextures(size: Int) {
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .r8Uint,
                width: size,
                height: size,
                mipmapped: false
            )
            descriptor.usage = [.shaderRead, .shaderWrite]
            srcTex = device.makeTexture(descriptor: descriptor)
            dstTex = device.makeTexture(descriptor: descriptor)
            randomize(texture: srcTex)
            randomize(texture: dstTex) // 初期は同じでも OK
            viewModel.resetStats()
        }

        /// R8Uint テクスチャを 0/1 でランダム初期化する。
        private func randomize(texture: any MTLTexture) {
            let count = texture.width * texture.height
            var bytes = [UInt8](repeating: 0, count: count)
            for i in 0 ..< count {
                bytes[i] = UInt8.random(in: 0 ... 1)
            }
            bytes.withUnsafeBytes { ptr in
                texture.replace(
                    region: MTLRegionMake2D(0, 0, texture.width, texture.height),
                    mipmapLevel: 0,
                    withBytes: ptr.baseAddress!,
                    bytesPerRow: texture.width
                )
            }
        }

        // MARK: MTKViewDelegate

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // NOP
        }

        func draw(in view: MTKView) {
            guard
                let drawable = view.currentDrawable,
                let commandBuffer = queue.makeCommandBuffer()
            else { return }

            // 1) 必要なら 1 ステップ進める（間隔は cycleIntervalMS）
            if viewModel.isRunning {
                let now = CACurrentMediaTime()
                let elapsedMS = (now - lastStepTime) * 1000.0
                if elapsedMS >= viewModel.cycleIntervalMS {
                    encodeCompute(into: commandBuffer)
                    swap(&srcTex, &dstTex)
                    lastStepTime = now
                    viewModel.didCommitStep()
                }
            }

            // 2) 描画
            if let rp = view.currentRenderPassDescriptor {
                encodeRender(into: commandBuffer, with: rp)
                commandBuffer.present(drawable)
            }
            commandBuffer.commit()
        }

        // MARK: Encode

        /// ライフゲームの 1 ステップを計算するコンピュートパスをエンコードする。
        private func encodeCompute(into cb: any MTLCommandBuffer) {
            guard let enc = cb.makeComputeCommandEncoder() else { return }
            enc.setComputePipelineState(computePSO)
            enc.setTexture(srcTex, index: 0)
            enc.setTexture(dstTex, index: 1)

            var wh1 = SIMD3<UInt32>(UInt32(srcTex.width), UInt32(srcTex.height), 1)
            var wrap: UInt32 = 1 // 1 にするとトーラス（ラップ）境界
            enc.setBytes(&wh1, length: MemoryLayout<SIMD3<UInt32>>.stride, index: 0)
            enc.setBytes(&wrap, length: MemoryLayout<UInt32>.stride, index: 1)

            let w = computePSO.threadExecutionWidth
            let h = max(1, computePSO.maxTotalThreadsPerThreadgroup / w)
            let tg = MTLSize(width: w, height: h, depth: 1)
            let ng = MTLSize(
                width: (srcTex.width + w - 1) / w,
                height: (srcTex.height + h - 1) / h,
                depth: 1
            )
            enc.dispatchThreadgroups(ng, threadsPerThreadgroup: tg)
            enc.endEncoding()
        }

        /// 表示（フルスクリーン・クアッド）のレンダーパスをエンコードする。
        private func encodeRender(into cb: any MTLCommandBuffer, with rpd: MTLRenderPassDescriptor) {
            guard let enc = cb.makeRenderCommandEncoder(descriptor: rpd) else { return }
            enc.setRenderPipelineState(renderPSO)

            // uniforms
            var uni = ViewUniforms(
                width: UInt32(srcTex.width),
                height: UInt32(srcTex.height),
                scale: Float(max(1.0, viewModel.scale)),
                location: SIMD2<Float>(Float(viewModel.location.x), Float(viewModel.location.y)),
                offset: SIMD2<Float>(Float(viewModel.offset.x), Float(viewModel.offset.y)),
                foreground: SIMD4<Float>(0.2, 0.9, 0.7, 1.0),  // mint-ish
                background: SIMD4<Float>(0.05, 0.05, 0.10, 1.0) // dark bluish
            )

            enc.setFragmentBytes(&uni, length: MemoryLayout<ViewUniforms>.stride, index: 0)
            enc.setFragmentTexture(srcTex, index: 0)

            // フルスクリーンクアッド（3頂点トリック）
            enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            enc.endEncoding()
        }
    }

    // MARK: UIViewRepresentable

    /// ViewModel 参照。
    let viewModel: GameOfLifeViewModel

    func makeCoordinator() -> Coordinator {
        let device = MTLCreateSystemDefaultDevice()!
        return Coordinator(viewModel: viewModel, device: device)
    }

    func makeUIView(context: Context) -> MTKView {
        let device = context.coordinator.device
        let view = MTKView(frame: .zero, device: device)
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.framebufferOnly = true
        view.colorPixelFormat = .bgra8Unorm
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        GameOfLifeScreen()
    }
    .colorScheme(.dark)
}
