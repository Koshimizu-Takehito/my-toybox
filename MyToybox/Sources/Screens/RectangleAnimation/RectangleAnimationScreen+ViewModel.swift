import Combine
import Foundation
import SwiftUI

extension RectangleAnimationScreen {
    // MARK: - ViewModel

    /// A view model that manages an array of animated rectangles (`RectModel`).
    /// It is responsible for setting up initial positions, avoiding overlaps,
    /// and triggering animation updates per frame.
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var rects: [Model] = []

        let colors: [Color] = [
            Color(red: 0.937, green: 0.176, blue: 0.337),  // #ef2d56
            Color(red: 0.051, green: 0.376, blue: 0.612),  // #0D609C
            Color(red: 0.929, green: 0.490, blue: 0.227),  // #ed7d3a
            Color(red: 0.941, green: 0.741, blue: 0.082),  // #F0BD15
            Color(red: 0.549, green: 0.847, blue: 0.404),  // #8cd867
            Color(red: 0.184, green: 0.749, blue: 0.443),  // #2fbf71
            Color(red: 0.808, green: 0.878, blue: 0.863),  // #cee0dc
            Color(red: 0.725, green: 0.812, blue: 0.831),  // #b9cfd4
        ]

        /// Initializes and randomly generates non-overlapping rectangles to fill the canvas.
        /// - Parameter size: The size of the canvas (usually the screen).
        func setup(size: CGSize) {
            var tempRects: [Model] = []
            let width = size.width
            let height = size.height
            for _ in 0..<5000 {
                let x = .random(in: -0.1...1.1) * width
                let y = .random(in: -0.1...1.1) * height
                var w = width * .random(in: 0.02...0.3)
                let h = width * .random(in: 0.02...0.3)
                let type = Int.random(in: 0...1)
                if type == 1 {
                    w = h
                }
                let newRect = Model(
                    x: x,
                    y: y,
                    w: w,
                    h: h,
                    color: colors.randomElement()!,
                    colors: colors,
                    canvasSize: size
                )
                if !tempRects.contains(where: { $0.checkCollision(with: newRect) }) {
                    tempRects.append(newRect)
                }
            }
            rects = tempRects
        }

        /// Advances the animation state of each rectangle and triggers a view update.
        func updateRects() {
            for rect in rects {
                rect.animate()
            }
            objectWillChange.send()
        }
    }

    // MARK: - Model

    /// Represents a single animated rectangle with its own position, size,
    /// color, movement direction, and animation progress state.
    final class Model: Identifiable {
        let id = UUID()
        let originX: Double
        let originY: Double
        let originWidth: Double
        let originHeight: Double
        var currentColor: Color  // 現在の色
        var targetColor: Color  // 目標の色
        var t: Double
        let t1: Double = 120
        let t2: Double = 240
        let t3: Double = 480
        let t4: Double = 600
        let t5: Double = 720
        var progress1: Double = 0
        var progress2: Double = 0
        let shiftX: Double
        let shiftY: Double
        let voh: Bool
        let colors: [Color]

        // 現在の位置とサイズ
        var currentX: Double
        var currentY: Double
        var currentWidth: Double
        var currentHeight: Double

        init(
            x: Double,
            y: Double,
            w: Double,
            h: Double,
            color: Color,
            colors: [Color],
            canvasSize: CGSize
        ) {
            self.originX = x
            self.originY = y
            self.originWidth = w
            self.originHeight = h
            self.currentX = x
            self.currentY = y
            self.currentWidth = w
            self.currentHeight = h
            self.currentColor = color
            self.targetColor = color
            self.colors = colors
            self.t = -Double.random(in: 0..<100)
            self.voh = Bool.random()

            // 移動量をキャンバスサイズの10%に設定
            let maxShiftX = canvasSize.width * 0.1
            let maxShiftY = canvasSize.height * 0.1

            if voh {
                self.shiftX = 0
                self.shiftY = Double.random(in: -maxShiftY...maxShiftY)
            } else {
                self.shiftX = Double.random(in: -maxShiftX...maxShiftX)
                self.shiftY = 0
            }
        }

        /// Calculates the current position and size of the rectangle
        /// based on its progress and canvas size.
        func update(size: CGSize) {
            // アニメーションの進行度合いに基づいて位置とサイズを更新
            let width = size.width
            let xShift = shiftX * (1 - progress1)
            let yShift = shiftY * (1 - progress1)
            currentX = originX + xShift
            currentY = originY + yShift

            let minSize = width * 0.01
            currentWidth = lerp(a: minSize, b: originWidth, t: progress2)
            currentHeight = lerp(a: minSize, b: originHeight, t: progress2)
        }

        /// Advances the animation phase, updating color transitions and position/size easing.
        /// The animation goes through five phases: slide in, grow, pause, shrink, and slide out.
        func animate() {
            // 色の補間
            currentColor = currentColor.mix(with: targetColor, by: 0.05)

            if Int(t) % 80 == 0 {  // 色の変更タイミングを調整
                targetColor = colors.randomElement()!  // 新しい目標色を設定
            }

            if t > 0 && t < t1 {
                progress1 = easeInOutQuint(x: normalize(value: t, start: 0, end: t1 - 1))
            } else if t1 < t && t < t2 {
                progress2 = easeInOutQuint(x: normalize(value: t, start: t1, end: t2 - 1))
            } else if t2 < t && t < t3 {
                // 一時停止
            } else if t3 < t && t < t4 {
                progress2 = easeInOutQuint(x: 1 - normalize(value: t, start: t3, end: t4 - 1))
            } else if t4 < t && t < t5 {
                progress1 = easeInOutQuint(x: 1 - normalize(value: t, start: t4, end: t5 - 1))
            }
            if t5 < t {
                t = 0
            }
            t += 1  // tの増加量はそのまま
        }

        /// Checks whether this rectangle would collide with another based on original positions.
        /// - Parameter other: Another `RectModel` to check collision against.
        /// - Returns: True if the rectangles overlap.
        func checkCollision(with other: Model) -> Bool {
            return
                !(originX - originWidth / 2 > other.originX + other.originWidth / 2
                || originX + originWidth / 2 < other.originX - other.originWidth / 2
                || originY - originHeight / 2 > other.originY + other.originHeight / 2
                || originY + originHeight / 2 < other.originY - other.originHeight / 2)
        }
    }

}

// イージング関数と補間関数

/// Easing function for smooth animations with acceleration and deceleration.
/// Provides a 'quintic' curve (x⁵ and its inverse).
private func easeInOutQuint(x: Double) -> Double {
    return x < 0.5 ? 16 * pow(x, 5) : 1 - pow(-2 * x + 2, 5) / 2
}

/// Normalizes a value within a given range to a 0.0 - 1.0 scale.
private func normalize(value: Double, start: Double, end: Double) -> Double {
    return (value - start) / (end - start)
}

/// Linearly interpolates between two values.
/// - Parameters:
///   - a: Start value
///   - b: End value
///   - t: Interpolation factor (0.0 to 1.0)
private func lerp(a: Double, b: Double, t: Double) -> Double {
    return a + (b - a) * t
}
