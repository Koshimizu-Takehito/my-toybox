import MetadatasMacros
import MyToyboxCore
import ScreenMacros
import SwiftUI

// MARK: - MockScreen

@Screens
@Metadatas
public enum MockScreen: String, MyToyboxScreen {
    case mockA
    case mockB
}

// MARK: - MockA

@Metadata(title: "Mock Screen A", description: "A mock screen for previews", tags: [])
struct MockA: View {
    var body: some View {
        Color.blue.overlay {
            Text(verbatim: "Mock A")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)
        }
    }
}

// MARK: - MockB

@Metadata(title: "Mock Screen B", description: "A mock screen for previews", tags: [])
struct MockB: View {
    var body: some View {
        Color.green.overlay {
            Text(verbatim: "Mock B")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)
        }
    }
}
