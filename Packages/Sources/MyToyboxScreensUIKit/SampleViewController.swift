import UIKit

/// A simple UIViewController that invalidates its intrinsic content size
/// when the preferred content size category (Dynamic Type) changes.
public final class SampleViewController: UIViewController {
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public convenience init() {
        self.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let traits = [UITraitPreferredContentSizeCategory.self]
        registerForTraitChanges(traits) { (self: Self, _) in
            self.view.invalidateIntrinsicContentSize()
        }
    }
}
