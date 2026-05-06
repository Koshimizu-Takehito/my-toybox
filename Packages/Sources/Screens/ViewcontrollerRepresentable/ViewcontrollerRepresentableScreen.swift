import MyToyboxCore
import SwiftUI

#if os(iOS)

// MARK: - ViewControllerRepresentableScreen

/// A SwiftUI screen that demonstrates the integration of a UIKit UIViewController
/// using UIViewControllerRepresentable, and updates its layout in response to Dynamic Type changes.
@Metadata(title: .screenViewControllerRepresentableTitle, description: .screenViewControllerRepresentableDescription, tags: [.layout])
public struct ViewcontrollerRepresentableScreen: View {
    public init() {}

    @State private var tapCount = 0

    public var body: some View {
        // Compute the current DynamicTypeSize based on the tap count.
        var currentDynamicTypeSize: DynamicTypeSize {
            let allSizes = DynamicTypeSize.allCases
            return allSizes[tapCount % allSizes.count]
        }

        VStack {
            // Embed the custom UIViewController into SwiftUI with layout constraints.
            ViewControllerRepresentable(SampleViewController())
                .fixedSize()
                .padding()
                .background(Color.blue.secondary)
                .clipShape(.rect(cornerRadius: 10))
                .contentShape(.rect(cornerRadius: 10))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
                .environment(\.dynamicTypeSize, currentDynamicTypeSize)
                .tint(.pink)
                .onTapGesture {
                    tapCount += 1 // Cycle through available DynamicTypeSize values
                }

            // Display the current dynamic type size label
            Text(String(describing: currentDynamicTypeSize))
        }
    }
}

// MARK: - ViewControllerRepresentable

/// A generic wrapper for any UIViewController to be used inside SwiftUI.
/// Implements layout measurement using `systemLayoutSizeFitting`.
private struct ViewControllerRepresentable<ViewController: UIViewController>: UIViewControllerRepresentable {
    private let viewController: () -> ViewController

    init(_ viewController: @autoclosure @escaping () -> ViewController) {
        self.viewController = viewController
    }

    func makeUIViewController(context _: Context) -> ViewController {
        viewController()
    }

    func updateUIViewController(_: ViewController, context _: Context) {
        // No-op: no external updates needed
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: ViewController, context _: Context) -> CGSize? {
        // Provide a size fitting logic using Auto Layout from UIKit
        let proposedSize = CGSize(
            width: proposal.width ?? UIView.noIntrinsicMetric,
            height: proposal.height ?? UIView.noIntrinsicMetric
        )
        return uiViewController.view.systemLayoutSizeFitting(
            proposedSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .defaultLow
        )
    }
}

// MARK: - Preview

#Preview {
    ViewcontrollerRepresentableScreen()
}

#elseif os(macOS)
@Metadata(title: .screenViewControllerRepresentableTitle, description: .screenViewControllerRepresentableDescription, tags: [.layout])
public struct ViewcontrollerRepresentableScreen: View {
    public init() {}

    public var body: some View {
        Text(verbatim: "This feature is not available on macOS")
            .foregroundStyle(.secondary)
    }
}
#endif
