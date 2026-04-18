import SwiftUI

// MARK: - PrimeSpiralScreen

/// A SwiftUI view that renders a prime number spiral (Ulam spiral-like),
/// where each prime number is plotted along a polar spiral curve.
///
/// The spiral continuously animates outward as time progresses, using
/// `TimelineView` and `Canvas` for efficient real-time rendering.
@Metadata(title: "Prime Spiral", description: "素数のアルキメデスの螺旋", tags: [.animation])
struct PrimeSpiralScreen: View {
    /// The start time of the animation.
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            // Compute elapsed time in seconds since `start`, looping every 30 seconds.
            let time = context.date.timeIntervalSince(start).truncatingRemainder(dividingBy: 30)
            // Prevent division by zero by clamping the minimum scale.
            let scale = max(time, 1)

            PrimeSpiralContent(scale: scale, color: color)
        }
        .ignoresSafeArea()
        .background(.black)
        .onTapGesture {
            // Restart the animation from zero on tap.
            start = Date()
        }
    }

    /// The color used to draw each prime dot.
    var color: Color {
        Color(hue: 0.6, saturation: 0.6, brightness: 1)
    }
}

// MARK: - PrimeSpiralContent

struct PrimeSpiralContent: View {
    /// List of all prime numbers up to 1,000,000.
    private static let primeNumbers = sieveOfEratosthenes(upTo: 1_000_000)

    var scale: Double
    var color: Color

    var body: some View {
        Canvas { context, size in
            // Each prime will be drawn as a small dot (circle) on the spiral.
            let radius = 4 / min(scale, 4) // Point radius shrinks as scale increases.
            let center = CGPoint(size: size) / 2 - radius
            let pointSize = radius * CGSize(width: 2, height: 2)

            for i in Self.primeNumbers {
                let j = Double(i)
                let p = CGPoint.spiral(at: .radians(j)) / (scale * 50)
                let path = Circle().path(in: CGRect(origin: center + p, size: pointSize))
                context.fill(path, with: .color(color))
            }
        }
    }
}

// MARK: - CGPoint

private extension CGPoint {
    /// Computes the spiral position (polar coordinates) for a given angle.
    ///
    /// The spiral grows outward as the angle increases.
    /// This method is used to convert an index (e.g., prime number) into a coordinate.
    static func spiral(at angle: Angle) -> Self {
        let r = angle.radians
        return CGPoint(x: r * cos(r), y: r * sin(r))
    }

    // Utility overloads to support CGPoint math.

    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func + (_ lhs: Self, _ rhs: Double) -> Self {
        self.init(x: lhs.x + rhs, y: lhs.y + rhs)
    }

    static func - (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func - (_ lhs: Self, _ rhs: Double) -> Self {
        self.init(x: lhs.x - rhs, y: lhs.y - rhs)
    }

    static func * (_ lhs: Double, _ rhs: Self) -> Self {
        self.init(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    static func / (_ lhs: Self, _ rhs: Double) -> Self {
        self.init(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    init(size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
}

// MARK: - CGSize

private extension CGSize {
    static func * (_ lhs: Double, _ rhs: Self) -> Self {
        self.init(width: lhs * rhs.width, height: lhs * rhs.height)
    }
}

// MARK: -

/// Calculates all prime numbers up to a given upper bound using
/// the Sieve of Eratosthenes algorithm.
///
/// This is a classic method for efficiently finding prime numbers.
///
/// - Parameter n: The inclusive upper bound.
/// - Returns: An array of all primes ≤ `n`.
private func sieveOfEratosthenes(upTo n: Int) -> [Int] {
    guard n >= 2 else {
        return []
    }
    var isPrime = [Bool](repeating: true, count: n + 1)
    isPrime[0] = false
    isPrime[1] = false

    let limit = Int(Double(n).squareRoot())
    for i in 2 ... limit {
        if !isPrime[i] {
            continue
        }
        for j in stride(from: i * i, through: n, by: i) {
            isPrime[j] = false
        }
    }
    var primes: [Int] = []
    for i in 2 ... n {
        if isPrime[i] {
            primes.append(i)
        }
    }
    return primes
}

#Preview {
    PrimeSpiralScreen()
}
