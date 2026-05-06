#if os(iOS)
import UIKit

final class SampleViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    convenience init() {
        self.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let traits = [UITraitPreferredContentSizeCategory.self]
        registerForTraitChanges(traits) { (self: Self, _) in
            self.view.invalidateIntrinsicContentSize()
        }
    }
}
#endif
