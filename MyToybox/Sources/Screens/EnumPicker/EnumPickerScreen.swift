import SwiftUI

struct EnumPickerScreen: View {
    @State private var leading: Font.Leading = .standard
    @State private var design: Font.Design = Font.Design.default
    @State private var dynamicTypeSize: DynamicTypeSize = .medium

    var body: some View {
        VStack {
            EnumPicker(selection: $leading)
            EnumPicker(selection: $design)
            EnumPicker(selection: $dynamicTypeSize)
        }
        .dynamicTypeSize(dynamicTypeSize)
        .padding()
    }
}

struct EnumPicker<Enum>: View where Enum: CaseIterable & Hashable, Enum == Enum.AllCases.Element, Enum.AllCases: RandomAccessCollection {
    @Binding var selection: Enum

    var body: some View {
        Picker(String(describing: Enum.self), selection: $selection) {
            ForEach(Enum.allCases, id: \.self) { value in
                Text("\(value)")
                    .tag(value)
            }
        }
    }
}

extension Font.Leading: @retroactive CaseIterable {
    public static let allCases: [Self] = [
        .loose,
        .standard,
        .tight,
    ]
}

extension Font.Design: @retroactive CaseIterable {
    public static let allCases: [Self] = [
        .default,
        .serif,
        .rounded,
        .monospaced,
    ]
}

#Preview {
    EnumPickerScreen()
}
