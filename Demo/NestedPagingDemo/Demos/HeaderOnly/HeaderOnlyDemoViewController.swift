import NestedPaging
import UIKit

/// Header + one article `UIView`. No category tabs.
///
/// The article is a plain view in the outer table, so the page scrolls as
/// one. It overlaps the header with a rounded top and continues under a
/// transparent navigation bar. The table background is white so bottom
/// bounce stays white.
private enum HeaderOnlyMetrics {
    static let headerContentHeight: CGFloat = 160
    static let sheetOverlap: CGFloat = 24
    static let sheetCornerRadius: CGFloat = 16
    static let headerColor = UIColor.systemTeal
}

final class HeaderOnlyDemoViewController: UIViewController, NestedPagingViewDelegate {
    private let pagingView = NestedPagingView()
    private let headerView = HeaderOnlyHeaderView()
    private let articleView = HeaderOnlyArticleView()
    private let topFillView = UIView()
    private var headerHeight: CGFloat = HeaderOnlyMetrics.headerContentHeight

    private var didCaptureAppearance = false
    private var previousStandardAppearance: UINavigationBarAppearance?
    private var previousScrollEdgeAppearance: UINavigationBarAppearance?
    private var previousCompactAppearance: UINavigationBarAppearance?
    private var previousTintColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "无分类栏"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        pagingView.delegate = self
        pagingView.automaticallyAdjustsPinSectionHeaderVerticalOffset = false
        pagingView.pinSectionHeaderVerticalOffset = 0
        pagingView.backgroundColor = .systemBackground
        pagingView.mainTableView.backgroundColor = .systemBackground
        pagingView.listContainerView.backgroundColor = HeaderOnlyMetrics.headerColor

        topFillView.backgroundColor = HeaderOnlyMetrics.headerColor
        pagingView.mainTableView.addSubview(topFillView)

        view.addSubview(pagingView)
        pagingView.pinToEdges(of: view)
        headerHeight = measuredHeaderHeight()
        pagingView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureNavigationAppearanceIfNeeded()
        applyNavigationChrome()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            restoreNavigationAppearance()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topFillView.frame = CGRect(x: 0, y: -1000, width: view.bounds.width, height: 1000)

        let measured = measuredHeaderHeight()
        guard abs(measured - headerHeight) > 0.5 else { return }
        guard !pagingView.mainTableView.isDragging, !pagingView.mainTableView.isDecelerating else { return }
        headerHeight = measured
        pagingView.reloadData()
    }

    private func measuredHeaderHeight() -> CGFloat {
        view.safeAreaInsets.top + HeaderOnlyMetrics.headerContentHeight - HeaderOnlyMetrics.sheetOverlap
    }

    func tableHeaderViewHeight(in pagingView: NestedPagingView) -> CGFloat { headerHeight }
    func tableHeaderView(in pagingView: NestedPagingView) -> UIView { headerView }
    func heightForPinSectionHeader(in pagingView: NestedPagingView) -> CGFloat { 0 }
    func viewForPinSectionHeader(in pagingView: NestedPagingView) -> UIView { UIView() }
    func numberOfLists(in pagingView: NestedPagingView) -> Int { 1 }

    func pagingView(_ pagingView: NestedPagingView, initListAt index: Int) -> NestedPagingListViewDelegate {
        articleView
    }

    private func applyNavigationChrome() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "无分类栏"
    }

    private func captureNavigationAppearanceIfNeeded() {
        guard !didCaptureAppearance, let navigationBar = navigationController?.navigationBar else { return }
        didCaptureAppearance = true
        previousStandardAppearance = navigationBar.standardAppearance
        previousScrollEdgeAppearance = navigationBar.scrollEdgeAppearance
        previousCompactAppearance = navigationBar.compactAppearance
        previousTintColor = navigationBar.tintColor
    }

    private func restoreNavigationAppearance() {
        guard let navigationController else { return }
        let navigationBar = navigationController.navigationBar
        navigationBar.standardAppearance = previousStandardAppearance ?? UINavigationBarAppearance()
        navigationBar.scrollEdgeAppearance = previousScrollEdgeAppearance
        navigationBar.compactAppearance = previousCompactAppearance
        navigationBar.tintColor = previousTintColor ?? .label
    }
}

private final class HeaderOnlyHeaderView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = HeaderOnlyMetrics.headerColor

        titleLabel.text = "没有 Tab"
        titleLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 28, weight: .bold))
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .white

        subtitleLabel.text = "白色卡片压在封面下沿，并可以滚进导航栏下面。"
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.86)
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}

private final class HeaderOnlyArticleView: UIView, NestedPagingListViewDelegate {
    private let textLabel = UILabel()
    private let unusedScrollView = UIScrollView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = HeaderOnlyMetrics.sheetCornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerCurve = .continuous
        layer.masksToBounds = true

        unusedScrollView.isScrollEnabled = false

        textLabel.text = HeaderOnlyArticleView.article
        textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.textColor = .label
        textLabel.numberOfLines = 0
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func listView() -> UIView { self }
    func listScrollView() -> UIScrollView { unusedScrollView }
    func listViewDidScrollCallback(_ callback: @escaping (UIScrollView) -> Void) {}

    func listPreferredContentHeight(forWidth width: CGFloat) -> CGFloat? {
        let fittingWidth = max(width, 0)
        textLabel.preferredMaxLayoutWidth = max(fittingWidth - 40, 0)
        let target = CGSize(width: fittingWidth, height: UIView.layoutFittingCompressedSize.height)
        return systemLayoutSizeFitting(
            target,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }

    private static let article = """
    这是没有分类栏的页面。正文是一块普通 UIView，高度按文案撑开。整页只靠外层 table 滚动，所以可以一直往上滑：Header 走完之后，卡片和文章跟着继续走，不会在中间把外层锁死再交给内层 ScrollView。

    有 tab 时才需要嵌套接力：多个子列表共享一个 Header，每个列表自己滚。没有 tab 时只有一篇内容，再套一层 ScrollView 是多余的。

    白色卡片上沿切了圆角，并往 Header 里叠进一截。卡片会跟着滚进半透明导航栏下面，没有单独的吸顶条。

    底部回弹是白色。顶部下拉仍露出封面的青色。

    下面再写几段，把 UIView 拉高，确认整页是一条滚动，白色内容可以穿过导航栏。

    外层仍是 NestedPaging 的 plain UITableView：tableHeaderView 是封面，cell 里放这一块文章 UIView。cell 高度等于文章高度，所以外层的 contentSize 足够长，手指不用换一层就能滚到底。

    如果以后要加分类栏，拿掉 listPreferredContentHeight，改回真正的子列表 ScrollView，并恢复垂直接力即可。

    正文继续。读到这里，白色卡片应已经贴着导航栏往上走，而不是停在一条灰色吸顶下面。

    再写一段。量高用 systemLayoutSizeFitting，宽度跟屏幕走。Dynamic Type 变大时，下一次布局会重新量高。

    再写一段。没有内层 ScrollView，也就没有漏转 scrollViewDidScroll 导致接不上的问题。

    最后一段。如果滚到这里都还在往上走，底部露出的是白底而不是蓝底，这一页就算对了。
    """
}
