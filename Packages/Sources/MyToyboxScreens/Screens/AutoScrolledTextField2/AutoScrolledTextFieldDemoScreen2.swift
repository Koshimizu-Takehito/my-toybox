import SwiftUI

// MARK: - AutoScrolledTextFieldDemoScreen2

/// Demo screen that showcases the AutoScrolledTextField2 component.
/// Presents a single screen with an automatically scrolling email text field.
@Metadata(title: "Auto Scrolled TextField 2", description: "テキストフィールドに入力した時に自動でスクロール 2", tags: [])
struct AutoScrolledTextFieldDemoScreen2: View {
    var body: some View {
        #if os(iOS) || os(tvOS)
        AutoScrolledTextField2()
        #elseif os(macOS)
        EmptyView()
        #endif
    }
}

#if os(iOS) || os(tvOS)

// MARK: - AutoScrolledTextField2

/// A SwiftUI view demonstrating a text field that auto-scrolls into view when focused,
/// preventing the keyboard from covering the input area.
/// Useful for forms where fields may be pushed off-screen by the keyboard.
struct AutoScrolledTextField2: View {
    /// The user's input for the email address.
    @State private var email: String = ""
    /// Tracks whether the text field is currently focused.
    @FocusState private var focused: Bool
    /// Namespace used to identify the submit button for scroll targeting.
    @Namespace private var buttonID

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack(alignment: .leading) {
                    // Spacer to simulate content above the text field.
                    Color.clear
                        .frame(height: 400)

                    // Email input field.
                    TextField("Email Address", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focused)
                        .submitLabel(.done)
                        .padding(.vertical)

                    // Dummy submit button.
                    Button(action: {}) {
                        Text("Submit")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, idealHeight: 44, alignment: .center)
                            .background(.tint.tertiary)
                            .clipShape(.capsule)
                    }
                    .padding(.bottom)
                    .id(buttonID)
                }
                .padding()
                .ignoresSafeArea(.container, edges: [.bottom])
            }
            // When the text field is focused, scroll the submit button into view.
            .onChange(of: focused) { _, focused in
                if focused {
                    Task {
                        // Wait for the keyboard animation to finish before scrolling.
                        try await Task.sleep(nanoseconds: 300_000_000)
                        withAnimation(.snappy) {
                            scrollView.scrollTo(buttonID, anchor: .bottom)
                        }
                    }
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                focused = true
            }
            .tint(.blue)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#elseif os(macOS)
#endif

// MARK: - Preview

#Preview {
    AutoScrolledTextFieldDemoScreen2()
}
