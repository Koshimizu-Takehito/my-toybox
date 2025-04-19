import SwiftUI

struct SqureflowScreen: View {
    private let holder = SquresHolder()

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                holder.update(at: timeline.date, in: size)
                for item in holder.squre {
                    let shape = item.path(in: size, date: timeline.date)
                    context.fill(shape, with: .color(item.color))
                }
            }
        }
        .ignoresSafeArea()
    }
}

private final class SquresHolder {
    private(set) var squre = Set<Squre>()
    private let maxCount = 10

    func update(at date: Date, in size: CGSize) {
        squre = squre.filter { $0.isAlive(at: date, in: size) }
        guard squre.count < maxCount else {
            return
        }
        squre.insert(Squre(creationDate: date))
    }
}

private struct Squre: Hashable {
    static let velocities = 0.02...0.1

    var x: Double
    var edge: Double
    var creationDate: Date
    var initialY: Double = .random(in: 1.0...2.0)
    var velocity: Double = .random(in: velocities)
    var color = Color(red: 0.2, green: 0.3, blue: 0.8).opacity(.random(in: 0.2...0.6))

    init(creationDate: Date) {
        self.creationDate = creationDate
        self.edge = .random(in: 0.1...0.3)
        self.x = max(.random(in: 0.01...0.99) - edge, 0.01)
    }

    func isAlive(at date: Date, in size: CGSize) -> Bool {
        let duration = date.distance(to: creationDate)
        let y = size.height * (initialY + duration * velocity)
        let d = size.width * sqrt(2) * edge
        return y + d > 0
    }

    func path(in size: CGSize, date: Date) -> Path {
        let duration = date.distance(to: creationDate)
        let edge = edge * size.width
        let rect = CGRect(
            x: x * size.width,
            y: size.height * (initialY + duration * velocity),
            width: edge,
            height: edge
        )

        let velocity = velocity/Squre.velocities.upperBound
        return RoundedRectangle(cornerRadius: max(edge/8, 4), style: .circular)
            .rotation(.radians(-velocity * duration / 2))
            .path(in: rect)
    }
}

#Preview {
    SqureflowScreen()
}
