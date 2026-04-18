import SwiftUI

#if os(iOS)
private let gradationColors: [Color] = [
    .black,
    .blue,
    .green,
    .purple,
    .mint,
    .teal,
    .indigo,
    .cyan,
]

@Metadata(title: "Mesh Gradient", description: "MeshGradient サンプル", tags: [])
struct Meshgradient2Screen: View {
    @State private var id = UUID()
    @State private var isDotsHidden = false
    @State private var colors: [Color] = [.black, .blue, .green]
    @State private var offsets: [CGSize] = .init(repeating: .zero, count: 25)
    @State private var angle: Double = 0
    @State private var toolbarHidden = false

    var body: some View {
        NavigationStack {
            ZStack {
                MeshView(
                    id: $id,
                    isDotsHidden: $isDotsHidden,
                    offsets: $offsets,
                    width: colors.count,
                    height: colors.count,
                    colors: colors
                )
                .hueRotation(.radians(angle))
            }
            .onTapGesture {
                withAnimation {
                    toolbarHidden.toggle()
                }
            }
            .toolbar {
                toolbarItems()
            }
            .tint(.white)
            .fontWeight(.semibold)
            .background {
                Color.black
                    .ignoresSafeArea()
            }
            .onChange(of: colors.count) { _, _ in
                offsets = [CGSize](repeating: .zero, count: colors.count * colors.count)
            }
        }
    }

    @ToolbarContentBuilder
    func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Button {
                    id = .init()
                    colors.append(gradationColors[colors.count])
                } label: {
                    Image(systemName: "plus.circle")
                }
                .disabled(colors.count > 7)

                Button {
                    id = .init()
                    _ = colors.popLast()
                } label: {
                    Image(systemName: "minus.circle")
                }
                .disabled(colors.count <= 3)
            }
            .opacity(toolbarHidden ? 0 : 1)
        }
        ToolbarItem(placement: .topBarTrailing) {
            HStack {
                Spacer()
                    .frame(maxWidth: .infinity)
                Button(isDotsHidden ? "Show" : "Hide") {
                    withAnimation {
                        isDotsHidden.toggle()
                    }
                }
                Button("Reset") {
                    id = .init()
                    isDotsHidden = false
                    angle = 0
                }
            }
            .opacity(toolbarHidden ? 0 : 1)
        }
        ToolbarItem(placement: .bottomBar) {
            Slider(value: $angle, in: -(.pi) ... .pi)
                .opacity(toolbarHidden ? 0 : 1)
        }
    }
}

struct MeshView: View {
    let width: Int
    let height: Int
    let colors: [Color]
    @Binding private var offsets: [CGSize]
    @Binding private var id: UUID
    @Binding private var isDotsHidden: Bool

    init(
        id: Binding<UUID>,
        isDotsHidden: Binding<Bool>,
        offsets: Binding<[CGSize]>,
        width: Int,
        height: Int,
        colors: [Color]
    ) {
        self._id = id
        self._isDotsHidden = isDotsHidden
        self._offsets = offsets
        self.width = width
        self.height = height
        self.colors = colors
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MeshGradient(
                    width: width,
                    height: height,
                    points: points(geometry: geometry),
                    colors: colors.flatMap { color in
                        [Color](repeating: color, count: width)
                    }
                )
                let size = geometry.size
                let radius = min(size.width, size.height) / 20
                ForEach(0 ..< height, id: \.self) { j in
                    ForEach(0 ..< width, id: \.self) { i in
                        if offsets.count > j * width + i {
                            Dot(id: id, radius: radius, isDraggable: false, currentOffset: .constant(CGSize.zero))
                                .offset(
                                    x: 0.85 * (Double(i) - Double(width - 1) / 2) / Double(width - 1) * size.width,
                                    y: 0.85 * (Double(j) - Double(height - 1) / 2) / Double(height - 1) * size.height
                                )
                                .opacity(isDotsHidden ? 0 : 1)
                        }
                    }
                }
                ForEach(0 ..< height, id: \.self) { j in
                    ForEach(0 ..< width, id: \.self) { i in
                        if offsets.count > j * width + i {
                            let isDraggable = (i != 0 && i != width - 1) && (j != 0 && j != height - 1)
                            if isDraggable {
                                Dot(id: id, radius: radius, isDraggable: isDraggable, currentOffset: $offsets[j * width + i])
                                    .offset(
                                        x: 0.85 * (Double(i) - Double(width - 1) / 2) / Double(width - 1) * size.width,
                                        y: 0.85 * (Double(j) - Double(height - 1) / 2) / Double(height - 1) * size.height
                                    )
                                    .opacity(isDotsHidden ? 0 : 1)
                            }
                        }
                    }
                }
            }
            .id(id)
            .onChange(of: id) { _, _ in
                withAnimation {
                    offsets = [CGSize](repeating: .zero, count: width * height)
                }
            }
            .ignoresSafeArea()
        }
    }

    func points(geometry: GeometryProxy) -> [SIMD2<Float>] {
        let size = geometry.size
        var points = [SIMD2<Float>](repeating: .zero, count: width * height)
        for j in 0 ..< height {
            for i in 0 ..< width {
                points[j * width + i].x += Float(i) / Float(height - 1)
                points[j * width + i].y += Float(j) / Float(height - 1)
                if offsets.count > j * width + i {
                    points[j * width + i] += SIMD2(offsets[j * width + i] / size)
                }
            }
        }
        return points
    }
}

private struct Dot: View {
    let id: UUID
    let radius: Double
    let isDraggable: Bool
    @State private var offsets = (dragging: CGSize.zero, last: CGSize.zero)
    @Binding var currentOffset: CGSize

    var body: some View {
        Circle()
            .frame(width: radius)
            .foregroundStyle(.white.opacity(1 / 1024))
            .gesture(
                DragGesture()
                    .onChanged {
                        guard isDraggable else { return }
                        offsets.dragging = $0.translation
                        currentOffset = offsets.last + offsets.dragging
                    }
                    .onEnded { _ in
                        guard isDraggable else { return }
                        offsets.last += offsets.dragging
                        offsets.dragging = .zero
                        currentOffset = offsets.last + offsets.dragging
                    }
            )
            .offset(offsets.last)
            .background {
                Circle()
                    .frame(width: radius)
                    .foregroundStyle(
                        isDraggable ? .orange.mix(with: .pink, by: 0.45).opacity(0.9) : .white.opacity(0.3)
                    )
                    .offset(currentOffset)
            }
            .onChange(of: id) { _, _ in
                offsets = (.zero, .zero)
            }
    }
}

private extension CGSize {
    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func - (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func / (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }

    static func * (_ lhs: CGFloat, _ rhs: Self) -> Self {
        self.init(width: lhs * rhs.width, height: lhs * rhs.height)
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}

private extension SIMD2<Float> {
    init(_ v: CGSize) {
        self.init(x: Float(v.width), y: Float(v.height))
    }
}

#Preview {
    Meshgradient2Screen()
}

#elseif os(macOS)
@Metadata(title: "Mesh Gradient", description: "MeshGradient サンプル", tags: [])
struct Meshgradient2Screen: View {
    var body: some View {
        Text("This feature is not available on macOS")
            .foregroundStyle(.secondary)
    }
}
#endif
