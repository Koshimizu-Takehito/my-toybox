//
//  Inspired by the following work:
//  Yohei Nishitsuji (@YoheiNishitsuji)
//  https://x.com/YoheiNishitsuji/status/1928677024131895624
//
//  This implementation is an adaptation for SwiftUI and Metal,
//  with additional documentation and parameterization.
//  Original idea and shader pattern by Yohei Nishitsuji.
//

import MyToyboxCore
import SwiftUI

// MARK: - CosmicWebDemoScreen

/// A demo screen that displays an animated "Cosmic Web" visualization,
/// inspired by large-scale cosmic structures and self-organizing neural networks.
/// The pattern is generated using a custom Metal shader.
@Metadata(title: .screenCosmicWebDemoTitle, description: .screenCosmicWebDemoDescription, tags: [.animation, .metal])
public struct CosmicWebDemoScreen: View {
    public init() {}

    public var body: some View {
        CosmicWebScreen()
    }
}

// MARK: - CosmicWebScreen

public struct CosmicWebScreen: View {
    public init() {}

    public var body: some View {
        TimelineView(.animation) { context in
            // The current time, used to animate the shader pattern.
            let time = context.date.timeIntervalSinceReferenceDate
            Rectangle()
                .backgroundExtensionEffect()
                .layerEffect(.cosmicWeb(time: time), maxSampleOffset: .zero)
        }
    }
}

// MARK: - Shader

extension Shader {
    /// Returns a Shader configured to generate the cosmic web effect.
    /// - Parameter time: The current animation time (seconds).
    /// - Returns: The configured Shader instance.
    static func cosmicWeb(time: Double) -> Shader {
        var time = time
        time = time.truncatingRemainder(dividingBy: 2 * .pi)
        let function = ShaderFunction(library: .screenModule, name: "CosmicWeb::main")
        return function(.boundingRect, .float(time))
    }
}

// MARK: - Preview

#Preview {
    CosmicWebDemoScreen()
}
