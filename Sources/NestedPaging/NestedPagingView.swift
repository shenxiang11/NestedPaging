import UIKit

/// Nested paging container: a header that scrolls away, a pin bar that sticks,
/// and horizontally paged child lists that take over vertical scrolling.
///
/// Vertical handoff:
/// 1. Main table and child list recognize the same pan.
/// 2. While the header is still visible, the child list is locked at 0.
/// 3. After the pin bar reaches the top, the main table is locked and the child list scrolls.
@MainActor
public final class NestedPagingView: UIView, UITableViewDataSource, UITableViewDelegate, NestedPagingListContainerViewDelegate {
    public weak var delegate: NestedPagingViewDelegate?

    /// Distance from the top where the pin bar should stick.
    /// When `automaticallyAdjustsPinSectionHeaderVerticalOffset` is true, this tracks `safeAreaInsets.top`.
    public var pinSectionHeaderVerticalOffset: CGFloat = 0 {
        didSet {
            guard oldValue != pinSectionHeaderVerticalOffset else { return }
            refreshListContainerHeight()
        }
    }

    /// Stick the pin bar just below the navigation bar / status bar. Default is `true`.
    public var automaticallyAdjustsPinSectionHeaderVerticalOffset = true

    /// Adds the view's bottom / horizontal safe area to each child list. Default is `true`.
    public var automaticallyAdjustsListContentInset = true

    public var mainTableViewDidScroll: ((UIScrollView) -> Void)?
    public var listContainerDidScroll: ((NestedPagingListContainerView) -> Void)?
    public var didChangeListIndex: ((Int) -> Void)?

    public let mainTableView = NestedPagingMainTableView(frame: .zero, style: .plain)
    public let listContainerView = NestedPagingListContainerView()

    public private(set) weak var currentScrollingListView: UIScrollView?
    public private(set) var currentListIndex = 0

    private var lastBounds: CGRect = .zero
    private var appliedListBottomInset: CGFloat = 0
    private var appliedListLeftInset: CGFloat = 0
    private var appliedListRightInset: CGFloat = 0
    private let listCellReuseIdentifier = "NestedPagingListCell"

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureMainTableView()
        listContainerView.delegate = self
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    public func reloadData() {
        configureTableHeaderView()
        listContainerView.reloadData()
        currentScrollingListView = listContainerView.currentList()?.listScrollView()
        mainTableView.reloadData()
        updateScrollingMode()
    }

    public func setCurrentListIndex(_ index: Int, animated: Bool) {
        listContainerView.setCurrentIndex(index, animated: animated)
    }

    public var currentListScrollProgress: CGFloat {
        let width = listContainerView.scrollView.bounds.width
        guard width > 0 else { return CGFloat(currentListIndex) }
        return listContainerView.scrollView.contentOffset.x / width
    }

    public var mainTableViewMaxContentOffsetY: CGFloat {
        let headerHeight = delegate?.tableHeaderViewHeight(in: self) ?? 0
        return max(headerHeight - pinSectionHeaderVerticalOffset, 0)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        mainTableView.frame = bounds

        if bounds != lastBounds {
            lastBounds = bounds
            configureTableHeaderView()
            refreshListContainerHeight()
            updateScrollingMode()
        }
    }

    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        syncSafeAreaAdjustments()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            syncSafeAreaAdjustments()
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === mainTableView else { return }
        if !usesMainTableScrolling {
            processMainTableViewDidScroll(scrollView)
        }
        mainTableViewDidScroll?(scrollView)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        listContainerSize.height
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        listContainerSize.height
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listCellReuseIdentifier, for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.contentView.clipsToBounds = true

        if listContainerView.superview !== cell.contentView {
            listContainerView.removeFromSuperview()
            cell.contentView.addSubview(listContainerView)
        }
        listContainerView.frame = cell.contentView.bounds
        listContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        delegate?.heightForPinSectionHeader(in: self) ?? 0
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        delegate?.heightForPinSectionHeader(in: self) ?? 0
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        delegate?.viewForPinSectionHeader(in: self)
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    func numberOfLists(in containerView: NestedPagingListContainerView) -> Int {
        delegate?.numberOfLists(in: self) ?? 0
    }

    func listContainerView(_ containerView: NestedPagingListContainerView, initListAt index: Int) -> NestedPagingListViewDelegate {
        let list = delegate?.pagingView(self, initListAt: index)
            ?? EmptyNestedPagingListView()
        if list.listPreferredContentHeight(forWidth: max(bounds.width, 1)) == nil {
            list.listViewDidScrollCallback { [weak self] scrollView in
                self?.processListViewDidScroll(scrollView)
            }
            applySafeAreaInsetsToNewList(list.listScrollView())
        }
        return list
    }

    func listContainerView(_ containerView: NestedPagingListContainerView, listDidScrollTo index: Int) {
        currentListIndex = index
        currentScrollingListView = containerView.currentList()?.listScrollView()
        updateScrollsToTop()
        didChangeListIndex?(index)
    }

    func listContainerViewDidScroll(_ containerView: NestedPagingListContainerView) {
        listContainerDidScroll?(containerView)
    }

    private func configureMainTableView() {
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.separatorStyle = .none
        mainTableView.showsVerticalScrollIndicator = false
        mainTableView.showsHorizontalScrollIndicator = false
        mainTableView.allowsSelection = false
        mainTableView.estimatedRowHeight = 0
        mainTableView.estimatedSectionHeaderHeight = 0
        mainTableView.estimatedSectionFooterHeight = 0
        mainTableView.sectionHeaderTopPadding = 0
        mainTableView.contentInsetAdjustmentBehavior = .never
        mainTableView.backgroundColor = .systemBackground
        mainTableView.scrollsToTop = false
        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: listCellReuseIdentifier)
        mainTableView.shouldRecognizeSimultaneously = { [weak self] _, other in
            self?.shouldRecognizeSimultaneously(with: other) ?? false
        }
        addSubview(mainTableView)
    }

    private func configureTableHeaderView() {
        guard let delegate, bounds.width > 0 else { return }
        let header = delegate.tableHeaderView(in: self)
        let height = delegate.tableHeaderViewHeight(in: self)
        header.frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)
        mainTableView.tableHeaderView = header
    }

    private func processMainTableViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffsetY = mainTableViewMaxContentOffsetY

        if let list = currentScrollingListView, list.contentOffset.y > -list.adjustedContentInset.top {
            scrollView.contentOffset.y = maxOffsetY
        }

        if scrollView.contentOffset.y > maxOffsetY {
            scrollView.contentOffset.y = maxOffsetY
        }

        scrollView.bounces = scrollView.contentOffset.y <= 0
        syncListBounce()
    }

    private func processListViewDidScroll(_ scrollView: UIScrollView) {
        currentScrollingListView = scrollView
        let maxOffsetY = mainTableViewMaxContentOffsetY
        let minListOffset = -scrollView.adjustedContentInset.top

        if mainTableView.contentOffset.y < maxOffsetY {
            scrollView.contentOffset.y = minListOffset
            scrollView.showsVerticalScrollIndicator = false
        } else {
            mainTableView.contentOffset.y = maxOffsetY
            scrollView.showsVerticalScrollIndicator = true
        }

        syncListBounce()
    }

    private var usesMainTableScrolling: Bool {
        guard bounds.width > 0, let list = listContainerView.currentList() else { return false }
        return list.listPreferredContentHeight(forWidth: bounds.width) != nil
    }

    private func updateScrollingMode() {
        let mainOnly = usesMainTableScrolling
        mainTableView.showsVerticalScrollIndicator = mainOnly
        mainTableView.scrollsToTop = mainOnly
        mainTableView.bounces = true
        if mainOnly {
            mainTableView.shouldRecognizeSimultaneously = { _, _ in false }
        } else {
            mainTableView.shouldRecognizeSimultaneously = { [weak self] _, other in
                self?.shouldRecognizeSimultaneously(with: other) ?? false
            }
        }
        applyMainTableSafeAreaInsetIfNeeded()
    }

    private func applyMainTableSafeAreaInsetIfNeeded() {
        guard automaticallyAdjustsListContentInset, usesMainTableScrolling else { return }
        let bottom = safeAreaInsets.bottom
        guard abs(mainTableView.contentInset.bottom - bottom) > 0.5 else { return }
        var inset = mainTableView.contentInset
        inset.bottom = bottom
        mainTableView.contentInset = inset
        mainTableView.verticalScrollIndicatorInsets.bottom = bottom
    }

    private func syncListBounce() {
        guard !usesMainTableScrolling else { return }
        let headerPinned = mainTableView.contentOffset.y >= mainTableViewMaxContentOffsetY - 0.5
        for list in listContainerView.validLists.values {
            list.listScrollView().bounces = headerPinned
        }
    }

    private func updateScrollsToTop() {
        for (index, list) in listContainerView.validLists {
            list.listScrollView().scrollsToTop = index == currentListIndex
        }
    }

    private func shouldRecognizeSimultaneously(with other: UIGestureRecognizer) -> Bool {
        guard other is UIPanGestureRecognizer else { return false }
        if other.view === listContainerView.scrollView {
            return false
        }
        return other.view is UIScrollView
    }

    private func refreshListContainerHeight() {
        guard bounds.width > 0 else { return }
        mainTableView.beginUpdates()
        mainTableView.endUpdates()
        listContainerView.frame = CGRect(origin: .zero, size: listContainerSize)
    }

    private func syncSafeAreaAdjustments() {
        if automaticallyAdjustsPinSectionHeaderVerticalOffset {
            let target = safeAreaInsets.top
            if abs(pinSectionHeaderVerticalOffset - target) > 0.5 {
                pinSectionHeaderVerticalOffset = target
            }
        }
        applyListSafeAreaInsets()
    }

    private func applyListSafeAreaInsets() {
        if usesMainTableScrolling {
            applyMainTableSafeAreaInsetIfNeeded()
            return
        }
        guard automaticallyAdjustsListContentInset else { return }
        let bottom = safeAreaInsets.bottom
        let left = safeAreaInsets.left
        let right = safeAreaInsets.right
        let dBottom = bottom - appliedListBottomInset
        let dLeft = left - appliedListLeftInset
        let dRight = right - appliedListRightInset
        guard dBottom != 0 || dLeft != 0 || dRight != 0 else { return }

        for list in listContainerView.validLists.values {
            let scrollView = list.listScrollView()
            var inset = scrollView.contentInset
            inset.bottom += dBottom
            inset.left += dLeft
            inset.right += dRight
            scrollView.contentInset = inset
            scrollView.verticalScrollIndicatorInsets.bottom = bottom
            scrollView.horizontalScrollIndicatorInsets.left = left
            scrollView.horizontalScrollIndicatorInsets.right = right
        }

        appliedListBottomInset = bottom
        appliedListLeftInset = left
        appliedListRightInset = right
    }

    private func applySafeAreaInsetsToNewList(_ scrollView: UIScrollView) {
        guard automaticallyAdjustsListContentInset else { return }
        var inset = scrollView.contentInset
        inset.bottom += safeAreaInsets.bottom
        inset.left += safeAreaInsets.left
        inset.right += safeAreaInsets.right
        scrollView.contentInset = inset
        scrollView.verticalScrollIndicatorInsets.bottom = safeAreaInsets.bottom
        scrollView.horizontalScrollIndicatorInsets.left = safeAreaInsets.left
        scrollView.horizontalScrollIndicatorInsets.right = safeAreaInsets.right
        appliedListBottomInset = safeAreaInsets.bottom
        appliedListLeftInset = safeAreaInsets.left
        appliedListRightInset = safeAreaInsets.right
    }

    private var listContainerSize: CGSize {
        let width = bounds.width
        if width > 0,
           let list = listContainerView.currentList(),
           let contentHeight = list.listPreferredContentHeight(forWidth: width) {
            return CGSize(width: width, height: max(contentHeight, 0))
        }
        let pinHeight = delegate?.heightForPinSectionHeader(in: self) ?? 0
        let height = max(bounds.height - pinHeight - pinSectionHeaderVerticalOffset, 0)
        return CGSize(width: width, height: height)
    }
}

@MainActor
private final class EmptyNestedPagingListView: UIView, NestedPagingListViewDelegate {
    func listView() -> UIView { self }
    func listScrollView() -> UIScrollView { UIScrollView() }
    func listViewDidScrollCallback(_ callback: @escaping (UIScrollView) -> Void) {}
}
