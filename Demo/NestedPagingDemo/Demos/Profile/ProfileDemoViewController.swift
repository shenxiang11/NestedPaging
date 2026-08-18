import NestedPaging
import UIKit

final class ProfileDemoViewController: UIViewController, NestedPagingViewDelegate {
    private let pagingView = NestedPagingView()
    private let headerView = ProfileHeaderView()
    private let pinBar = NestedPagingPinBar(titles: ProfileTab.allCases.map(\.title), indicatorColor: ProfilePalette.accent)
    private var lists: [Int: NestedPagingListViewDelegate] = [:]
    private var headerHeight: CGFloat = 360
    private var navigationProgress: CGFloat = 0
    private var didCaptureAppearance = false

    private var previousStandardAppearance: UINavigationBarAppearance?
    private var previousScrollEdgeAppearance: UINavigationBarAppearance?
    private var previousCompactAppearance: UINavigationBarAppearance?
    private var previousTintColor: UIColor?
    private var previousPrefersLargeTitles = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonDisplayMode = .minimal

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
        pagingView.mainTableView.backgroundColor = ProfilePalette.coverTop

        let initialWidth = view.bounds.width > 0 ? view.bounds.width : 390
        headerHeight = headerView.preferredHeight(forWidth: initialWidth)
        pagingView.reloadData()

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
            self.pagingView.mainTableView.backgroundColor = ProfilePalette.coverTop
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
        updateHeaderHeightIfNeeded()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if traitCollection.userInterfaceStyle == .dark {
            return .lightContent
        }
        return navigationProgress > 0.55 ? .darkContent : .lightContent
    }

    func tableHeaderViewHeight(in pagingView: NestedPagingView) -> CGFloat {
        headerHeight
    }

    func tableHeaderView(in pagingView: NestedPagingView) -> UIView {
        headerView
    }

    func heightForPinSectionHeader(in pagingView: NestedPagingView) -> CGFloat {
        48
    }

    func viewForPinSectionHeader(in pagingView: NestedPagingView) -> UIView {
        pinBar
    }

    func numberOfLists(in pagingView: NestedPagingView) -> Int {
        ProfileTab.allCases.count
    }

    func pagingView(_ pagingView: NestedPagingView, initListAt index: Int) -> NestedPagingListViewDelegate {
        if let existing = lists[index] {
            return existing
        }

        let list: NestedPagingListViewDelegate
        switch ProfileTab(rawValue: index) ?? .feed {
        case .feed, .likes:
            let tab = ProfileTab(rawValue: index) ?? .feed
            list = ProfileFeedListView(items: ProfileContent.items(for: tab))
        case .works:
            list = ProfileWorksListView(items: ProfileContent.workItems)
        }

        lists[index] = list
        return list
    }

    private func updateHeaderHeightIfNeeded() {
        let width = view.bounds.width
        guard width > 0 else { return }
        guard !pagingView.mainTableView.isDragging, !pagingView.mainTableView.isDecelerating else { return }
        let measured = headerView.preferredHeight(forWidth: width)
        guard abs(measured - headerHeight) > 0.5 else { return }
        headerHeight = measured
        pagingView.reloadData()
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
        navigationController?.navigationBar.tintColor = coverToLabelColor(progress: progress)
        navigationItem.title = progress > 0.72 ? ProfileContent.name : ""

        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNeedsStatusBarAppearanceUpdate()
    }

    private func coverToLabelColor(progress: CGFloat) -> UIColor {
        let cover = UIColor.white
        let label = UIColor.label.resolvedColor(with: traitCollection)
        var coverRed: CGFloat = 1, coverGreen: CGFloat = 1, coverBlue: CGFloat = 1, coverAlpha: CGFloat = 1
        var labelRed: CGFloat = 0, labelGreen: CGFloat = 0, labelBlue: CGFloat = 0, labelAlpha: CGFloat = 1
        cover.getRed(&coverRed, green: &coverGreen, blue: &coverBlue, alpha: &coverAlpha)
        label.getRed(&labelRed, green: &labelGreen, blue: &labelBlue, alpha: &labelAlpha)
        return UIColor(
            red: coverRed + (labelRed - coverRed) * progress,
            green: coverGreen + (labelGreen - coverGreen) * progress,
            blue: coverBlue + (labelBlue - coverBlue) * progress,
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
