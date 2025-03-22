import SwiftUI

struct SolarSystem2Screen: View {
    let start: Date = .now
    @State var faith = 0.0

    var body: some View {
        ZStack {
            OrbitsView(faith: faith)

            TimelineView(.animation) {
                let time = $0.date.timeIntervalSince(start) / 10
                SolarSystemView(faith: faith, time: time)
            }

            FaithSlider(faith: $faith)
        }
        .animation(.linear, value: faith)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 28 / 255))
    }
}

private struct FaithSlider: View {
    @Binding var faith: Double

    var body: some View {
        HStack {
            Slider(value: $faith.animation(.linear), in: 0.0...1.0)

            ZStack(alignment: .trailing) {
                Text(1.00.formatted(.percent.rounded(rule: .up, increment: 1)))
                    .hidden()
                Text(faith.formatted(.percent.rounded(rule: .up, increment: 1)))
            }
            .contentTransition(.numericText())
            .foregroundStyle(.white)
            .monospacedDigit()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding()
    }
}

private struct SolarSystemView: View {
    let faith: Double
    let time: TimeInterval

    var body: some View {
        GeometryReader { geometry in
            let radius = geometry.size.width * 5 / 100
            let offset: (_ index: Int) -> CGFloat = { index in
                (4 + 3 * CGFloat(index)) * radius / 2
            }
            let earth = Sphere(star: .earth, offset: offset(2), time: time)
            ZStack {
                // Sun
                Sphere(faith: faith, star: .sun, center: earth)
                    .frame(width: radius)
                // Planets
                ForEach(0..<Star.planets.count, id: \.self) { index in
                    let planet = Star.planets[index]
                    Sphere(
                        faith: faith, star: planet, center: earth, offset: offset(index), time: time
                    )
                    .frame(width: radius / 2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scaledToFit()
    }
}

private struct OrbitsView: View {
    let faith: Double

    var body: some View {
        GeometryReader { geometry in
            let radius = geometry.size.width * 5 / 100
            // Sun
            Orbit(faith: 1 - faith, radius: radius, index: 2, target: Star.sun)
                .stroke(lineWidth: 1.5)
                .foregroundStyle(Star.sun.color)
            // Planets
            ForEach(0..<Star.planets.count, id: \.self) { index in
                let planet = Star.planets[index]
                Orbit(faith: faith, radius: radius, index: index, target: planet)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(planet.color)
                    .opacity(1 - 0.5 * faith)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scaledToFit()
    }
}

private struct Orbit: Shape {
    var faith = 1.0
    var insetAmount = 0.0
    var radius: CGFloat
    var index: Int
    var target: Star

    var animatableData: Double {
        get { faith }
        set { faith = min(max(newValue, 0), 1) }
    }

    func path(in rect: CGRect) -> Path {
        let offset: (_ index: Int) -> CGFloat = { index in
            (4 + 3 * CGFloat(index)) * radius / 2
        }
        let mid = CGPoint(x: rect.midX, y: rect.midY)
        return Path { path in
            let earth = Sphere(star: .earth, offset: offset(2), time: 0)
            let planet = Sphere(
                faith: faith, star: target, center: earth, offset: offset(index), time: 0)
            let point = planet.point - planet.faith * planet.center
            path.move(to: point + mid)

            let maxVaule = target.speed > 1 ? target.speed : 1 / target.speed
            for time in 0...Int(360.0 * maxVaule) {
                let time = Double(time) / 360.0
                let earth = Sphere(star: .earth, offset: offset(2), time: time)
                let planet = Sphere(
                    faith: faith, star: target, center: earth, offset: offset(index), time: time)
                let point = planet.point - planet.faith * planet.center
                path.addLine(to: point + mid)
            }
        }
    }
}

private struct Sphere {
    var color: Color = .clear
    var center: CGPoint = .zero
    var offset = 0.0
    var radians = 0.0
    var faith = 0.0

    var point: CGPoint {
        CGPoint(x: offset * cos(radians), y: offset * sin(radians))
    }
}

extension Sphere {
    fileprivate init(
        faith: Double = 0,
        star: Star,
        center: Sphere = Sphere(),
        offset: Double = 0.0,
        time: Double = 0.0
    ) {
        self.color = star.color
        self.offset = offset
        self.radians = -2 * .pi * star.speed * time
        self.center = center.point
        self.faith = faith
    }
}

extension Sphere: View {
    var body: some View {
        let point = point - faith * center
        color.clipShape(.circle)
            .offset(x: point.x, y: point.y)
    }
}

extension Sphere: Animatable {
    var animatableData: Double {
        get { faith }
        set { faith = min(max(newValue, 0), 1) }
    }
}

private struct Star: Hashable, Identifiable {
    var id = UUID()
    var color: Color
    var speed: Double

    static var sun: Star {
        Star(color: .red.mix(with: .orange, by: 0.2), speed: 1)
    }

    static var earth: Star {
        Star(color: .green, speed: 1)
    }

    static let planets: [Star] = [
        Star(color: .blue, speed: 1 / 0.2),
        Star(color: .yellow, speed: 1 / 0.5),
        Star(color: .green, speed: 1),
        Star(color: .red, speed: 1 / 2),
        Star(color: .brown, speed: 1 / 10),
        Star(color: .gray, speed: 1 / 20),
    ]
}

extension CGPoint {
    fileprivate static func + (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    fileprivate static func - (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    fileprivate static func * (_ lhs: Double, _ rhs: Self) -> Self {
        self.init(x: lhs * rhs.x, y: lhs * rhs.y)
    }
}

#Preview {
    SolarSystem2Screen()
}
