import UIKit

final class ProfileHeaderView: UIView {
    private let coverView = UIView()
    private let coverGradient = CAGradientLayer()
    private let avatarContainer = UIView()
    private let avatarImageView = UIImageView()
    private let followButton = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let handleLabel = UILabel()
    private let bioLabel = UILabel()
    private let statsLabel = UILabel()
    private let contentStack = UIStackView()

    private let coverHeight: CGFloat = 220
    private let avatarSize: CGFloat = 72
    private var isFollowing = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        configureCover()
        configureAvatar()
        configureTexts()
        configureFollowButton()
        configureLayout()
        applyFollowAppearance()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func preferredHeight(forWidth width: CGFloat) -> CGFloat {
        guard width > 0 else { return coverHeight + 180 }
        let target = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return systemLayoutSizeFitting(
            target,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        coverGradient.frame = coverView.bounds
        avatarContainer.layer.cornerRadius = avatarSize / 2
        avatarImageView.layer.cornerRadius = (avatarSize - 6) / 2
    }

    private func configureCover() {
        coverView.clipsToBounds = true
        coverGradient.colors = [ProfilePalette.coverTop.cgColor, ProfilePalette.coverBottom.cgColor]
        coverGradient.startPoint = CGPoint(x: 0.1, y: 0)
        coverGradient.endPoint = CGPoint(x: 0.9, y: 1)
        coverView.layer.addSublayer(coverGradient)
        addSubview(coverView)

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
            self.coverGradient.colors = [ProfilePalette.coverTop.cgColor, ProfilePalette.coverBottom.cgColor]
        }
    }

    private func configureAvatar() {
        avatarContainer.backgroundColor = .systemBackground
        avatarContainer.layer.cornerCurve = .continuous
        addSubview(avatarContainer)

        avatarImageView.image = UIImage(systemName: "bird.fill")
        avatarImageView.tintColor = .white
        avatarImageView.backgroundColor = ProfilePalette.accent
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.clipsToBounds = true
        avatarImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
        avatarImageView.isAccessibilityElement = false
        avatarContainer.addSubview(avatarImageView)
    }

    private func configureTexts() {
        nameLabel.text = ProfileContent.name
        nameLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 26, weight: .bold))
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.textColor = .label

        handleLabel.text = ProfileContent.handle
        handleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        handleLabel.adjustsFontForContentSizeCategory = true
        handleLabel.textColor = .secondaryLabel

        bioLabel.text = ProfileContent.bio
        bioLabel.font = UIFont.preferredFont(forTextStyle: .body)
        bioLabel.adjustsFontForContentSizeCategory = true
        bioLabel.textColor = .label
        bioLabel.numberOfLines = 0

        statsLabel.text = "22 动态  ·  10 作品  ·  20 喜欢"
        statsLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        statsLabel.adjustsFontForContentSizeCategory = true
        statsLabel.textColor = .secondaryLabel
        statsLabel.numberOfLines = 0

        contentStack.axis = .vertical
        contentStack.alignment = .leading
        contentStack.spacing = 8
        contentStack.addArrangedSubview(nameLabel)
        contentStack.addArrangedSubview(handleLabel)
        contentStack.setCustomSpacing(12, after: handleLabel)
        contentStack.addArrangedSubview(bioLabel)
        contentStack.setCustomSpacing(14, after: bioLabel)
        contentStack.addArrangedSubview(statsLabel)
        addSubview(contentStack)
    }

    private func configureFollowButton() {
        followButton.addAction(UIAction { [weak self] _ in
            self?.toggleFollow()
        }, for: .touchUpInside)
        addSubview(followButton)
    }

    private func configureLayout() {
        coverView.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        followButton.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            coverView.topAnchor.constraint(equalTo: topAnchor),
            coverView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverView.heightAnchor.constraint(equalToConstant: coverHeight),

            avatarContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarContainer.centerYAnchor.constraint(equalTo: coverView.bottomAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarContainer.heightAnchor.constraint(equalToConstant: avatarSize),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarSize - 6),
            avatarImageView.heightAnchor.constraint(equalToConstant: avatarSize - 6),

            followButton.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor, constant: 18),
            followButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            followButton.leadingAnchor.constraint(greaterThanOrEqualTo: avatarContainer.trailingAnchor, constant: 12),
            followButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            followButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 88),

            contentStack.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 14),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }

    private func toggleFollow() {
        isFollowing.toggle()
        applyFollowAppearance()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func applyFollowAppearance() {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .subheadline)
            return outgoing
        }

        if isFollowing {
            configuration.title = "已关注"
            configuration.baseBackgroundColor = .secondarySystemFill
            configuration.baseForegroundColor = .label
        } else {
            configuration.title = "关注"
            configuration.baseBackgroundColor = ProfilePalette.accent
            configuration.baseForegroundColor = .white
        }

        followButton.configuration = configuration
        followButton.accessibilityLabel = isFollowing ? "已关注，点按取消关注" : "关注"
    }
}
