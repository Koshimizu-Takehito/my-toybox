import SwiftUI

// MARK: - EnumPickerScreen

/// A demonstration screen that allows users to choose various typography-related enum values.
/// It displays three pickers for:
/// - `Font.Leading`: line height spacing
/// - `Font.Design`: font design
/// - `DynamicTypeSize`: dynamic type scaling size
struct EnumPickerScreen: View {
    @State private var leading: Font.Leading = .standard
    @State private var design: Font.Design = Font.Design.default
    @State private var dynamicTypeSize: DynamicTypeSize = .medium

    var body: some View {
        VStack {
            // Picker for Font.Leading options
            EnumPicker(selectedValue: $leading, allEnumCases: Font.Leading.allCases)

            // Picker for Font.Design options
            EnumPicker(selectedValue: $design, allEnumCases: Font.Design.allCases)

            // Picker for DynamicTypeSize options
            EnumPicker(selectedValue: $dynamicTypeSize, allEnumCases: DynamicTypeSize.allCases)
        }
        .dynamicTypeSize(dynamicTypeSize)
        .padding()
    }
}

// MARK: - EnumPicker

/// A generic Picker view that allows selection from any Hashable enum type.
/// - Parameters:
///   - selection: The currently selected enum value.
///   - allEnumCases: All possible enum cases to be displayed.
struct EnumPicker<Enum>: View where Enum: Hashable {
    @Binding var selectedValue: Enum
    var allEnumCases: [Enum]

    var body: some View {
        Picker(String(describing: Enum.self), selection: $selectedValue) {
            ForEach(allEnumCases, id: \.self) { value in
                Text(String(describing: value))
                    .tag(value)
            }
        }
    }
}

// MARK: - Font.Leading + AllCases support

/// Provides an array of all Font.Leading cases.
/// Note: Font.Leading does not conform to CaseIterable by default.
private extension Font.Leading {
    static let allCases: [Self] = [
        .loose,
        .standard,
        .tight,
    ]
}

// MARK: - Font.Design + AllCases support

/// Provides an array of all Font.Design cases.
/// Note: Font.Design does not conform to CaseIterable by default.
private extension Font.Design {
    static let allCases: [Self] = [
        .default,
        .serif,
        .rounded,
        .monospaced,
    ]
}

// MARK: - Preview

#Preview {
    EnumPickerScreen()
}
