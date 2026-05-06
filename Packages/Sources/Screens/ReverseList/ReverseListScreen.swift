import MyToyboxCore
import SwiftUI

// MARK: - ReverseListScreen

/// A SwiftUI screen that displays a vertically reversed list,
/// where the most recent items appear at the bottom visually.
///
/// This effect is achieved by applying a `.rotationEffect(.pi)` to both the `List`
/// and its rows, effectively inverting the scroll direction while preserving layout order.
@Metadata(title: .screenReverseListTitle, description: .screenReverseListDescription, tags: [.layout])
public struct ReverseListScreen: View {
    public init() {}

    /// The array of list items, with new elements added to the beginning.
    @State private var items = [Item()]

    public var body: some View {
        NavigationStack {
            List(items) { item in
                RowContent(item: item)
                    .listRowSeparator(.hidden)
                    // Flip the row content
                    .rotationEffect(.radians(.pi))
            }
            // Flip the entire list
            .rotationEffect(.radians(.pi))
            .scrollIndicators(.hidden)
            .animation(.default, value: items)
            .listStyle(.plain)
            .toolbar {
                // Adds a new item to the top of the list (bottom of UI)
                Button {
                    items.insert(Item(), at: 0)
                } label: {
                    Label {
                        Text(verbatim: "plus")
                    } icon: {
                        Image(systemName: "plus")
                    }
                }
                // Removes the first item (top of data, bottom of UI)
                Button {
                    if !items.isEmpty {
                        items.removeFirst()
                    }
                } label: {
                    Label {
                        Text(verbatim: "minus")
                    } icon: {
                        Image(systemName: "minus")
                    }
                }
            }
        }
    }
}

// MARK: - RowContent

/// A single row in the reversed list, showing a colored icon and static text.
///
/// The color of each row is generated based on the hash value of the `Item`.
private struct RowContent: View {
    var item: Item

    /// Generates a deterministic color based on the item's hash value.
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
            Text(verbatim: "Hello, world!")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.secondary)
        .clipShape(.rect(cornerRadius: 10))
        .font(.title)
        .fontWeight(.bold)
    }
}

// MARK: - Item

/// A simple identifiable data model used for list rendering.
private struct Item: Identifiable, Hashable {
    var id = UUID()
}

#Preview {
    ReverseListScreen()
}
