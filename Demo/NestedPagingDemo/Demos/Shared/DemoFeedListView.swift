import NestedPaging
import UIKit

final class DemoFeedListView: UIView, UITableViewDataSource, UITableViewDelegate, NestedPagingListViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let tweets: [DemoTweetItem]
    private let handle: String
    private var scrollCallback: ((UIScrollView) -> Void)?

    init(tweets: [DemoTweetItem], handle: String) {
        self.tweets = tweets
        self.handle = handle
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.scrollsToTop = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.register(DemoTweetCell.self, forCellReuseIdentifier: DemoTweetCell.reuseIdentifier)
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
        tweets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DemoTweetCell.reuseIdentifier, for: indexPath)
        (cell as? DemoTweetCell)?.apply(tweets[indexPath.row], handle: handle)
        return cell
    }
}

private final class DemoTweetCell: UITableViewCell {
    static let reuseIdentifier = "DemoTweetCell"

    private let avatar = UIView()
    private let nameLabel = UILabel()
    private let bodyLabel = UILabel()
    private let metricsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        avatar.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        avatar.layer.cornerCurve = .continuous

        nameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1

        bodyLabel.font = UIFont.preferredFont(forTextStyle: .body)
        bodyLabel.adjustsFontForContentSizeCategory = true
        bodyLabel.textColor = .label
        bodyLabel.numberOfLines = 0

        metricsLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        metricsLabel.adjustsFontForContentSizeCategory = true
        metricsLabel.textColor = .secondaryLabel

        avatar.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        metricsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(metricsLabel)

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            avatar.widthAnchor.constraint(equalToConstant: 40),
            avatar.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatar.topAnchor),

            bodyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            metricsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            metricsLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            metricsLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 10),
            metricsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatar.layer.cornerRadius = 20
    }

    func apply(_ item: DemoTweetItem, handle: String) {
        nameLabel.text = "阿爪  \(handle) · \(item.time)"
        bodyLabel.text = item.body
        metricsLabel.text = "\(item.replies) 回复    \(item.reposts) 转帖    \(item.likes) 喜欢"
    }
}
