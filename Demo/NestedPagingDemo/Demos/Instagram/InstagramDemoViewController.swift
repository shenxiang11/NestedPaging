import NestedPaging
import UIKit

/// Instagram-style profile: no cover, opaque nav, highlights, icon tabs, 3-column grid.
final class InstagramDemoViewController: UIViewController, NestedPagingViewDelegate {
    private let pagingView = NestedPagingView()
    private let headerView = InstagramHeaderView()
    private let pinBar = DemoIconPinBar(
        symbols: ["square.grid.3x3", "play.square", "person.crop.square"],
        titles: ["帖子", "Reels", "标记"],
        selectedColor: .label
    )
    private var lists: [Int: NestedPagingListViewDelegate] = [:]
    private var headerHeight: CGFloat = 320

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "nestedpaging"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        pinBar.onSelectIndex = { [weak self] index in
            self?.pagingView.setCurrentListIndex(index, animated: true)
        }
        pagingView.delegate = self
        pagingView.listContainerDidScroll = { [weak self] _ in
            guard let self else { return }
            self.pinBar.setProgress(self.pagingView.currentListScrollProgress, animated: false)
        }
        pagingView.didChangeListIndex = { [weak self] index in
            self?.pinBar.setProgress(CGFloat(index), animated: true)
        }

        view.addSubview(pagingView)
        pagingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pagingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pagingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        headerHeight = headerView.demoPreferredHeight(forWidth: view.bounds.width > 0 ? view.bounds.width : 390, fallback: 320)
        pagingView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let measured = headerView.demoPreferredHeight(forWidth: view.bounds.width, fallback: headerHeight)
        guard abs(measured - headerHeight) > 0.5 else { return }
        guard !pagingView.mainTableView.isDragging, !pagingView.mainTableView.isDecelerating else { return }
        headerHeight = measured
        pagingView.reloadData()
    }

    func tableHeaderViewHeight(in pagingView: NestedPagingView) -> CGFloat { headerHeight }
    func tableHeaderView(in pagingView: NestedPagingView) -> UIView { headerView }
    func heightForPinSectionHeader(in pagingView: NestedPagingView) -> CGFloat { 48 }
    func viewForPinSectionHeader(in pagingView: NestedPagingView) -> UIView { pinBar }
    func numberOfLists(in pagingView: NestedPagingView) -> Int { 3 }

    func pagingView(_ pagingView: NestedPagingView, initListAt index: Int) -> NestedPagingListViewDelegate {
        if let existing = lists[index] { return existing }
        let titles = ["帖子", "Reels", "标记"]
        let symbols = ["photo", "play.fill", "person.crop.square"]
        let list = DemoGridListView(
            items: DemoMediaPalette.items(count: 27, title: titles[index], symbol: symbols[index]) { _ in "" },
            style: index == 1 ? .portraitVideo : .photoSquare
        )
        lists[index] = list
        return list
    }
}

private final class InstagramHeaderView: UIView {
    private let avatar = UIView()
    private let statsStack = UIStackView()
    private let nameLabel = UILabel()
    private let bioLabel = UILabel()
    private let highlightsStack = UIStackView()
    private let contentStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        avatar.backgroundColor = UIColor.systemGray3
        avatar.layer.borderWidth = 2
        avatar.layer.borderColor = UIColor.separator.cgColor

        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.addArrangedSubview(statView(value: "128", title: "帖子"))
        statsStack.addArrangedSubview(statView(value: "3.2万", title: "粉丝"))
        statsStack.addArrangedSubview(statView(value: "326", title: "关注"))

        let topRow = UIStackView(arrangedSubviews: [avatar, statsStack])
        topRow.alignment = .center
        topRow.spacing = 24

        nameLabel.text = "阿爪"
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.adjustsFontForContentSizeCategory = true

        bioLabel.text = "没有大封面。资料和 Highlights 滚走后，图标 tab 吸顶，下面三列宫格接手。"
        bioLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        bioLabel.numberOfLines = 0
        bioLabel.adjustsFontForContentSizeCategory = true

        highlightsStack.axis = .horizontal
        highlightsStack.spacing = 16
        highlightsStack.alignment = .top
        ["旅行", "日常", "开发", "胶片", "食物"].forEach { title in
            highlightsStack.addArrangedSubview(highlightView(title: title))
        }

        let highlightsScroll = UIScrollView()
        highlightsScroll.showsHorizontalScrollIndicator = false
        highlightsScroll.addSubview(highlightsStack)
        highlightsStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 12
        contentStack.addArrangedSubview(topRow)
        contentStack.addArrangedSubview(nameLabel)
        contentStack.addArrangedSubview(bioLabel)
        contentStack.setCustomSpacing(16, after: bioLabel)
        contentStack.addArrangedSubview(highlightsScroll)
        addSubview(contentStack)

        avatar.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 86),
            avatar.heightAnchor.constraint(equalToConstant: 86),

            highlightsStack.topAnchor.constraint(equalTo: highlightsScroll.topAnchor),
            highlightsStack.bottomAnchor.constraint(equalTo: highlightsScroll.bottomAnchor),
            highlightsStack.leadingAnchor.constraint(equalTo: highlightsScroll.leadingAnchor),
            highlightsStack.trailingAnchor.constraint(equalTo: highlightsScroll.trailingAnchor),
            highlightsScroll.heightAnchor.constraint(equalToConstant: 86),

            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatar.layer.cornerRadius = 43
    }

    private func statView(value: String, title: String) -> UIView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontForContentSizeCategory = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontForContentSizeCategory = true

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        stack.isAccessibilityElement = true
        stack.accessibilityLabel = "\(value) \(title)"
        return stack
    }

    private func highlightView(title: String) -> UIView {
        let circle = UIView()
        circle.backgroundColor = .secondarySystemBackground
        circle.layer.borderWidth = 1
        circle.layer.borderColor = UIColor.separator.cgColor
        circle.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true

        let stack = UIStackView(arrangedSubviews: [circle, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.isAccessibilityElement = true
        stack.accessibilityLabel = title

        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 64),
            circle.heightAnchor.constraint(equalToConstant: 64),
        ])
        circle.layer.cornerRadius = 32
        return stack
    }
}
