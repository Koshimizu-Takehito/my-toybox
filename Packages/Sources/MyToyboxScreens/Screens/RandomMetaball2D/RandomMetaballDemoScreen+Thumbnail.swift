import SwiftUI

extension RandomMetaballDemoScreen {
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> some View {
        RandomMetaballThumbnail(particleCount: 10, time: time)
            .transaction { transaction in
                transaction.animation = !isScrolling ? transaction.animation : nil
                transaction.disablesAnimations = isScrolling
            }
    }
}

// MARK: - RandomMetaballThumbnail

private struct RandomMetaballThumbnail: View {
    private let particles: [Particle]
    private let time: TimeInterval

    init(particleCount: Int, time: TimeInterval) {
        self.particles = Particle.makeParticles(count: particleCount)
        self.time = time
    }

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                context.addFilter(.alphaThreshold(min: 0.3, color: .purple))
                context.addFilter(.blur(radius: 0.025 * min(size.width, size.height)))

                context.drawLayer { layer in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    for index in particles.indices {
                        layer.draw(layer.resolveSymbol(id: index)!, at: center)
                    }
                }
            } symbols: {
                let size = geometry.size
                let base = min(size.width, size.height)
                ForEach(Array(particles.enumerated()), id: \.offset) { index, particle in
                    Circle()
                        .frame(
                            width: particle.diameterRatio * base,
                            height: particle.diameterRatio * base
                        )
                        .position(
                            x: particle.xRatio * size.width,
                            y: particle.yRatio * size.height
                        )
                        .scaleEffect(particle.scale(at: time))
                        .tag(index)
                }
            }
        }
    }
}

// MARK: - Particle

private struct Particle {
    var xRatio: CGFloat
    var yRatio: CGFloat
    var diameterRatio: CGFloat
    var phase: Double
    var speed: Double

    func scale(at time: TimeInterval) -> Double {
        let oscillation = sin(phase + speed * time)
        return 0.15 + 0.85 * ((oscillation + 1.0) / 2.0)
    }

    /// 粒子の幾何と位相はインデックスから決定
    static func makeParticles(count: Int) -> [Particle] {
        let golden = Double.pi * (3 - sqrt(5))
        let n = Double(max(count, 1))
        return (0 ..< count).map { index in
            let i = Double(index) + 0.5
            let radius = sqrt(i / n) * 0.42
            let theta = i * golden
            let x = 0.5 + radius * cos(theta)
            let y = 0.5 + radius * sin(theta)
            let xRatio = CGFloat(min(max(x, 0.1), 0.9))
            let yRatio = CGFloat(min(max(y, 0.1), 0.9))
            let diameterT = 0.5 + 0.5 * cos(i * 1.414)
            let diameterRatio = CGFloat(0.08 + 0.20 * diameterT)
            let phase = i * 1.618 * (2.0 * .pi / 5.0)
            let speedT = 0.5 + 0.5 * sin(i * 2.718)
            let speed = 0.8 + 1.6 * speedT
            return Particle(xRatio: xRatio, yRatio: yRatio, diameterRatio: diameterRatio, phase: phase, speed: speed)
        }
    }
}

#Preview {
    RandomMetaballDemoScreen.thumbnail
}
