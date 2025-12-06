import SwiftUI

struct UnevenRoundedRectangle1Screen: View {
    var body: some View {
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

private struct HelloWorld: View {
    var body: some View {
        Text("Hello, world!")
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.blue.gradient)
    }
}

#Preview {
    UnevenRoundedRectangle1Screen()
}
