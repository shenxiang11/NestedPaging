import UIKit

extension UIView {
    func demoPreferredHeight(forWidth width: CGFloat, fallback: CGFloat) -> CGFloat {
        guard width > 0 else { return fallback }
        return systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
}
