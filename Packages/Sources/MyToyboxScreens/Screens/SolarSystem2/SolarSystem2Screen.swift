import SwiftUI

// MARK: - SolarSystem2Screen

/// A SwiftUI view that simulates a solar system with adjustable perspective between
/// the geocentric and heliocentric models using a faith slider.
struct SolarSystem2Screen: View {
    let start: Date = .now
    @State private var faith = 0.0

    var body: some View {
        // The main container overlays multiple views:
        // 1. Planet orbit paths (OrbitsView)
        // 2. Planet animations (SolarSystemView in TimelineView)
        // 3. Slider control for changing the "faith" parameter
        ZStack {
            // Draws orbital paths that morph based on "faith"
            OrbitsView(faith: faith)

            // Continuously animates the solar system over time
            TimelineView(.animation) {
                let time = $0.date.timeIntervalSince(start) / 10
                SolarSystemView(faith: faith, time: time)
            }

            // Slider to interactively adjust the "faith" value
            FaithSlider(faith: $faith)
        }
        // Smoothly animate changes to "faith"
        .animation(.linear, value: faith)
        // Make the view take up the full available space
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Set a dark background color
        .background(Color(white: 28 / 255))
    }
}

// MARK: - FaithSlider

/// A slider UI to control the `faith` parameter, which linearly interpolates between
/// geocentric (0.0) and heliocentric (1.0) planetary motion models.
private struct FaithSlider: View {
    @Binding var faith: Double

    var body: some View {
        // A horizontal layout containing a slider and a dynamic percentage label
        HStack {
            // Slider to control the faith value (0.0 to 1.0), with animation
            Slider(value: $faith.animation(.linear), in: 0.0 ... 1.0)

            // Percentage label aligned to the right
            ZStack(alignment: .trailing) {
                // Hidden label to reserve layout space for consistent alignment
                Text(1.00.formatted(.percent.rounded(rule: .up, increment: 1)))
                    .hidden()
                // Actual visible percentage that updates with faith value
                Text(faith.formatted(.percent.rounded(rule: .up, increment: 1)))
            }
            .contentTransition(.numericText()) // Smooth numeric transition
            .foregroundStyle(.white) // White text color
            .monospacedDigit() // Monospaced digits for stable layout
        }
        // Position the slider at the bottom of the screen
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding()
    }
}

// MARK: - SolarSystemView

/// A view that displays all planets and the sun as animated circular bodies,
/// orbiting based on the `faith` value and elapsed time.
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
                ForEach(0 ..< Star.planets.count, id: \.self) { index in
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

// MARK: - OrbitsView

/// A background visualization of the orbital paths of each celestial body.
/// The appearance and motion depend on the `faith` parameter.
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
            ForEach(0 ..< Star.planets.count, id: \.self) { index in
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

// MARK: - Orbit

/// A `Shape` that draws the orbital path of a celestial body
/// by computing positions over time using the given model (`faith`).
private struct Orbit: Shape {
    /// Faith value determining heliocentric (1.0) or geocentric (0.0) view
    var faith = 1.0
    /// Base orbit radius
    var radius: CGFloat
    /// Planet index (e.g., 0 for Mercury, 1 for Venus, etc.)
    var index: Int
    /// The planet/star to render the orbit for
    var target: Star
    /// Required to animate the `faith` property smoothly
    var animatableData: Double {
        get { faith }
        set { faith = min(max(newValue, 0), 1) }
    }

    func path(in rect: CGRect) -> Path {
        /// Computes the offset from the center for the given index
        let offset: (_ index: Int) -> CGFloat = { index in
            (4 + 3 * CGFloat(index)) * radius / 2
        }
        /// The center point of the canvas
        let mid = CGPoint(x: rect.midX, y: rect.midY)

        return Path { path in
            // Compute the initial Earth position at time = 0
            let earth = Sphere(star: .earth, offset: offset(2), time: 0)
            // Compute the target planet's position relative to Earth
            let planet = Sphere(
                faith: faith, star: target, center: earth, offset: offset(index), time: 0
            )
            // Calculate the orbit start point, adjusted based on faith
            let point = planet.point - planet.faith * planet.center
            // Move the path's start point to the computed position
            path.move(to: point + mid)
            // Determine the appropriate number of samples based on orbit speed
            let maxSpeed = target.speed > 1 ? target.speed : 1 / target.speed
            // Iterate to simulate orbit progression across time (0 to ~1 second)
            for step in 0 ... Int(360.0 * maxSpeed) {
                // Normalize step into a time value between 0.0 and 1.0
                let time = Double(step) / 360.0
                // Recalculate Earth's position at this time
                let earth = Sphere(star: .earth, offset: offset(2), time: time)
                // Recalculate planet's position at this time
                let planet = Sphere(faith: faith, star: target, center: earth, offset: offset(index), time: time)
                // Adjust position based on faith (centered around Earth or Sun)
                let point = planet.point - planet.faith * planet.center
                // Add a line from the previous point to the current one
                path.addLine(to: point + mid)
            }
        }
    }
}

// MARK: - Sphere

/// A geometric and visual representation of a celestial body (planet or star).
/// When used as a View, it renders itself as a circle offset from its center,
/// simulating orbital motion.
private nonisolated struct Sphere {
    var color: Color = .clear
    var center: CGPoint = .zero
    var offset = 0.0
    var radians = 0.0
    var faith = 0.0

    /// Computes the screen position of this sphere based on its radius and angle.
    var point: CGPoint {
        CGPoint(x: offset * cos(radians), y: offset * sin(radians))
    }
}

private nonisolated extension Sphere {
    init(
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

// MARK: View

extension Sphere: View {
    var body: some View {
        let point = point - faith * center
        color.clipShape(.circle)
            .offset(x: point.x, y: point.y)
    }
}

// MARK: Animatable

extension Sphere: Animatable {
    var animatableData: Double {
        get { faith }
        set { faith = min(max(newValue, 0), 1) }
    }
}

// MARK: - Star

/// A model representing a star or planet in the solar system, including its color and orbital speed.
private nonisolated struct Star: Hashable, Identifiable {
    var id = UUID()
    var color: Color
    var speed: Double

    static var sun: Self {
        Self(color: .red.mix(with: .orange, by: 0.2), speed: 1)
    }

    static var earth: Self {
        Self(color: .green, speed: 1)
    }

    static let planets: [Self] = [
        Self(color: .blue, speed: 1 / 0.2),
        Self(color: .yellow, speed: 1 / 0.5),
        Self(color: .green, speed: 1),
        Self(color: .red, speed: 1 / 2),
        Self(color: .brown, speed: 1 / 10),
        Self(color: .gray, speed: 1 / 20),
    ]
}

private nonisolated extension CGPoint {
    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (_ lhs: Double, _ rhs: Self) -> Self {
        self.init(x: lhs * rhs.x, y: lhs * rhs.y)
    }
}

#Preview {
    SolarSystem2Screen()
}
