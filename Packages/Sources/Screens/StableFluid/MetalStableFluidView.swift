import Metal
import MetalKit
import MyToyboxCore
import MyToyboxMedia
import Observation
import simd
import SwiftUI

// MARK: - MetalStableFluidView

/// Metal-backed view that renders the stable fluid simulation (`UIViewRepresentable`).
///
/// ## Attribution
/// The stable fluid simulation algorithm is based on
/// Jos Stam, *"Stable Fluids,"* SIGGRAPH 1999.
///
/// This Metal implementation is inspired by the WebGPU (TypeScript) example in
/// [TypeGPU](https://github.com/software-mansion/TypeGPU)
/// (`apps/typegpu-docs/src/examples/simulation/stable-fluid/`).
/// TypeGPU is **© 2025 Software Mansion** and distributed under the **MIT License**.
/// 安定流体シミュレーションを描画する Metal ベースのビュー（`UIViewRepresentable`）。
///
/// This view bridges SwiftUI and MetalKit by wrapping an `MTKView`.
/// All GPU work (compute simulation + render visualization) is managed
/// by the inner `Coordinator` class, which acts as the `MTKViewDelegate`.
/// このビューは `MTKView` をラップして SwiftUI と MetalKit を橋渡しする。
/// すべての GPU 処理（コンピュートシミュレーション＋レンダー可視化）は、
/// `MTKViewDelegate` として機能する内部の `Coordinator` クラスで管理される。
struct MetalStableFluidView: PlatformAgnosticViewRepresentable {
    // MARK: Coordinator

    /// Manages Metal pipeline state objects, simulation textures, and per-frame rendering.
    /// Metal パイプラインステートオブジェクト、シミュレーションテクスチャ、フレーム毎の描画を管理する。
    ///
    /// ## Metal Glossary
    /// - `MTLDevice` – GPU hardware / GPU ハードウェア
    /// - `MTLCommandQueue` – serial queue of GPU command buffers / GPU コマンドバッファの直列キュー
    /// - PSO (`MTLComputePipelineState`, `MTLRenderPipelineState`) – pre-compiled shader / プリコンパイル済みシェーダ
    /// - `MTLTexture` – GPU-resident 2D data grid / GPU 上の 2D データグリッド
    /// - `MTLSamplerState` – texture interpolation policy / テクスチャ補間ポリシー
    ///
    /// - SeeAlso: [Metal Programming Guide](https://developer.apple.com/metal/)
    @MainActor
    final class Coordinator: NSObject, MTKViewDelegate {
        // MARK: Types

        /// Mirrors MSL `SimParams`. Layout must match exactly.
        /// MSL `SimParams` のミラー。レイアウトを正確に一致させること。
        struct SimParamsBuffer {
            /// Discrete time step (dimensionless).
            /// 離散時間刻み幅（無次元）。
            var deltaTime: Float

            /// Kinematic viscosity coefficient (dimensionless).
            /// 動粘性係数（無次元）。
            var viscosity: Float
        }

        /// Mirrors MSL `BrushParams`. Layout must match exactly.
        /// MSL `BrushParams` のミラー。レイアウトを正確に一致させること。
        struct BrushParamsBuffer {
            /// Brush center in grid-cell indices.
            /// グリッドセルインデックスでのブラシ中心。
            var pos: SIMD2<Int32>

            /// Per-frame movement in grid cells.
            /// グリッドセル単位のフレーム間移動。
            var delta: SIMD2<Float>

            /// Gaussian falloff radius in grid cells.
            /// グリッドセル単位のガウス減衰半径。
            var radius: Float

            /// Force vector multiplier.
            /// 力ベクトルの倍率。
            var forceScale: Float

            /// Peak ink deposit at brush center.
            /// ブラシ中心でのインク注入ピーク値。
            var inkAmount: Float
        }

        /// Mirrors MSL `ImageParams`. Layout must match exactly.
        /// MSL `ImageParams` のミラー。レイアウトを正確に一致させること。
        struct ImageParamsBuffer {
            /// One pixel in UV space (`1.0 / gridWidth`), for gradient sampling.
            /// UV 空間での 1 ピクセル幅（`1.0 / グリッド幅`）。勾配サンプリング用。
            var pixelStep: Float

            /// Background image aspect ratio (`width / height`).
            /// 背景画像アスペクト比（`幅 / 高さ`）。
            var imageAspect: Float
        }

        // MARK: Brush Defaults

        private enum BrushDefaults {
            static let radiusFraction: Float = 1.0 / 16.0
            static let forceScale: Float = 1.0
            static let inkAmount: Float = 0.02
        }

        // MARK: Stored Properties

        private let viewModel: StableFluidViewModel

        /// The GPU device. Exposed for `MTKView` initialization.
        /// GPU デバイス。`MTKView` の初期化のために公開。
        let device: any MTLDevice
        private let queue: any MTLCommandQueue

        /// Bilinear sampler with clamp-to-edge addressing.
        /// Required by Semi-Lagrangian advection and fragment shaders to
        /// interpolate values at non-integer texture coordinates.
        /// エッジクランプアドレッシング付きバイリニアサンプラー。
        /// Semi-Lagrangian 移流およびフラグメントシェーダが
        /// 非整数テクスチャ座標で値を補間するために必要。
        private let linearSampler: any MTLSamplerState

        // -- Compute pipeline state objects (one per simulation step) --
        private var brushPSO: (any MTLComputePipelineState)!
        private var addInkPSO: (any MTLComputePipelineState)!
        private var addForcesPSO: (any MTLComputePipelineState)!
        private var advectPSO: (any MTLComputePipelineState)!
        private var diffusionPSO: (any MTLComputePipelineState)!
        private var divergencePSO: (any MTLComputePipelineState)!
        private var pressurePSO: (any MTLComputePipelineState)!
        private var projectPSO: (any MTLComputePipelineState)!
        private var advectInkPSO: (any MTLComputePipelineState)!

        // -- Render pipeline state objects (one per display mode) --
        private var inkRenderPSO: (any MTLRenderPipelineState)!
        private var velRenderPSO: (any MTLRenderPipelineState)!
        private var imageFitRenderPSO: (any MTLRenderPipelineState)!
        private var imageFillRenderPSO: (any MTLRenderPipelineState)!

        /// Background image texture for the image-distortion display mode.
        /// 画像歪み表示モード用の背景画像テクスチャ。
        private var backgroundTex: (any MTLTexture)?

        // -- Simulation textures --
        // "Ping-pong" technique: two textures per field so one can be read
        // while the other is written in the same dispatch. The active index
        // (velIndex, inkIndex, pressureIndex) tracks which is current.
        //
        // 「ピンポン」技法：各場に 2 つのテクスチャを用意し、同一ディスパッチ内で
        // 一方を読み取りながら他方に書き込む。アクティブインデックス
        // (velIndex, inkIndex, pressureIndex) がどちらが最新かを追跡する。

        /// Velocity field (float2: vx, vy stored in .rg channels).
        /// 速度場（float2: vx, vy を .rg チャネルに格納）。
        private var velTex: [any MTLTexture] = []

        /// Ink density field (scalar stored in .r channel).
        /// インク密度場（スカラーを .r チャネルに格納）。
        private var inkTex: [any MTLTexture] = []

        /// Pressure field (scalar stored in .r channel).
        /// 圧力場（スカラーを .r チャネルに格納）。
        private var pressureTex: [any MTLTexture] = []

        /// Temporary texture for brush-generated force vectors.
        /// ブラシが生成した力ベクトルの一時テクスチャ。
        private var forceTex: (any MTLTexture)!

        /// Temporary texture for newly deposited ink from the brush.
        /// ブラシから新たに注入されたインクの一時テクスチャ。
        private var newInkTex: (any MTLTexture)!

        /// Temporary texture storing the divergence of the velocity field.
        /// 速度場の発散を格納する一時テクスチャ。
        private var divergenceTex: (any MTLTexture)!

        /// Heap used for all simulation textures.
        /// シミュレーションテクスチャに使う MTLHeap。
        private var simulationHeap: (any MTLHeap)?

        private var velIndex = 0
        private var inkIndex = 0
        private var pressureIndex = 0

        // MARK: Init

        init(viewModel: StableFluidViewModel, device: any MTLDevice) {
            self.viewModel = viewModel
            self.device = device
            self.queue = device.makeCommandQueue()!

            let samplerDesc = MTLSamplerDescriptor()
            samplerDesc.minFilter = .linear
            samplerDesc.magFilter = .linear
            samplerDesc.sAddressMode = .clampToEdge
            samplerDesc.tAddressMode = .clampToEdge
            self.linearSampler = device.makeSamplerState(descriptor: samplerDesc)!

            super.init()
            buildPipelines()
            loadBackgroundTexture()
            makeTextures(size: viewModel.gridSize)

            viewModel.onGridSizeChanged = { [weak self] newSize in
                self?.makeTextures(size: newSize)
            }
        }

        // MARK: Setup

        /// Build all compute and render pipeline state objects from the Metal library.
        /// Metal ライブラリからすべてのコンピュートおよびレンダーパイプラインステートオブジェクトを構築する。
        ///
        /// A **compute PSO** wraps a single kernel function for GPGPU work.
        /// A **render PSO** pairs a vertex shader with a fragment shader for drawing.
        /// **コンピュート PSO** は GPGPU 処理用の単一カーネル関数をラップする。
        /// **レンダー PSO** は頂点シェーダとフラグメントシェーダを組み合わせて描画する。
        private func buildPipelines() {
            let library = try! device.makeDefaultLibrary(bundle: .module)

            func computePSO(_ name: String) -> any MTLComputePipelineState {
                let fn = library.makeFunction(name: name)!
                let desc = MTLComputePipelineDescriptor()
                desc.computeFunction = fn
                desc.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
                return try! device.makeComputePipelineState(descriptor: desc, options: [], reflection: nil)
            }

            brushPSO = computePSO("fluidBrush")
            addInkPSO = computePSO("fluidAddInk")
            addForcesPSO = computePSO("fluidAddForces")
            advectPSO = computePSO("fluidAdvect")
            diffusionPSO = computePSO("fluidDiffusion")
            divergencePSO = computePSO("fluidDivergence")
            pressurePSO = computePSO("fluidPressure")
            projectPSO = computePSO("fluidProject")
            advectInkPSO = computePSO("fluidAdvectInk")

            let vs = library.makeFunction(name: "fluidFullscreenVS")!

            func renderPSO(_ fsName: String) -> any MTLRenderPipelineState {
                let fs = library.makeFunction(name: fsName)!
                let desc = MTLRenderPipelineDescriptor()
                desc.vertexFunction = vs
                desc.fragmentFunction = fs
                desc.colorAttachments[0].pixelFormat = .bgra8Unorm
                return try! device.makeRenderPipelineState(descriptor: desc)
            }

            inkRenderPSO = renderPSO("fluidInkFS")
            velRenderPSO = renderPSO("fluidVelocityFS")

            func imageRenderPSO(fill: Bool) -> any MTLRenderPipelineState {
                let fcv = MTLFunctionConstantValues()
                var flag = fill
                fcv.setConstantValue(&flag, type: .bool, index: 0)
                let fs = try! library.makeFunction(name: "fluidImageFS", constantValues: fcv)
                let desc = MTLRenderPipelineDescriptor()
                desc.vertexFunction = vs
                desc.fragmentFunction = fs
                desc.colorAttachments[0].pixelFormat = .bgra8Unorm
                return try! device.makeRenderPipelineState(descriptor: desc)
            }
            imageFitRenderPSO = imageRenderPSO(fill: false)
            imageFillRenderPSO = imageRenderPSO(fill: true)
        }

        /// Load the "waterwheel" image from the asset catalog into a Metal texture.
        /// アセットカタログの "waterwheel" 画像を Metal テクスチャに読み込む。
        ///
        /// Uses platform-specific APIs (`UIImage` on iOS/tvOS, `NSImage` on macOS)
        /// because `MTKTextureLoader` requires a `CGImage`.
        /// `MTKTextureLoader` が `CGImage` を要求するため、プラットフォーム固有の
        /// API（iOS/tvOS では `UIImage`、macOS では `NSImage`）を使用する。
        private func loadBackgroundTexture() {
            #if os(iOS) || os(tvOS)
            guard let cgImage = UIImage(named: "waterwheel", in: MyToyboxMedia.bundle, compatibleWith: nil)?.cgImage else { return }
            #elseif os(macOS)
            guard let cgImage = MyToyboxMedia.bundle.image(forResource: "waterwheel")?.cgImage(forProposedRect: nil, context: nil, hints: nil)
            else { return }
            #endif
            let loader = MTKTextureLoader(device: device)
            backgroundTex = try? loader.newTexture(cgImage: cgImage, options: [
                .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
                .SRGB: false,
            ])
        }

        /// Allocate (or re-allocate) all simulation textures for the given grid size.
        /// 指定されたグリッドサイズで、すべてのシミュレーションテクスチャを確保（または再確保）する。
        ///
        /// All textures use `.rgba16Float` (16-bit float per channel) for HDR precision.
        /// This avoids clamping artifacts in velocity and pressure fields where values
        /// may be negative or exceed 1.0.
        /// すべてのテクスチャは HDR 精度のために `.rgba16Float`（チャネルあたり 16 ビット浮動小数点）を使用。
        /// 速度場や圧力場で値が負や 1.0 を超える場合のクランプアーティファクトを回避する。
        ///
        /// - Parameter size: Number of cells along each axis.
        ///                   各軸のセル数。
        private func makeTextures(size: Int) {
            let texDesc = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .rgba16Float,
                width: size,
                height: size,
                mipmapped: false
            )
            texDesc.usage = [.shaderRead, .shaderWrite]
            texDesc.storageMode = .private

            let texCount = 9 // vel×2 + ink×2 + pressure×2 + force + newInk + divergence
            let sizeAndAlign = device.heapTextureSizeAndAlign(descriptor: texDesc)
            let alignedSize = (sizeAndAlign.size + sizeAndAlign.align - 1) & ~(sizeAndAlign.align - 1)

            let heapDesc = MTLHeapDescriptor()
            heapDesc.size = alignedSize * texCount
            heapDesc.storageMode = .private
            heapDesc.hazardTrackingMode = .tracked

            if let heap = device.makeHeap(descriptor: heapDesc) {
                simulationHeap = heap
                func heapTexture() -> any MTLTexture { heap.makeTexture(descriptor: texDesc)! }
                velTex = [heapTexture(), heapTexture()]
                inkTex = [heapTexture(), heapTexture()]
                pressureTex = [heapTexture(), heapTexture()]
                forceTex = heapTexture()
                newInkTex = heapTexture()
                divergenceTex = heapTexture()
            } else {
                simulationHeap = nil
                func deviceTexture() -> any MTLTexture { device.makeTexture(descriptor: texDesc)! }
                velTex = [deviceTexture(), deviceTexture()]
                inkTex = [deviceTexture(), deviceTexture()]
                pressureTex = [deviceTexture(), deviceTexture()]
                forceTex = deviceTexture()
                newInkTex = deviceTexture()
                divergenceTex = deviceTexture()
            }

            velIndex = 0
            inkIndex = 0
            pressureIndex = 0
        }

        // MARK: MTKViewDelegate

        func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let commandBuffer = queue.makeCommandBuffer()
            else { return }

            let gridSize = velTex[0].width

            if !viewModel.paused {
                encodeSimulation(into: commandBuffer, gridSize: gridSize)
            }
            if let rpd = view.currentRenderPassDescriptor {
                encodeRender(into: commandBuffer, with: rpd)
            }
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

        // MARK: Simulation

        /// Encode the full 9-step fluid simulation pipeline into a compute command encoder.
        /// 9 ステップの流体シミュレーションパイプライン全体をコンピュートコマンドエンコーダにエンコードする。
        ///
        /// The steps implement the Jos Stam "Stable Fluids" algorithm:
        /// ステップは Jos Stam の「Stable Fluids」アルゴリズムを実装する：
        ///
        /// **User Input (Steps 1-3, only when brush is active):**
        /// **ユーザー入力（ステップ 1-3、ブラシがアクティブ時のみ）：**
        ///   1. `fluidBrush`     – Generate force & ink from touch via Gaussian falloff.
        ///   2. `fluidAddInk`    – Accumulate new ink into the density field.
        ///   3. `fluidAddForces` – Apply external forces to the velocity field (Euler: v += Δt * F).
        ///
        /// **Advection & Diffusion (Steps 4-5):**
        /// **移流と拡散（ステップ 4-5）：**
        ///   4. `fluidAdvect`    – Semi-Lagrangian velocity self-advection (trace backward, sample).
        ///   5. `fluidDiffusion` – Viscous diffusion via Jacobi iteration.
        ///
        /// **Pressure Projection (Steps 6-8, Helmholtz-Hodge decomposition):**
        /// **圧力射影（ステップ 6-8、Helmholtz-Hodge 分解）：**
        ///   6. `fluidDivergence` – Compute divergence of the velocity field.
        ///   7. `fluidPressure`   – Solve the Poisson equation for pressure (Jacobi).
        ///   8. `fluidProject`    – Subtract pressure gradient to enforce div(v) = 0.
        ///
        /// **Ink Transport (Step 9):**
        /// **インク輸送（ステップ 9）：**
        ///   9. `fluidAdvectInk`  – Advect ink density by the divergence-free velocity.
        ///
        /// All dispatches share a single compute encoder; Metal guarantees
        /// serial execution within one encoder, so no explicit barriers are needed.
        /// すべてのディスパッチは単一のコンピュートエンコーダを共有する。Metal は
        /// 1 つのエンコーダ内での直列実行を保証するため、明示的なバリアは不要。
        private func encodeSimulation(into cb: any MTLCommandBuffer, gridSize: Int) {
            guard let enc = cb.makeComputeCommandEncoder() else { return }

            let threadW = 16
            let threadH = 16
            let threadsPerGroup = MTLSize(width: threadW, height: threadH, depth: 1)
            let numGroups = MTLSize(
                width: (gridSize + threadW - 1) / threadW,
                height: (gridSize + threadH - 1) / threadH,
                depth: 1
            )

            var simParams = SimParamsBuffer(deltaTime: viewModel.deltaTime, viscosity: viewModel.viscosity)

            if viewModel.brush.isDown {
                // 1. Brush: generate force and ink
                var brushParams = BrushParamsBuffer(
                    pos: viewModel.brush.pos,
                    delta: viewModel.brush.delta,
                    radius: Float(gridSize) * BrushDefaults.radiusFraction,
                    forceScale: BrushDefaults.forceScale,
                    inkAmount: BrushDefaults.inkAmount
                )
                enc.setComputePipelineState(brushPSO)
                enc.setTexture(forceTex, index: 0)
                enc.setTexture(newInkTex, index: 1)
                enc.setBytes(&brushParams, length: MemoryLayout<BrushParamsBuffer>.stride, index: 0)
                enc.dispatchThreadgroups(numGroups, threadsPerThreadgroup: threadsPerGroup)

                // 2. Add ink
                enc.setComputePipelineState(addInkPSO)
                enc.setTexture(inkTex[inkIndex], index: 0)
                enc.setTexture(newInkTex, index: 1)
                enc.setTexture(inkTex[1 - inkIndex], index: 2)
                enc.dispatchThreadgroups(numGroups, threadsPerThreadgroup: threadsPerGroup)
                inkIndex = 1 - inkIndex

                // 3. Add forces
                enc.setComputePipelineState(addForcesPSO)
                enc.setTexture(velTex[velIndex], index: 0)
                enc.setTexture(forceTex, index: 1)
                enc.setTexture(velTex[1 - velIndex], index: 2)
                enc.setBytes(&simParams, length: MemoryLayout<SimParamsBuffer>.stride, index: 0)
                enc.dispatchThreadgroups(numGroups, threadsPerThreadgroup: threadsPerGroup)
                velIndex = 1 - velIndex
            }

            // 4. Advect velocity
            enc.setComputePipelineState(advectPSO)
            enc.setTexture(velTex[velIndex], index: 0)
            enc.setTexture(velTex[1 - velIndex], index: 1)
            enc.setSamplerState(linearSampler, index: 0)
            enc.setBytes(&simParams, length: MemoryLayout<SimParamsBuffer>.stride, index: 0)
            enc.dispatchThreadgroups(numGroups, threadsPerThreadgroup: threadsPerGroup)
            velIndex = 1 - velIndex

            // 5. Diffusion (Jacobi iterations)
            for _ in 0 ..< viewModel.jacobiIterations {
                enc.setComputePipelineState(diffusionPSO)
                enc.setTexture(velTex[velIndex], index: 0)
                enc.setTexture(velTex[1 - velIndex], index: 1)
                enc.setBytes(&simParams, length: MemoryLayout<SimParamsBuffer>.stride, index: 0)
                enc.dispatchThreadgroups(numGroups, threadsPerThreadgroup: threadsPerGroup)
                velIndex = 1 - velIndex
            }

            // 6. Divergence
            enc.setComputePipelineState(divergencePSO)
            enc.setTexture(velTex[velIndex], index: 0)
            enc.setTexture(divergenceTex, index: 1)
            enc.dispatchThreadgroups(numGroups, threadsPerThreadgroup: threadsPerGroup)

            // 7. Pressure solve (Jacobi iterations)
            pressureIndex = 0
            for _ in 0 ..< viewModel.jacobiIterations {
                enc.setComputePipelineState(pressurePSO)
                enc.setTexture(pressureTex[pressureIndex], index: 0)
                enc.setTexture(divergenceTex, index: 1)
                enc.setTexture(pressureTex[1 - pressureIndex], index: 2)
                enc.dispatchThreadgroups(numGroups, threadsPerThreadgroup: threadsPerGroup)
                pressureIndex = 1 - pressureIndex
            }

            // 8. Project
            enc.setComputePipelineState(projectPSO)
            enc.setTexture(velTex[velIndex], index: 0)
            enc.setTexture(pressureTex[pressureIndex], index: 1)
            enc.setTexture(velTex[1 - velIndex], index: 2)
            enc.dispatchThreadgroups(numGroups, threadsPerThreadgroup: threadsPerGroup)
            velIndex = 1 - velIndex

            // 9. Advect ink
            enc.setComputePipelineState(advectInkPSO)
            enc.setTexture(velTex[velIndex], index: 0)
            enc.setTexture(inkTex[inkIndex], index: 1)
            enc.setTexture(inkTex[1 - inkIndex], index: 2)
            enc.setSamplerState(linearSampler, index: 0)
            enc.setBytes(&simParams, length: MemoryLayout<SimParamsBuffer>.stride, index: 0)
            enc.dispatchThreadgroups(numGroups, threadsPerThreadgroup: threadsPerGroup)
            inkIndex = 1 - inkIndex

            enc.endEncoding()
        }

        // MARK: Render

        /// Encode a fullscreen render pass that visualizes the simulation in the chosen display mode.
        /// 選択された表示モードでシミュレーションを可視化するフルスクリーンレンダーパスをエンコードする。
        ///
        /// Uses the "oversized triangle" trick: a single triangle with vertices at
        /// (-1,-1), (3,-1), (-1,3) covers the entire clip space without a vertex buffer.
        /// The rasterizer clips it to the viewport, producing a fullscreen quad.
        /// 「巨大三角形」トリック：(-1,-1), (3,-1), (-1,3) の頂点を持つ
        /// 単一の三角形が頂点バッファなしでクリップ空間全体をカバーする。
        /// ラスタライザがビューポートにクリップし、フルスクリーンクアッドを生成する。
        private func encodeRender(into cb: any MTLCommandBuffer, with rpd: MTLRenderPassDescriptor) {
            guard let enc = cb.makeRenderCommandEncoder(descriptor: rpd) else { return }

            switch viewModel.displayMode {
            case .image:
                let pso = viewModel.imageContentMode == .aspectFill
                    ? imageFillRenderPSO! : imageFitRenderPSO!
                enc.setRenderPipelineState(pso)
                enc.setFragmentTexture(inkTex[inkIndex], index: 0)
                enc.setFragmentTexture(backgroundTex, index: 1)
                let bgW = Float(backgroundTex?.width ?? 1)
                let bgH = Float(backgroundTex?.height ?? 1)
                var imageParams = ImageParamsBuffer(
                    pixelStep: 1.0 / Float(velTex[0].width),
                    imageAspect: bgW / bgH
                )
                enc.setFragmentBytes(&imageParams, length: MemoryLayout<ImageParamsBuffer>.stride, index: 0)

            case .ink:
                enc.setRenderPipelineState(inkRenderPSO)
                enc.setFragmentTexture(inkTex[inkIndex], index: 0)

            case .velocity:
                enc.setRenderPipelineState(velRenderPSO)
                enc.setFragmentTexture(velTex[velIndex], index: 0)
            }
            enc.setFragmentSamplerState(linearSampler, index: 0)
            enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            enc.endEncoding()
        }
    }

    // MARK: Properties

    /// ViewModel reference shared with the SwiftUI screen.
    /// SwiftUI 画面と共有される ViewModel 参照。
    let viewModel: StableFluidViewModel

    func makeCoordinator() -> Coordinator {
        let device = MTLCreateSystemDefaultDevice()!
        return Coordinator(viewModel: viewModel, device: device)
    }

    func makePlatformView(context: Context) -> MTKView {
        let device = context.coordinator.device
        let view = MTKView(frame: .zero, device: device)
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.framebufferOnly = true
        view.colorPixelFormat = .bgra8Unorm
        view.delegate = context.coordinator
        return view
    }

    func updatePlatformView(_: PlatformViewType, context _: Context) {}
}
