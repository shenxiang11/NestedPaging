import UIKit

final class DemoNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        visibleViewController
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        visibleViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
}
