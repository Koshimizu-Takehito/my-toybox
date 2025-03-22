import SwiftUI

struct CollisionColorChangeScreen: View {
    var body: some View {
        CollisionAnimationView(speed: .init(dx: 100, dy: 140))
    }
}

private struct CollisionAnimationView: View {
    var speed: CGVector
    private let start: Date = .now
    @State private var collision: Int = 0
    @State private var item: CGSize = .zero
    @State private var velocity: CGPoint = .zero

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { context in
                let time = context.date.timeIntervalSince(start)
                let offset = offset(container: geometry.size, movement: time * speed)
                ItemView(size: $item)
                    .background(itemColor())
                    .offset(x: -item.width / 2, y: -item.height / 2)
                    .offset(x: offset.x, y: offset.y)
                    .onChange(of: offset) { old, new in
                        velocity = old - new
                    }
                    .onChange(of: velocity) { old, new in
                        if old.x * new.x < 0 || old.y * new.y < 0 {
                            collision += 1
                        }
                    }
            }
        }
        .padding(.horizontal, item.width / 2)
        .padding(.vertical, item.height / 2)
        .background(Color(white: 28 / 255))
        .clipped()
    }

    func itemColor() -> Color {
        let hue = Double((collision * 150) % 360) / 360
        return Color(hue: hue, saturation: 0.7, brightness: 1)
    }

    func offset(container size: CGSize, movement: CGVector) -> CGPoint {
        func calc(_ key1: KeyPath<CGVector, CGFloat>, _ key2: KeyPath<CGSize, CGFloat>) -> CGFloat {
            let quotient = movement[keyPath: key1] / size[keyPath: key2]
            let remainder = movement[keyPath: key1].truncatingRemainder(
                dividingBy: size[keyPath: key2])
            return Int(floor(quotient)).isMultiple(of: 2)
                ? remainder : size[keyPath: key2] - remainder
        }
        return CGPoint(x: calc(\.dx, \.width), y: calc(\.dy, \.height))
    }
}

private struct ItemView: View {
    @Binding var size: CGSize

    var body: some View {
        Image(systemName: "playstation.logo")
            .resizable()
            .scaledToFit()
            .font(.largeTitle)
            .imageScale(.large)
            .padding()
            .frame(width: 120, height: 100)
            .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
                self.size = size
            }
    }
}

private extension CGPoint {
    static func - (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

private extension CGVector {
    static func * (_ lhs: CGFloat, _ rhs: Self) -> Self {
        self.init(dx: lhs * rhs.dx, dy: lhs * rhs.dy)
    }
}

#Preview {
    CollisionColorChangeScreen()
}
