import SwiftUI

struct AuthCodeScreen: View {
    @State private var digits: [Int] = []

    var body: some View {
        AuthCodeInput(digits: $digits, count: 6)
            .padding()
            .ignoresSafeArea(.keyboard)
            .onChange(of: digits) { _, digits in
                print(digits.map(String.init).joined())
            }
    }
}

private struct AuthCodeInput: View {
    private static let space = "\u{200B}"

    @Binding private var digits: [Int]
    @State private var values: [String]
    @FocusState private var position: Int?

    init(digits: Binding<[Int]>, count: Int) {
        _digits = digits
        values = Array(repeating: AuthCodeInput.space, count: count)
    }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0 ..< values.count, id: \.self) { index in
                Circle()
                    .fill(.orange)
                    .overlay {
                        TextField("", text: $values[index])
                            .textContentType(.oneTimeCode)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .focused($position, equals: index)
                            .font(.title.monospacedDigit())
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                            .tint(.white)
                    }
            }
        }
        .onChange(of: values) { _, newDigits in
            update(with: newDigits)
        }
        .onAppear {
            position = 0
        }
    }

    private func update(with values: [String]) {
        var values = values
        guard let position else { return }

        if values[position].isEmpty, position > 0 {
            values[position - 1] = AuthCodeInput.space
        }
        let joined = values
            .map { $0.filter { $0.isASCII && $0.isNumber } }
            .reduce(into: String()) { $0 += $1 }
        self.values = joined
            .prefix(values.count)
            .map { AuthCodeInput.space + String($0) }
            + [String](repeating: AuthCodeInput.space, count: max(values.count - joined.count, 0))
        self.position = values[position].isEmpty
            ? max(position - 1, 0)
            : min(joined.count, values.count - 1)
        digits = joined.compactMap { Int(String($0)) }
    }
}

#Preview {
    AuthCodeScreen()
}
