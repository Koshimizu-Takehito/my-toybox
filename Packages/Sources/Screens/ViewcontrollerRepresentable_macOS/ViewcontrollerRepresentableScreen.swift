import MyToyboxCore
import SwiftUI

#if os(macOS)
import AppKit

// MARK: - ViewControllerRepresentableScreen

/// A SwiftUI screen that demonstrates the integration of an AppKit NSViewController
/// using NSViewControllerRepresentable, loading its view hierarchy from a macOS XIB.
@Metadata(title: .screenViewControllerRepresentableTitle, description: .screenViewControllerRepresentableDescription, tags: [.layout])
public struct ViewcontrollerRepresentableScreen: View {
    public init() {}

    public var body: some View {
        VStack {
            ViewControllerRepresentable(SampleViewController())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))
                .padding()
        }
    }
}

// MARK: - ViewControllerRepresentable

private struct ViewControllerRepresentable<ViewController: NSViewController>: NSViewControllerRepresentable {
    private let viewController: () -> ViewController

    init(_ viewController: @autoclosure @escaping () -> ViewController) {
        self.viewController = viewController
    }

    func makeNSViewController(context _: Context) -> ViewController {
        viewController()
    }

    func updateNSViewController(_: ViewController, context _: Context) {}
}

// MARK: - Preview

#Preview {
    ViewcontrollerRepresentableScreen()
}

#elseif os(iOS)
@Metadata(title: .screenViewControllerRepresentableTitle, description: .screenViewControllerRepresentableDescription, tags: [.layout])
public struct ViewcontrollerRepresentableScreen: View {
    public init() {}

    public var body: some View {
        Text(verbatim: "This module is for macOS")
            .foregroundStyle(.secondary)
    }
}
#endif
