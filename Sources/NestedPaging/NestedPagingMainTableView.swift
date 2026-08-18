import UIKit

/// Outer table that hosts the header, pin bar, and list container.
///
/// The main table and the current child list recognize the same vertical pan.
/// Offset locking in `NestedPagingView` then decides who actually moves.
@MainActor
public final class NestedPagingMainTableView: UITableView, UIGestureRecognizerDelegate {
    public var shouldRecognizeSimultaneously: ((UIGestureRecognizer, UIGestureRecognizer) -> Bool)?

    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        panGestureRecognizer.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let shouldRecognizeSimultaneously {
            return shouldRecognizeSimultaneously(gestureRecognizer, otherGestureRecognizer)
        }

        return gestureRecognizer is UIPanGestureRecognizer
            && otherGestureRecognizer is UIPanGestureRecognizer
    }
}
