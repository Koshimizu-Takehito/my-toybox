import SwiftUI

public extension ShaderLibrary {
    /// Returns the shader library from the module's bundle.
    /// Falls back to `.default` if the module library is not available (e.g., when running in the main app).
    static var module: ShaderLibrary {
        if let url = Bundle.module.url(forResource: "default", withExtension: "metallib") {
            return ShaderLibrary(url: url)
        }
        return .default
    }
}
