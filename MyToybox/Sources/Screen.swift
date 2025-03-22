import SwiftUI

enum Screen: String, CaseIterable, Hashable {
    case first
}

extension Screen: Identifiable {
    var id: String {
        rawValue
    }
}

extension Screen {
    var displayTitle: String {
        rawValue.capitalized
    }
}

extension Screen: View {
    var body: some View {
        switch self {
        case .first:
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text(displayTitle)
            }
        }
    }
}

#Preview {
    RootView()
}
