import NestedPaging
import UIKit

final class DemoGridListView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, NestedPagingListViewDelegate {
    private let collectionView: UICollectionView
    private let items: [DemoMediaItem]
    private let style: DemoGridStyle
    private var scrollCallback: ((UIScrollView) -> Void)?

    init(items: [DemoMediaItem], style: DemoGridStyle) {
        self.items = items
        self.style = style
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout(style: style))
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.scrollsToTop = false
        collectionView.alwaysBounceVertical = true
        collectionView.register(DemoGridCell.self, forCellWithReuseIdentifier: DemoGridCell.reuseIdentifier)
        addSubview(collectionView)
        collectionView.pinToEdges(of: self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func listView() -> UIView { self }
    func listScrollView() -> UIScrollView { collectionView }

    func listViewDidScrollCallback(_ callback: @escaping (UIScrollView) -> Void) {
        scrollCallback = callback
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DemoGridCell.reuseIdentifier, for: indexPath)
        (cell as? DemoGridCell)?.apply(items[indexPath.item], style: style)
        return cell
    }

    private static func makeLayout(style: DemoGridStyle) -> UICollectionViewLayout {
        switch style {
        case .portraitVideo:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(5 / 12))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
            return UICollectionViewCompositionalLayout(section: NSCollectionLayoutSection(group: group))
        case .photoSquare:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1 / 3))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
            return UICollectionViewCompositionalLayout(section: NSCollectionLayoutSection(group: group))
        case .noteCard:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(320))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(320))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            return UICollectionViewCompositionalLayout(section: section)
        }
    }
}

private final class DemoGridCell: UICollectionViewCell {
    static let reuseIdentifier = "DemoGridCell"

    private let mediaView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let overlay = UILabel()
    private var style: DemoGridStyle = .photoSquare
    private var noteConstraints: [NSLayoutConstraint] = []
    private var fillConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true

        mediaView.layer.cornerCurve = .continuous
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .center
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        iconView.tintColor = .white

        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        metaLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        metaLabel.adjustsFontForContentSizeCategory = true
        metaLabel.textColor = .secondaryLabel
        metaLabel.translatesAutoresizingMaskIntoConstraints = false

        overlay.font = UIFont.preferredFont(forTextStyle: .caption1)
        overlay.textColor = .white
        overlay.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mediaView)
        mediaView.addSubview(iconView)
        mediaView.addSubview(overlay)
        contentView.addSubview(titleLabel)
        contentView.addSubview(metaLabel)

        fillConstraints = [
            mediaView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]

        noteConstraints = [
            mediaView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mediaView.heightAnchor.constraint(equalTo: mediaView.widthAnchor, multiplier: 4 / 3),
            titleLabel.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            metaLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ]

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: mediaView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: mediaView.centerYAnchor),
            overlay.leadingAnchor.constraint(equalTo: mediaView.leadingAnchor, constant: 8),
            overlay.bottomAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: -8),
        ])
        applyConstraints(for: .photoSquare)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        guard style == .noteCard else { return attributes }

        let width = layoutAttributes.size.width
        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        attributes.size = CGSize(width: width, height: size.height)
        return attributes
    }

    func apply(_ item: DemoMediaItem, style: DemoGridStyle) {
        let styleChanged = self.style != style
        self.style = style
        mediaView.backgroundColor = item.tint.withAlphaComponent(0.85)
        iconView.image = UIImage(systemName: item.symbolName)
        overlay.text = item.meta
        titleLabel.text = item.title
        metaLabel.text = item.meta

        let isCard = style == .noteCard
        titleLabel.isHidden = !isCard
        metaLabel.isHidden = !isCard
        overlay.isHidden = style != .portraitVideo
        mediaView.layer.cornerRadius = isCard ? 12 : 0
        contentView.clipsToBounds = !isCard
        if styleChanged {
            applyConstraints(for: style)
        }
    }

    private func applyConstraints(for style: DemoGridStyle) {
        NSLayoutConstraint.deactivate(noteConstraints)
        NSLayoutConstraint.deactivate(fillConstraints)
        NSLayoutConstraint.activate(style == .noteCard ? noteConstraints : fillConstraints)
    }
}
