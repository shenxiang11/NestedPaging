import NestedPaging
import UIKit

final class XiaohongshuDemoViewController: CoverPagingController {
    private let header = XiaohongshuHeaderView()
    private let accent = UIColor(red: 1, green: 0.14, blue: 0.26, alpha: 1)

    override var coverBackgroundColor: UIColor { UIColor(red: 1, green: 0.86, blue: 0.88, alpha: 1) }
    override var pinnedNavigationTitle: String { "阿爪" }

    override func makeHeader() -> UIView { header }
    override func measureHeader(width: CGFloat) -> CGFloat { header.demoPreferredHeight(forWidth: width, fallback: 400) }

    override func makePinBar() -> UIView & DemoProgressPinBar {
        NestedPagingPinBar(titles: ["笔记", "收藏", "赞过"], indicatorColor: accent)
    }

    override func listCount() -> Int { 3 }

    override func makeList(at index: Int) -> NestedPagingListViewDelegate {
        let titles = ["周末咖啡馆", "胶片 Recap", "南京一日"]
        return DemoGridListView(
            items: DemoMediaPalette.items(count: 16, title: titles[index], symbol: "photo") { "♥ \(120 + $0 * 17)" },
            style: .noteCard
        )
    }
}

private final class XiaohongshuHeaderView: UIView {
    private let cover = UIView()
    private let gradient = CAGradientLayer()
    private let avatar = UIView()
    private let followButton = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let idLabel = UILabel()
    private let bioLabel = UILabel()
    private let statsLabel = UILabel()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        gradient.colors = [
            UIColor(red: 1, green: 0.62, blue: 0.68, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.86, blue: 0.88, alpha: 1).cgColor,
        ]
        cover.layer.addSublayer(gradient)
        addSubview(cover)

        avatar.backgroundColor = UIColor(red: 1, green: 0.14, blue: 0.26, alpha: 1)
        avatar.layer.borderWidth = 3
        avatar.layer.borderColor = UIColor.systemBackground.cgColor
        addSubview(avatar)

        var follow = UIButton.Configuration.filled()
        follow.title = "关注"
        follow.baseBackgroundColor = UIColor(red: 1, green: 0.14, blue: 0.26, alpha: 1)
        follow.baseForegroundColor = .white
        follow.cornerStyle = .capsule
        follow.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 22, bottom: 10, trailing: 22)
        followButton.configuration = follow
        followButton.accessibilityLabel = "关注"
        addSubview(followButton)

        nameLabel.text = "阿爪"
        nameLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 24, weight: .bold))
        nameLabel.adjustsFontForContentSizeCategory = true

        idLabel.text = "小红书号：nestedpaging"
        idLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        idLabel.textColor = .secondaryLabel
        idLabel.adjustsFontForContentSizeCategory = true

        bioLabel.text = "笔记是双列瀑布，收藏和赞过各自独立滚。分类栏吸顶后外层锁死。"
        bioLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        bioLabel.numberOfLines = 0
        bioLabel.adjustsFontForContentSizeCategory = true

        statsLabel.text = "关注 128    粉丝 3.2万    获赞与收藏 18.6万"
        statsLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        statsLabel.textColor = .secondaryLabel
        statsLabel.adjustsFontForContentSizeCategory = true

        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        [nameLabel, idLabel, bioLabel, statsLabel].forEach { stack.addArrangedSubview($0) }
        addSubview(stack)

        cover.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        followButton.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: topAnchor),
            cover.leadingAnchor.constraint(equalTo: leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: trailingAnchor),
            cover.heightAnchor.constraint(equalToConstant: 188),

            avatar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: cover.bottomAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 76),
            avatar.heightAnchor.constraint(equalToConstant: 76),

            followButton.centerYAnchor.constraint(equalTo: avatar.centerYAnchor, constant: 16),
            followButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            followButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            stack.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = cover.bounds
        avatar.layer.cornerRadius = 38
        avatar.layer.borderColor = UIColor.systemBackground.cgColor
    }
}
