import SwiftUI

struct MatchTopWidthScreen: View {
    @State var isInfinityWidth = false
    @State var isFixedSize = false

    var body: some View {
        Form {
            Section {
                Toggle("maxWidth: .infinity", isOn: $isInfinityWidth.animation())
                Toggle("fixedSize", isOn: $isFixedSize.animation())
            }
            Section {
                Sample(isInfinityWidth: isInfinityWidth, isFixedSize: isFixedSize)
                    .backgroundStyle(linearGradient)
                    .listRowInsets(.init(top: 12, leading: 0, bottom: 12, trailing: 0))
            }
        }
        .tint(.blue)
    }

    var linearGradient: some ShapeStyle {
        .linearGradient(
            colors: [
                isInfinityWidth ? blue : isFixedSize ? purple : .gray,
                isFixedSize ? purple : isInfinityWidth ? blue : .gray
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var blue: Color { .init(hue: 207/360, saturation: 0.88, brightness: 0.88) }
    var purple: Color { .init(hue: 302/360, saturation: 1.00, brightness: 1.00) }
}

private struct Sample: View {
    let isInfinityWidth: Bool
    let isFixedSize: Bool

    var body: some View {
        VStack {
            HStack {
                Group {
                    Label("PS", systemImage: "playstation.logo")
                    Label("XBox", systemImage: "xbox.logo")
                    Image(systemName: "gamecontroller.fill")
                }
                .frame(maxHeight: .infinity)
                .modifier(MyStyle())
            }
            .fixedSize()

            Label("message", systemImage: "message.badge.filled.fill")
                .frame(maxWidth: isInfinityWidth ? .infinity : nil)
                .modifier(MyStyle())
        }
        .fontWeight(.bold)
        .fixedSize(horizontal: isFixedSize, vertical: true)
        .border(.red, width: 1)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct MyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.background, in: .capsule)
            .foregroundStyle(.white)
    }
}

#Preview {
    MatchTopWidthScreen()
}
