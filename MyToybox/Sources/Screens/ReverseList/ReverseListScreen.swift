import SwiftUI

struct ReverseListScreen: View {
    @State private var items = [Item()]

    var body: some View {
        NavigationStack {
            List(items) { item in
                RowContent(item: item)
                    .listRowSeparator(.hidden)
                    .rotationEffect(.radians(.pi))
            }
            .rotationEffect(.radians(.pi))
            .scrollIndicators(.hidden)
            .animation(.default, value: items)
            .listStyle(.plain)
            .toolbar {
                Button("plus", systemImage: "plus") {
                    items.insert(Item(), at: 0)
                }
                Button("minus", systemImage: "minus") {
                    if !items.isEmpty {
                        items.removeFirst()
                    }
                }
            }
        }
    }
}

private struct RowContent: View {
    var item: Item

    var color: Color {
        Color(
            hue: Double(abs(item.hashValue)) / Double(Int.max),
            saturation: 0.8,
            brightness: 0.8
        )
    }

    var body: some View {
        HStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(color)
            Text("Hello, world!")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.secondary)
        .clipShape(.rect(cornerRadius: 10))
        .font(.title)
        .fontWeight(.bold)
    }
}

private struct Item: Identifiable, Hashable {
    var id = UUID()
}

#Preview {
    ReverseListScreen()
}
