import SwiftUI

// MARK: - ContentView

// https://x.com/okazz_/status/1870807939944243631
struct Motions4Screen: View {
    @State private var progress: Double = 0

    var body: some View {
        MyGroup {
            Content01(#colorLiteral(red: 0.8549019608, green: 0.2549019608, blue: 0.4039215686, alpha: 1), #colorLiteral(red: 1, green: 0.8392156863, blue: 0.2235294118, alpha: 1), progress: progress)
            Content02(#colorLiteral(red: 0.03137254902, green: 0.2392156863, blue: 0.4666666667, alpha: 1), #colorLiteral(red: 0.9843137255, green: 0.6862745098, blue: 0, alpha: 1), progress: progress)
            Content03(#colorLiteral(red: 0.5058823529, green: 0.8117647059, blue: 0.8980392157, alpha: 1), #colorLiteral(red: 0, green: 0.6862745098, blue: 0.3294117647, alpha: 1), progress: progress)
            Content04(#colorLiteral(red: 0.03137254902, green: 0.2392156863, blue: 0.4666666667, alpha: 1), #colorLiteral(red: 0.9843137255, green: 0.6862745098, blue: 0, alpha: 1), progress: progress)
        }
        .animation(animation, value: progress)
        .onAppear { progress = 1 }
    }

    var animation : Animation {
        .spring(duration: 1).repeatForever()
    }
}

// MARK: - MyGroup

private struct MyGroup<Content: View>: View {
    var numberOfColumns: Int
    var content: () -> Content

    init(numberOfColumns: Int = 2, @ViewBuilder content: @escaping () -> Content) {
        self.numberOfColumns = numberOfColumns
        self.content = content
    }

    var body: some View {
        Group(subviews: content()) { subviews in
            VStack(spacing: 0) {
                let (q, r) = subviews.count.quotientAndRemainder(dividingBy: numberOfColumns)
                let rows = Array(repeating: numberOfColumns, count: q) + (r == 0 ? [] : [r])
                ForEach(0..<rows.count, id: \.self) { i in
                    HStack(spacing: 0) {
                        Group {
                            ForEach(0..<rows[i], id: \.self) { j in
                                subviews[numberOfColumns * i + j]
                            }
                            ForEach(0..<(numberOfColumns - rows[i]), id: \.self) { j in
                                Color.clear
                            }
                        }
                        .padding()
                        .scaledToFit()
                    }
                }
            }
        }
    }
}

// MARK: - SubContentView

private protocol SubContentView: View, Animatable {
    nonisolated var progress: Double { get set }
    nonisolated var animatableData: Double { get set }
    init(color1: Color, color2: Color, progress: Double)
}

private extension SubContentView {
    nonisolated var animatableData: Double {
        get { progress }
        set { progress = min(max(newValue, 0), 1) }
    }

    init(_ color1: UIColor, _ color2: UIColor, progress: Double) {
        self.init(color1: Color(uiColor: color1), color2: Color(uiColor: color2), progress: progress)
    }
}

// MARK: - Content01

private struct Content01: SubContentView {
    var color1, color2: Color
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            let (width, height) = (geometry.size.width, geometry.size.height)
            let radius = min(width, height) / 4
            Rectangle()
                .frame(height: height / 2)
                .offset(y: progress * height / 2)
                .foregroundStyle(color1)
            Rectangle()
                .frame(width: width / 2)
                .offset(x: progress * width / 2)
                .foregroundStyle(color2)
            RoundedRectangle(cornerRadius: progress * radius)
                .foregroundStyle(color1)
                .padding(.all, progress * radius / 2)
                .frame(width: 2 * radius, height: 2 * radius)
                .offset(x: width / 2, y: height / 2)
        }
    }
}

// MARK: - Content02

private struct Content02: SubContentView {
    var color1, color2: Color
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            let (width, height) = (geometry.size.width, geometry.size.height)
            Rectangle()
                .rotationEffect(.radians(progress * .pi))
                .frame(width: width / 3, height: height / 3)
                .offset(x: width / 3, y: height / 3)
                .foregroundStyle(color2)
            Rectangle()
                .frame(width: width / 3, height: height / 3)
                .offset(y: (1 - progress) * (2.0 / 3.0) * height)
                .foregroundStyle(color1)
            Rectangle()
                .frame(width: width / 3, height: height / 3)
                .offset(x: (2.0 / 3.0) * width, y: progress * (2.0 / 3.0) * height)
                .foregroundStyle(color1)
        }
    }
}

// MARK: - Content03

private struct Content03: SubContentView {
    var color1, color2: Color
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            let (width, height) = (geometry.size.width, geometry.size.height)
            let offset = (height / 2) - tan(.pi / 8) * (width / 2)
            Rectangle()
                .transformEffect(CGAffineTransform(a: 1, b: 0, c: cos(.pi / 4), d: sin(.pi / 4), tx: 0, ty: 0))
                .rotationEffect(.radians(-.pi / 8), anchor: .topLeading)
                .scaleEffect(1 / (2 * cos(.pi / 8)), anchor: .topLeading)
                .offset(y: offset + ((1 - progress) * (height / 2)))
                .foregroundStyle(color1)
            Rectangle()
                .transformEffect(CGAffineTransform(a: 1, b: 0, c: tan(.pi / 8), d: 1, tx: 0, ty: 0))
                .transformEffect(CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0))
                .frame(width: progress * width / 2, height: height / 2)
                .offset(y: offset + ((1 - progress) * (height / 2)))
                .foregroundStyle(color2)
            Rectangle()
                .transformEffect(CGAffineTransform(a: 1, b: 0, c: tan(.pi / 8), d: 1, tx: 0, ty: 0))
                .transformEffect(CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0))
                .transformEffect(CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: 0, ty: 0))
                .frame(width: progress * width / 2, height: height / 2)
                .offset(x: width, y: offset + ((1 - progress) * (height / 2)))
                .foregroundStyle(color2)
        }
    }
}

// MARK: - Content04

private struct Content04: SubContentView {
    var color1, color2: Color
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            let (width, height) = (geometry.size.width, geometry.size.height)
            Group {
                Path { path in
                    path.addArc(
                        center: CGPoint(x: width / 2 - progress * width / 4, y: height / 2),
                        radius: width / 4,
                        startAngle: .radians(.pi),
                        endAngle: .radians(0),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                Circle()
                    .frame(
                        width: progress * width / 4, height: progress * height / 4, alignment: .center
                    )
                    .offset(x: progress * width / 4, y: progress * -height / 4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .foregroundStyle(color1)

            Group {
                Path { path in
                    path.addArc(
                        center: CGPoint(x: width / 2 + progress * width / 4, y: height / 2),
                        radius: width / 4,
                        startAngle: .radians(0),
                        endAngle: .radians(.pi),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                Circle()
                    .frame(
                        width: progress * width / 4, height: progress * height / 4, alignment: .center
                    )
                    .offset(x: progress * -width / 4, y: progress * height / 4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .foregroundStyle(color2)
        }
    }
}

// MARK: - Preview

#Preview {
    Motions4Screen()
}
