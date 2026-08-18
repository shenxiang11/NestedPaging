import NestedPaging
import UIKit

/// Shared host for cover-style profile pages: header under the nav bar, pin bar sticks, lists take over.
class CoverPagingController: UIViewController, NestedPagingViewDelegate {
    let pagingView = NestedPagingView()
    private(set) var lists: [Int: NestedPagingListViewDelegate] = [:]
    private(set) var headerView: UIView!
    private(set) var pinBar: (UIView & DemoProgressPinBar)!
    private var headerHeight: CGFloat = 360
    private var navigationProgress: CGFloat = 0
    private var didCaptureAppearance = false

    private var previousStandardAppearance: UINavigationBarAppearance?
    private var previousScrollEdgeAppearance: UINavigationBarAppearance?
    private var previousCompactAppearance: UINavigationBarAppearance?
    private var previousTintColor: UIColor?
    private var previousPrefersLargeTitles = false

    func makeHeader() -> UIView { UIView() }
    func measureHeader(width: CGFloat) -> CGFloat { 320 }
    func makePinBar() -> UIView & DemoProgressPinBar {
        NestedPagingPinBar(titles: ["Tab"])
    }
    func listCount() -> Int { 1 }
    func makeList(at index: Int) -> NestedPagingListViewDelegate {
        DemoGridListView(items: [], style: .photoSquare)
    }
    var coverBackgroundColor: UIColor { .systemBackground }
    var pinnedNavigationTitle: String { "" }
    var pinBarHeight: CGFloat { 48 }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonDisplayMode = .minimal

        headerView = makeHeader()
        pinBar = makePinBar()
        pinBar.onSelectIndex = { [weak self] index in
            self?.pagingView.setCurrentListIndex(index, animated: true)
        }

        pagingView.delegate = self
        pagingView.mainTableViewDidScroll = { [weak self] scrollView in
            self?.updateNavigationChrome(offsetY: scrollView.contentOffset.y)
        }
        pagingView.listContainerDidScroll = { [weak self] _ in
            guard let self else { return }
            self.pinBar.setProgress(self.pagingView.currentListScrollProgress, animated: false)
        }
        pagingView.didChangeListIndex = { [weak self] index in
            self?.pinBar.setProgress(CGFloat(index), animated: true)
        }

        view.addSubview(pagingView)
        pagingView.pinToEdges(of: view)
        pagingView.mainTableView.backgroundColor = coverBackgroundColor

        let width = view.bounds.width > 0 ? view.bounds.width : 390
        headerHeight = measureHeader(width: width)
        pagingView.reloadData()

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
            self.pagingView.mainTableView.backgroundColor = self.coverBackgroundColor
            self.updateNavigationChrome(offsetY: self.pagingView.mainTableView.contentOffset.y)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        captureNavigationAppearanceIfNeeded()
        updateNavigationChrome(offsetY: pagingView.mainTableView.contentOffset.y)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            restoreNavigationAppearance()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let measured = measureHeader(width: view.bounds.width)
        guard abs(measured - headerHeight) > 0.5 else { return }
        guard !pagingView.mainTableView.isDragging, !pagingView.mainTableView.isDecelerating else { return }
        headerHeight = measured
        pagingView.reloadData()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if traitCollection.userInterfaceStyle == .dark {
            return .lightContent
        }
        return navigationProgress > 0.55 ? .darkContent : .lightContent
    }

    func tableHeaderViewHeight(in pagingView: NestedPagingView) -> CGFloat { headerHeight }
    func tableHeaderView(in pagingView: NestedPagingView) -> UIView { headerView }
    func heightForPinSectionHeader(in pagingView: NestedPagingView) -> CGFloat { pinBarHeight }
    func viewForPinSectionHeader(in pagingView: NestedPagingView) -> UIView { pinBar }
    func numberOfLists(in pagingView: NestedPagingView) -> Int { listCount() }

    func pagingView(_ pagingView: NestedPagingView, initListAt index: Int) -> NestedPagingListViewDelegate {
        if let existing = lists[index] { return existing }
        let list = makeList(at: index)
        lists[index] = list
        return list
    }

    private func updateNavigationChrome(offsetY: CGFloat) {
        let fadeDistance = max(headerHeight - view.safeAreaInsets.top - 72, 80)
        let progress = min(max(offsetY / fadeDistance, 0), 1)
        navigationProgress = progress

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(progress)
        appearance.shadowColor = progress > 0.98 ? UIColor.separator.withAlphaComponent(0.25) : .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label.withAlphaComponent(progress),
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = blendedTint(progress: progress)
        navigationItem.title = progress > 0.72 ? pinnedNavigationTitle : ""

        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNeedsStatusBarAppearanceUpdate()
    }

    private func blendedTint(progress: CGFloat) -> UIColor {
        let cover = UIColor.white
        let label = UIColor.label.resolvedColor(with: traitCollection)
        var cr: CGFloat = 1, cg: CGFloat = 1, cb: CGFloat = 1, ca: CGFloat = 1
        var lr: CGFloat = 0, lg: CGFloat = 0, lb: CGFloat = 0, la: CGFloat = 1
        cover.getRed(&cr, green: &cg, blue: &cb, alpha: &ca)
        label.getRed(&lr, green: &lg, blue: &lb, alpha: &la)
        return UIColor(
            red: cr + (lr - cr) * progress,
            green: cg + (lg - cg) * progress,
            blue: cb + (lb - cb) * progress,
            alpha: 1
        )
    }

    private func captureNavigationAppearanceIfNeeded() {
        guard !didCaptureAppearance, let navigationBar = navigationController?.navigationBar else { return }
        didCaptureAppearance = true
        previousStandardAppearance = navigationBar.standardAppearance
        previousScrollEdgeAppearance = navigationBar.scrollEdgeAppearance
        previousCompactAppearance = navigationBar.compactAppearance
        previousTintColor = navigationBar.tintColor
        previousPrefersLargeTitles = navigationController?.navigationBar.prefersLargeTitles ?? false
    }

    private func restoreNavigationAppearance() {
        guard let navigationController else { return }
        let navigationBar = navigationController.navigationBar
        navigationBar.standardAppearance = previousStandardAppearance ?? UINavigationBarAppearance()
        navigationBar.scrollEdgeAppearance = previousScrollEdgeAppearance
        navigationBar.compactAppearance = previousCompactAppearance
        navigationBar.tintColor = previousTintColor ?? .label
        navigationBar.prefersLargeTitles = previousPrefersLargeTitles
    }
}
