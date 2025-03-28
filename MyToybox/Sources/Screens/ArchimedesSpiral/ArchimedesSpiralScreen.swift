import SwiftUI

struct ArchimedesSpiralScreen: View {
    @State var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince(start) / 120
            let rotation = 0.8 + 0.2 * abs((cos(.pi * time) + 1.0) / 2.0)
            Canvas { context, size in
                let radius = 2.0
                let center = CGPoint(x: size.width/2 - radius, y: size.height/2 - radius)
                let pointSize = CGSize(width: 2 * radius, height: 2 * radius)
                for i in 0..<3000 {
                    let j = rotation * Double(i)
                    let p = CGPoint.spiral(at: .radians(j)) / 2
                    let path = Circle().path(in: CGRect(origin: center + p, size: pointSize))
                    let hue = j.truncatingRemainder(dividingBy: 255) / 255
                    context.fill(path, with:.color(Color(hue: hue)))
                }
            }
        }
        .background(.black)
        .onTapGesture { start = .now }
        .ignoresSafeArea()
    }
}

private extension CGPoint {
    static func spiral(at angle: Angle) -> Self {
        let r = angle.radians
        return CGPoint(x: r * cos(r), y: r * sin(r))
    }

    static func +(_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func *(_ lhs: Double, _ rhs: Self) -> Self {
        self.init(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    static func /(_ lhs: Self, _ rhs: Double) -> Self {
        self.init(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

private extension Color {
    init(hue: Double) {
        self.init(hue: hue, saturation: 0.6, brightness: 1)
    }
}

#Preview {
    ArchimedesSpiralScreen()
}
