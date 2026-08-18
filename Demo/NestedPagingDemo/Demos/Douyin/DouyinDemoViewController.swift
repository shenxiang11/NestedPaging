import NestedPaging
import UIKit

final class DouyinDemoViewController: CoverPagingController {
    private let header = DouyinHeaderView()

    override var coverBackgroundColor: UIColor { UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1) }
    override var pinnedNavigationTitle: String { "阿爪" }

    override func viewDidLoad() {
        overrideUserInterfaceStyle = .dark
        super.viewDidLoad()
    }

    override func makeHeader() -> UIView { header }
    override func measureHeader(width: CGFloat) -> CGFloat { header.demoPreferredHeight(forWidth: width, fallback: 420) }

    override func makePinBar() -> UIView & DemoProgressPinBar {
        let bar = NestedPagingPinBar(titles: ["作品", "喜欢", "收藏"], indicatorColor: .white)
        bar.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        return bar
    }

    override func listCount() -> Int { 3 }

    override func makeList(at index: Int) -> NestedPagingListViewDelegate {
        let titles = ["作品", "喜欢", "收藏"]
        return DemoGridListView(
            items: DemoMediaPalette.items(count: 30, title: titles[index], symbol: "play.fill") { "\(12 + $0 * 3)w" },
            style: .portraitVideo
        )
    }
}

private final class DouyinHeaderView: UIView {
    private let cover = UIView()
    private let gradient = CAGradientLayer()
    private let avatar = UIView()
    private let followButton = UIButton(type: .system)
    private let messageButton = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let idLabel = UILabel()
    private let bioLabel = UILabel()
    private let statsLabel = UILabel()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)

        gradient.colors = [
            UIColor(red: 0.42, green: 0.08, blue: 0.18, alpha: 1).cgColor,
            UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1).cgColor,
        ]
        cover.layer.addSublayer(gradient)
        addSubview(cover)

        avatar.backgroundColor = UIColor(red: 1, green: 0.17, blue: 0.33, alpha: 1)
        avatar.layer.borderWidth = 3
        avatar.layer.borderColor = UIColor.black.cgColor
        addSubview(avatar)

        var follow = UIButton.Configuration.filled()
        follow.title = "关注"
        follow.baseBackgroundColor = UIColor(red: 1, green: 0.17, blue: 0.33, alpha: 1)
        follow.baseForegroundColor = .white
        follow.cornerStyle = .medium
        follow.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 28, bottom: 10, trailing: 28)
        followButton.configuration = follow
        followButton.accessibilityLabel = "关注"

        var message = UIButton.Configuration.gray()
        message.title = "消息"
        message.baseForegroundColor = .white
        message.cornerStyle = .medium
        message.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18)
        messageButton.configuration = message
        messageButton.accessibilityLabel = "消息"

        let actions = UIStackView(arrangedSubviews: [followButton, messageButton])
        actions.spacing = 10

        nameLabel.text = "阿爪"
        nameLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 26, weight: .bold))
        nameLabel.textColor = .white
        nameLabel.adjustsFontForContentSizeCategory = true

        idLabel.text = "抖音号：nestedpaging"
        idLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        idLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        idLabel.adjustsFontForContentSizeCategory = true

        bioLabel.text = "作品、喜欢、收藏各自记住滚动位置。从封面甩上去，分类栏吸在导航栏下。"
        bioLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        bioLabel.textColor = UIColor.white.withAlphaComponent(0.86)
        bioLabel.numberOfLines = 0
        bioLabel.adjustsFontForContentSizeCategory = true

        statsLabel.text = "128.6万获赞    326关注    89.2万粉丝"
        statsLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        statsLabel.textColor = .white
        statsLabel.adjustsFontForContentSizeCategory = true

        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        [nameLabel, idLabel, bioLabel, statsLabel, actions].forEach { stack.addArrangedSubview($0) }
        stack.setCustomSpacing(14, after: statsLabel)
        addSubview(stack)

        cover.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cover.topAnchor.constraint(equalTo: topAnchor),
            cover.leadingAnchor.constraint(equalTo: leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: trailingAnchor),
            cover.heightAnchor.constraint(equalToConstant: 210),

            avatar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: cover.bottomAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 84),
            avatar.heightAnchor.constraint(equalToConstant: 84),

            stack.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = cover.bounds
        avatar.layer.cornerRadius = 42
    }
}
