import SwiftUI

// MARK: - JuliaSetScreen

@Metadata(title: "Julia Set", description: "Julia Set", tags: [.metal])
struct JuliaSetScreen: View {
    @State private var id = UUID()
    var body: some View {
        NavigationStack {
            JuliaSetGestureView(id: $id)
                .toolbar { barItem }
                .tint(.white)
        }
    }

    var barItem: some View {
        Button("Reset") {
            id = UUID()
        }
        .fontWeight(.semibold)
    }
}

// MARK: - JuliaSetShaderView

struct JuliaSetShaderView: View, Animatable {
    typealias Animatable2 = AnimatablePair<Double, Double>
    typealias Animatable4 = AnimatablePair<Animatable2, Animatable2>
    typealias Animatable5 = AnimatablePair<Double, Animatable4>

    var scale: Double
    var constant: CGPoint
    var location: CGPoint

    nonisolated var animatableData: Animatable5 {
        get {
            .init(scale, .init(.init(constant.x, constant.y), .init(location.x, location.y)))
        }
        set {
            scale = newValue.first
            constant.x = newValue.second.first.first
            constant.y = newValue.second.first.second
            location.x = newValue.second.second.first
            location.y = newValue.second.second.second
        }
    }

    var body: some View {
        Rectangle().colorEffect(
            ShaderFunction(library: .module, name: "JuliaSet::main")(
                .boundingRect,
                .float(scale),
                .float2(constant.x, constant.y),
                .float2(location.x, location.y)
            )
        )
    }
}

// MARK: - JuliaSetGestureView

private struct JuliaSetGestureView: View {
    @Binding var id: UUID
    @GestureState private var magnifyBy = 1.0
    @State private var constant = CGPoint(x: 0.3575, y: 0.3575)
    @State private var location = CGPoint.zero
    @State private var lastLocation = CGPoint.zero
    @State private var scale: Double = 1
    @State private var lastScale: Double = 0.5

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let size = geometry.size
                JuliaSetShaderView(scale: scale, constant: constant, location: location)
                    .onTapGesture(count: 1) { location in
                        onTap(location: location, in: size)
                    }
                    .gesture(dragGesture(size: size))
                    .gesture(magnification)
            }
            .ignoresSafeArea()

            VStack {
                Spacer()
                Slider(value: $constant.x, in: 0.3504 ... (constant.y - 0.0001))
                Slider(value: $constant.y, in: 0.3506 ... 0.4)
            }
            .padding()
        }
        .onChange(of: id) { _, _ in
            reset()
        }
    }

    var magnification: some Gesture {
        MagnifyGesture()
            .updating($magnifyBy) { value, gestureState, _ in
                gestureState = value.magnification / 2.0
                scale = lastScale + value.magnification / 2.0
            }
            .onEnded { _ in
                lastScale = scale
            }
    }

    private func onTap(location: CGPoint, in size: CGSize) {
        withAnimation {
            let r = pow(scale, 2)
            self.location.x += 1 / r * (location.x - size.width / 2) / size.width
            self.location.y += 1 / r * (location.y - size.height / 2) / size.width
            lastLocation = self.location
        }
    }

    private func dragGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { action in
                onDrag(action: action, in: size)
            }
            .onEnded { action in
                onDrag(action: action, in: size)
                lastLocation = CGPoint(x: -location.x, y: -location.y)
            }
    }

    private func onDrag(action: DragGesture.Value, in size: CGSize) {
        let base = lastLocation
        let r = pow(scale, 2)
        location.x = -(base.x + 1 / r * (action.translation.width) / size.width)
        location.y = -(base.y + 1 / r * (action.translation.height) / size.width)
    }

    func reset() {
        let scale = scale
        let duration = scale > 1 ? min(log(scale), 2) : 0.5
        withAnimation(.spring(duration: duration)) {
            self.scale = 1
            lastScale = 0.5
        } completion: {
            withAnimation(.spring(duration: duration)) {
                location = .zero
                lastLocation = .zero
            }
            withAnimation(.spring(duration: 1.5)) {
                constant = CGPoint(x: 0.3575, y: 0.3575)
            }
        }
    }
}

#Preview {
    JuliaSetScreen()
}
