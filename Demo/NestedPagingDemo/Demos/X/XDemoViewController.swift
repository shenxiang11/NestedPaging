import NestedPaging
import UIKit

final class XDemoViewController: CoverPagingController {
    private let header = XHeaderView()

    override var coverBackgroundColor: UIColor { UIColor(red: 0.29, green: 0.63, blue: 0.91, alpha: 1) }
    override var pinnedNavigationTitle: String { "阿爪" }

    override func makeHeader() -> UIView { header }
    override func measureHeader(width: CGFloat) -> CGFloat { header.demoPreferredHeight(forWidth: width, fallback: 380) }

    override func makePinBar() -> UIView & DemoProgressPinBar {
        NestedPagingPinBar(titles: ["帖子", "回复", "媒体", "喜欢"], indicatorColor: UIColor(red: 0.11, green: 0.61, blue: 0.94, alpha: 1))
    }

    override func listCount() -> Int { 4 }

    override func makeList(at index: Int) -> NestedPagingListViewDelegate {
        if index == 2 {
            return DemoGridListView(
                items: DemoMediaPalette.items(count: 18, title: "媒体", symbol: "photo") { _ in "" },
                style: .photoSquare
            )
        }
        return DemoFeedListView(tweets: Self.tweets(for: index), handle: "@nestedpaging")
    }

    private static func tweets(for index: Int) -> [DemoTweetItem] {
        let prefixes = ["刚把吸顶调顺：", "回复一楼：", "这条进喜欢："]
        let prefix = prefixes[min(index, prefixes.count - 1)]
        return (1...18).map { number in
            DemoTweetItem(
                id: "x-\(index)-\(number)",
                body: "\(prefix) Header 还在时子列表锁在 0，分类栏贴顶之后外层钉死。第 \(number) 条。",
                time: "\(number)h",
                replies: "\(number)",
                reposts: "\(number * 2)",
                likes: "\(number * 11)"
            )
        }
    }
}

private final class XHeaderView: UIView {
    private let banner = UIView()
    private let avatar = UIView()
    private let followButton = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let handleLabel = UILabel()
    private let bioLabel = UILabel()
    private let metaLabel = UILabel()
    private let statsLabel = UILabel()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        banner.backgroundColor = UIColor(red: 0.29, green: 0.63, blue: 0.91, alpha: 1)
        addSubview(banner)

        avatar.backgroundColor = UIColor(red: 0.11, green: 0.61, blue: 0.94, alpha: 1)
        avatar.layer.borderWidth = 4
        avatar.layer.borderColor = UIColor.systemBackground.cgColor
        addSubview(avatar)

        var follow = UIButton.Configuration.filled()
        follow.title = "关注"
        follow.baseBackgroundColor = .label
        follow.baseForegroundColor = .systemBackground
        follow.cornerStyle = .capsule
        follow.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18)
        followButton.configuration = follow
        followButton.accessibilityLabel = "关注"
        addSubview(followButton)

        nameLabel.text = "阿爪"
        nameLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 22, weight: .bold))
        nameLabel.adjustsFontForContentSizeCategory = true

        handleLabel.text = "@nestedpaging"
        handleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        handleLabel.textColor = .secondaryLabel
        handleLabel.adjustsFontForContentSizeCategory = true

        bioLabel.text = "外层吸顶，内层接手。帖子是时间线，媒体是九宫格，喜欢还是时间线。"
        bioLabel.font = UIFont.preferredFont(forTextStyle: .body)
        bioLabel.numberOfLines = 0
        bioLabel.adjustsFontForContentSizeCategory = true

        metaLabel.text = "📍 上海    📅 2024 年 8 月加入"
        metaLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        metaLabel.textColor = .secondaryLabel
        metaLabel.adjustsFontForContentSizeCategory = true

        statsLabel.text = "326 正在关注    1.2万 关注者"
        statsLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        statsLabel.adjustsFontForContentSizeCategory = true

        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        [nameLabel, handleLabel, bioLabel, metaLabel, statsLabel].forEach { stack.addArrangedSubview($0) }
        stack.setCustomSpacing(10, after: handleLabel)
        addSubview(stack)

        banner.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        followButton.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: topAnchor),
            banner.leadingAnchor.constraint(equalTo: leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: trailingAnchor),
            banner.heightAnchor.constraint(equalToConstant: 140),

            avatar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: banner.bottomAnchor, constant: 8),
            avatar.widthAnchor.constraint(equalToConstant: 76),
            avatar.heightAnchor.constraint(equalToConstant: 76),

            followButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            followButton.topAnchor.constraint(equalTo: banner.bottomAnchor, constant: 12),
            followButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            stack.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatar.layer.cornerRadius = 38
        avatar.layer.borderColor = UIColor.systemBackground.cgColor
    }
}
