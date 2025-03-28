import SwiftUI

struct PrimeSpiralScreen: View {
    private static let primeNumbers = sieveOfEratosthenes(upTo: 1000000)
    @State private var scale = 1.0
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince(start)
                .truncatingRemainder(dividingBy: 30)
            let scale = max(time, 1)
            Canvas { context, size in
                let radius = 4 / min(scale, 4)
                let center = CGPoint(size: size) / 2  - radius
                let pointSize =  radius * CGSize(width: 2, height: 2)
                for i in Self.primeNumbers {
                    let j = Double(i)
                    let p = CGPoint.spiral(at: .radians(j)) / (scale * 50)
                    let path = Circle().path(in: CGRect(origin: center + p, size: pointSize))
                    context.fill(path, with:.color(color))
                }
            }
        }
        .ignoresSafeArea()
        .background(.black)
        .onTapGesture { start = Date() }
    }

    var color: Color {
        Color(hue: 0.6, saturation: 0.6, brightness: 1)
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

    static func +(_ lhs: Self, _ rhs: Double) -> Self {
        self.init(x: lhs.x + rhs, y: lhs.y + rhs)
    }

    static func -(_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func -(_ lhs: Self, _ rhs: Double) -> Self {
        self.init(x: lhs.x - rhs, y: lhs.y - rhs)
    }

    static func *(_ lhs: Double, _ rhs: Self) -> Self {
        self.init(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    static func /(_ lhs: Self, _ rhs: Double) -> Self {
        self.init(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    init(size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
}

private extension CGSize {
    static func *(_ lhs: Double, _ rhs: Self) -> Self {
        self.init(width: lhs * rhs.width, height: lhs * rhs.height)
    }
}

private func sieveOfEratosthenes(upTo n: Int) -> [Int] {
    guard n >= 2 else {
        return []
    }
    var isPrime = [Bool](repeating: true, count: n + 1)
    isPrime[0] = false
    isPrime[1] = false

    let limit = Int(Double(n).squareRoot())
    for i in 2...limit {
        if !isPrime[i] {
            continue
        }
        for j in stride(from: i * i, through: n, by: i) {
            isPrime[j] = false
        }
    }
    var primes: [Int] = []
    for i in 2...n {
        if isPrime[i] {
            primes.append(i)
        }
    }
    return primes
}

#Preview {
    PrimeSpiralScreen()
}
