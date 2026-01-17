import SwiftUI

#if os(iOS)

// MARK: - ViewControllerRepresentableScreen

/// A SwiftUI screen that demonstrates the integration of a UIKit UIViewController
/// using UIViewControllerRepresentable, and updates its layout in response to Dynamic Type changes.
@Metadata(title: "Uiviewcontrollerrepresentable", description: "UIViewControllerRepresentableのレイアウト処理のサンプル", tags: [.layout])
struct ViewcontrollerRepresentableScreen: View {
    @State private var tapCount = 0

    var body: some View {
        // Compute the current DynamicTypeSize based on the tap count.
        var currentDynamicTypeSize: DynamicTypeSize {
            let allSizes = DynamicTypeSize.allCases
            return allSizes[tapCount % allSizes.count]
        }

        VStack {
            // Embed the custom UIViewController into SwiftUI with layout constraints.
            ViewControllerRepresentable<SampleViewController>()
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
    func makeUIViewController(context _: Context) -> ViewController {
        // Load from .xib in SPM module bundle using type name
        ViewController(nibName: String(describing: ViewController.self), bundle: .module)
    }

    func updateUIViewController(_: ViewController, context _: Context) {
        // No-op: no external updates needed
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiViewController: ViewController,
        context _: Context
    ) -> CGSize? {
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

// MARK: - SampleViewController

/// A simple UIViewController that invalidates its intrinsic content size
/// when the preferred content size category (Dynamic Type) changes.
final class SampleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let traits = [UITraitPreferredContentSizeCategory.self]
        registerForTraitChanges(traits) { (self: Self, _) in
            self.view.invalidateIntrinsicContentSize()
        }
    }
}

// MARK: - Preview

#Preview {
    ViewcontrollerRepresentableScreen()
}

#elseif os(macOS)
@Metadata(title: "Uiviewcontrollerrepresentable", description: "UIViewControllerRepresentableのレイアウト処理のサンプル", tags: [.layout])
struct ViewcontrollerRepresentableScreen: View {
    var body: some View {
        Text("This feature is not available on macOS")
            .foregroundStyle(.secondary)
    }
}
#endif
