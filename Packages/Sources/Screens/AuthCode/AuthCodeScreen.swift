import MyToyboxCore
import SwiftUI

#if os(iOS)
/// A screen that presents an authentication code (OTP) input interface.
///
/// Displays six input fields for numeric digits. The entered code is printed to the console whenever it changes.
@Metadata(title: .screenAuthCodeTitle, description: .screenAuthCodeDescription, tags: [])
public struct AuthCodeScreen: View {
    public init() {}

    /// The digits entered by the user, updated in real-time.
    @State private var digits: [Int] = []

    public var body: some View {
        AuthCodeInput(digits: $digits, count: 6)
            .padding()
            .ignoresSafeArea(.keyboard)
            .onChange(of: digits) { _, digits in
                print(digits.map(String.init).joined())
            }
    }
}

/// A reusable OTP input view composed of multiple circular text fields.
/// Handles input, focus movement, and digit extraction automatically.
private struct AuthCodeInput: View {
    /// A zero-width space used as a placeholder for empty fields.
    private static let space = "\u{200B}"
    /// A binding to the digits array from the parent view.
    @Binding private var digits: [Int]
    /// The raw text values displayed in each text field.
    @State private var values: [String]
    /// The currently focused text field index.
    @FocusState private var focusedIndex: Int?

    /// Initializes the view with a binding to the digits and the number of expected digits.
    /// - Parameters:
    ///   - digits: A binding to the output digits array.
    ///   - count: The number of input fields to display.
    init(digits: Binding<[Int]>, count: Int) {
        _digits = digits
        self.values = Array(repeating: Self.space, count: count)
    }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0 ..< values.count, id: \.self) { index in
                Circle()
                    .fill(.orange)
                    .overlay {
                        TextField(text: $values[index]) {
                            Text(verbatim: "")
                        }
                        .textContentType(.oneTimeCode)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .focused($focusedIndex, equals: index)
                        .font(.title.monospacedDigit())
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                        .tint(.white)
                    }
            }
        }
        .onChange(of: values) { _, newValues in
            update(with: newValues)
        }
        .onAppear {
            // Automatically focus the first input field when the view appears.
            focusedIndex = 0
        }
    }

    /// Updates internal state based on the current text field values.
    /// Handles filtering, sanitizing input, auto-advancing or retreating focus, and digit extraction.
    private func update(with values: [String]) {
        var values = values
        guard let focusedIndex else { return }

        // Handle backspacing by clearing the previous field if needed.
        if values[focusedIndex].isEmpty, focusedIndex > 0 {
            values[focusedIndex - 1] = Self.space
        }

        // Concatenate numeric characters only.
        let joined = values
            .map { $0.filter { $0.isASCII && $0.isNumber } }
            .reduce(into: String()) { $0 += $1 }

        // Reconstruct the field values with valid input and padding.
        self.values = joined
            .prefix(values.count)
            .map { Self.space + String($0) }
            + Array(repeating: Self.space, count: max(values.count - joined.count, 0))

        // Adjust the focus based on input state.
        self.focusedIndex = values[focusedIndex].isEmpty
            ? max(focusedIndex - 1, 0)
            : min(joined.count, values.count - 1)

        // Update the bound digits array.
        digits = joined.compactMap { Int(String($0)) }
    }
}

#Preview {
    AuthCodeScreen()
}

#elseif os(macOS)
@Metadata(title: .screenAuthCodeTitle, description: .screenAuthCodeDescription, tags: [])
public struct AuthCodeScreen: View {
    public init() {}

    public var body: some View {
        Text(verbatim: "This feature is not available on macOS")
            .foregroundStyle(.secondary)
    }
}
#endif
