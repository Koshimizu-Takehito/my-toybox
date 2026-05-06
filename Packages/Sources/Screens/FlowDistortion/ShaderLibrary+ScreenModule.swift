import SwiftUI

extension ShaderLibrary {
    static var screenModule: ShaderLibrary {
        if let url = Bundle.module.url(forResource: "default", withExtension: "metallib") {
            return ShaderLibrary(url: url)
        }
        return .default
    }
}
