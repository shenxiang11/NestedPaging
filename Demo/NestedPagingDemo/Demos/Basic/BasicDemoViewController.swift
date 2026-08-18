import NestedPaging
import UIKit

/// Minimal integration: a solid header, a pin bar, and two tables.
final class BasicDemoViewController: UIViewController, NestedPagingViewDelegate {
    private let pagingView = NestedPagingView()
    private let headerView = BasicHeaderView()
    private let pinBar = NestedPagingPinBar(titles: ["列表 A", "列表 B"], indicatorColor: .systemBlue)
    private var lists: [Int: NestedPagingListViewDelegate] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "基础用法"
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
        pagingView.reloadData()
    }

    func tableHeaderViewHeight(in pagingView: NestedPagingView) -> CGFloat {
        160
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
        2
    }

    func pagingView(_ pagingView: NestedPagingView, initListAt index: Int) -> NestedPagingListViewDelegate {
        if let existing = lists[index] {
            return existing
        }
        let prefix = index == 0 ? "A" : "B"
        let list = BasicListView(rows: (1...40).map { "\(prefix) · 第 \($0) 行" })
        lists[index] = list
        return list
    }
}

private final class BasicHeaderView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBlue

        titleLabel.text = "NestedPaging"
        titleLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 28, weight: .bold))
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .white

        subtitleLabel.text = "Header 滚走后，分类栏吸顶，子列表接手。"
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
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}

private final class BasicListView: UIView, UITableViewDataSource, UITableViewDelegate, NestedPagingListViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let rows: [String]
    private var scrollCallback: ((UIScrollView) -> Void)?

    init(rows: [String]) {
        self.rows = rows
        super.init(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.scrollsToTop = false
        tableView.rowHeight = 52
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "row")
        addSubview(tableView)
        tableView.pinToEdges(of: self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func listView() -> UIView { self }
    func listScrollView() -> UIScrollView { tableView }

    func listViewDidScrollCallback(_ callback: @escaping (UIScrollView) -> Void) {
        scrollCallback = callback
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        var content = UIListContentConfiguration.cell()
        content.text = rows[indexPath.row]
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
}
