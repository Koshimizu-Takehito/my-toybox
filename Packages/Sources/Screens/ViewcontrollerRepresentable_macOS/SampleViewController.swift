#if os(macOS)
import AppKit

final class SampleViewController: NSViewController {
    convenience init() {
        self.init(nibName: String(describing: Self.self), bundle: .module)
    }
}
#endif
