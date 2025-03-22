import SwiftUI

struct SolarSystem1Screen: View {
    @State var start: Date = .now

    var body: some View {
        GeometryReader { geometry in
            let radius = geometry.size.width * 5 / 100
            let offset: (_ index: Int) -> CGFloat = { index in
                radius/2 + (4 + 3 * CGFloat(index)) * radius / 2
            }
            TimelineView(.animation) { context in
                let progress = context.date.timeIntervalSince(start) / 10
                ZStack {
                    Sphere(color: .red.mix(with: .orange, by: 0.2))
                        .frame(width: 1.5 * radius)
                        .overlay {
                            Text("S")
                                .fontWeight(.bold)
                        }
                    ForEach(0..<6) { index in
                        Circle().stroke(lineWidth: 1)
                            .frame(width: 2 * offset(index))
                    }
                    Group {
                        Sphere(color: .blue, offset: offset(0), progress: progress / 0.24)
                        Sphere(color: .yellow, offset: offset(1), progress: progress / 0.62)
                        Sphere(color: .green, offset: offset(2), progress: progress)
                        Sphere(color: .red, offset: offset(3), progress: progress / 1.88)
                        Sphere(color: .brown, offset: offset(4), progress: progress / 11.86)
                        Sphere(color: .gray, offset: offset(5), progress: progress / 29.46)
                    }
                    .frame(width: radius)
                }
            }
        }
        .padding()
        .padding()
        .padding()
        .scaledToFit()
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 28/255))
        .onTapGesture {
            start = .now
        }
    }
}

private struct Sphere: View {
    var color: Color
    var offset: CGFloat = .zero
    var progress: CGFloat = 1.0

    var body: some View {
        let theta = -2 * .pi * progress
        color.clipShape(.circle)
            .offset(x: offset * cos(theta), y: offset * sin(theta))
    }
}

#Preview {
    SolarSystem1Screen()
}
