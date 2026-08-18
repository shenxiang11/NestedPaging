import UIKit

@MainActor
protocol NestedPagingListContainerViewDelegate: AnyObject {
    func numberOfLists(in containerView: NestedPagingListContainerView) -> Int
    func listContainerView(_ containerView: NestedPagingListContainerView, initListAt index: Int) -> NestedPagingListViewDelegate
    func listContainerView(_ containerView: NestedPagingListContainerView, listDidScrollTo index: Int)
    func listContainerViewDidScroll(_ containerView: NestedPagingListContainerView)
}

/// Horizontal pager that lazily hosts child lists.
@MainActor
public final class NestedPagingListContainerView: UIView, UIScrollViewDelegate {
    weak var delegate: NestedPagingListContainerViewDelegate?

    public var scrollView: UIScrollView { pagingScrollView }

    public private(set) var currentIndex = 0
    public private(set) var validLists: [Int: NestedPagingListViewDelegate] = [:]

    private let pagingScrollView: NestedPagingContainerScrollView = {
        let scrollView = NestedPagingContainerScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        return scrollView
    }()

    private var listCount = 0
    private var lastLayoutWidth: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        pagingScrollView.delegate = self
        pagingScrollView.shouldBegin = { [weak self] pan in
            self?.shouldBeginHorizontalPan(pan) ?? true
        }
        addSubview(pagingScrollView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    public func setCurrentIndex(_ index: Int, animated: Bool) {
        guard listCount > 0, (0..<listCount).contains(index) else { return }
        let width = bounds.width
        guard width > 0 else {
            currentIndex = index
            return
        }
        loadListIfNeeded(at: index)
        pagingScrollView.setContentOffset(CGPoint(x: CGFloat(index) * width, y: 0), animated: animated)
        if !animated {
            updateCurrentIndexIfNeeded()
        }
    }

    public func currentList() -> NestedPagingListViewDelegate? {
        validLists[currentIndex]
    }

    func reloadData() {
        validLists.values.forEach { $0.listView().removeFromSuperview() }
        validLists.removeAll()
        listCount = delegate?.numberOfLists(in: self) ?? 0
        currentIndex = min(currentIndex, max(listCount - 1, 0))
        setNeedsLayout()
        layoutIfNeeded()
        loadListIfNeeded(at: currentIndex)
        notifyCurrentIndex()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        pagingScrollView.frame = bounds
        pagingScrollView.contentSize = CGSize(width: bounds.width * CGFloat(listCount), height: bounds.height)

        for (index, list) in validLists {
            list.listView().frame = pageFrame(at: index)
        }

        if bounds.width > 0, bounds.width != lastLayoutWidth {
            lastLayoutWidth = bounds.width
            pagingScrollView.setContentOffset(CGPoint(x: CGFloat(currentIndex) * bounds.width, y: 0), animated: false)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.bounds.width > 0 else { return }
        let progress = scrollView.contentOffset.x / scrollView.bounds.width
        let nearby = Int(progress.rounded())
        loadListIfNeeded(at: nearby)
        loadListIfNeeded(at: nearby - 1)
        loadListIfNeeded(at: nearby + 1)
        delegate?.listContainerViewDidScroll(self)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentIndexIfNeeded()
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentIndexIfNeeded()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateCurrentIndexIfNeeded()
        }
    }

    private func shouldBeginHorizontalPan(_ pan: UIPanGestureRecognizer) -> Bool {
        let velocity = pan.velocity(in: pagingScrollView)
        guard abs(velocity.x) > abs(velocity.y) else { return false }

        if currentIndex == 0, velocity.x > 0 {
            return false
        }
        if currentIndex == listCount - 1, velocity.x < 0 {
            return false
        }
        return true
    }

    private func updateCurrentIndexIfNeeded() {
        guard pagingScrollView.bounds.width > 0 else { return }
        let index = Int((pagingScrollView.contentOffset.x / pagingScrollView.bounds.width).rounded())
        let clamped = min(max(index, 0), max(listCount - 1, 0))
        guard clamped != currentIndex else { return }
        currentIndex = clamped
        notifyCurrentIndex()
    }

    private func notifyCurrentIndex() {
        loadListIfNeeded(at: currentIndex)
        delegate?.listContainerView(self, listDidScrollTo: currentIndex)
    }

    private func loadListIfNeeded(at index: Int) {
        guard (0..<listCount).contains(index), validLists[index] == nil else { return }
        guard let list = delegate?.listContainerView(self, initListAt: index) else { return }
        validLists[index] = list
        let listView = list.listView()
        listView.frame = pageFrame(at: index)
        pagingScrollView.addSubview(listView)
    }

    private func pageFrame(at index: Int) -> CGRect {
        CGRect(x: CGFloat(index) * bounds.width, y: 0, width: bounds.width, height: bounds.height)
    }
}

@MainActor
final class NestedPagingContainerScrollView: UIScrollView {
    var shouldBegin: ((UIPanGestureRecognizer) -> Bool)?

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGestureRecognizer, let pan = gestureRecognizer as? UIPanGestureRecognizer {
            return shouldBegin?(pan) ?? super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
