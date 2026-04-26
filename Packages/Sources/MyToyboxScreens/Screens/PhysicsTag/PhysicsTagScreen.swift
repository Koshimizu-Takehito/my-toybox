import SpriteKit
import SwiftUI

#if os(iOS)

// MARK: - PhysicsTagScreen

/// Tag cloud demo combining SpriteKit physics and CoreMotion.
/// Gravity follows device tilt; touch to drag and nudge tags.
@Metadata(title: .screenPhysicsTagTitle, description: .screenPhysicsTagDescription, tags: [.animation])
struct PhysicsTagScreen: View {
    @State private var scene: PhysicsTagScene = {
        let scene = PhysicsTagScene()
        scene.scaleMode = .resizeFill
        return scene
    }()

    @State private var usesDeviceMotion = true
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        SpriteView(scene: scene)
            .backgroundExtensionEffect()
            .overlay(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(isOn: $usesDeviceMotion) {
                        Text(verbatim: "Motion")
                    }
                    Button {
                        scene.resetSimulation()
                    } label: {
                        Label {
                            Text(verbatim: "Reset")
                        } icon: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
                .fixedSize()
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding()
            }
            .onChange(of: usesDeviceMotion) { _, newValue in
                scene.usesDeviceMotion = newValue
            }
            .onChange(of: colorScheme) { _, _ in
                scene.backgroundColor = .systemBackground
            }
            .tint(.blue)
    }
}

#elseif os(macOS)

// MARK: - PhysicsTagScreen

@Metadata(title: .screenPhysicsTagTitle, description: .screenPhysicsTagDescription, tags: [.animation])
struct PhysicsTagScreen: View {
    var body: some View {
        Text(verbatim: "This feature is not available on macOS")
            .foregroundStyle(.secondary)
    }
}

#endif

#Preview {
    PhysicsTagScreen()
}
