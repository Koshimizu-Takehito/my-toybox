import MyToyboxCore
import SwiftUI

// MARK: - UnevenRoundedRectangle1Screen

@Metadata(title: .screenUnevenRoundedRectanglePerSideTitle, description: .screenUnevenRoundedRectanglePerSideDescription, tags: [])
public struct UnevenRoundedRectangle1Screen: View {
    public init() {}

    public var body: some View {
        Group {
            HelloWorld()
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 80,
                    bottomTrailingRadius: 80
                ))
            HelloWorld()
                .clipShape(.rect(
                    topLeadingRadius: 80,
                    bottomTrailingRadius: 80
                ))
        }
        .padding(.horizontal)
        .padding()
    }
}

// MARK: - HelloWorld

private struct HelloWorld: View {
    var body: some View {
        Text(verbatim: "Hello, world!")
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.blue.gradient)
    }
}

#Preview {
    UnevenRoundedRectangle1Screen()
}
