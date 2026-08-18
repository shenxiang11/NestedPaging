import UIKit

/// Equal-width category bar with a sliding underline. Use it as the pin section header,
/// or bring your own view.
@MainActor
public final class NestedPagingPinBar: UIView {
    public var onSelectIndex: ((Int) -> Void)?

    public var indicatorColor: UIColor {
        didSet { indicator.backgroundColor = indicatorColor }
    }

    private let titles: [String]
    private let buttons: [UIButton]
    private let indicator = UIView()
    private let separator = UIView()
    private var selectedIndex = 0
    private var progress: CGFloat = 0

    public init(titles: [String], indicatorColor: UIColor = .label) {
        self.titles = titles
        self.indicatorColor = indicatorColor
        self.buttons = titles.enumerated().map { index, title in
            var configuration = UIButton.Configuration.plain()
            configuration.title = title
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.preferredFont(forTextStyle: .body)
                return outgoing
            }

            let button = UIButton(configuration: configuration)
            button.tag = index
            return button
        }
        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    public func setProgress(_ progress: CGFloat, animated: Bool) {
        let maxIndex = CGFloat(max(titles.count - 1, 1))
        self.progress = min(max(progress, 0), maxIndex)
        selectedIndex = Int(self.progress.rounded())
        updateButtons()
        let animations = {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: animations)
        } else {
            animations()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard !buttons.isEmpty else { return }

        let buttonWidth = bounds.width / CGFloat(buttons.count)
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: bounds.height)
        }

        separator.frame = CGRect(
            x: 0,
            y: bounds.height - 1 / traitCollection.displayScale,
            width: bounds.width,
            height: 1 / traitCollection.displayScale
        )

        let indicatorWidth: CGFloat = 28
        let indicatorHeight: CGFloat = 3
        let centerX = (progress + 0.5) * buttonWidth
        indicator.frame = CGRect(
            x: centerX - indicatorWidth / 2,
            y: bounds.height - 8,
            width: indicatorWidth,
            height: indicatorHeight
        )
        indicator.layer.cornerRadius = indicatorHeight / 2
    }

    private func configure() {
        backgroundColor = .systemBackground
        accessibilityTraits = .tabBar

        for button in buttons {
            button.addAction(UIAction { [weak self] action in
                guard let button = action.sender as? UIButton else { return }
                self?.handleTap(at: button.tag)
            }, for: .touchUpInside)
            addSubview(button)
        }

        indicator.backgroundColor = indicatorColor
        addSubview(indicator)

        separator.backgroundColor = .separator
        addSubview(separator)
        updateButtons()
    }

    private func handleTap(at index: Int) {
        guard titles.indices.contains(index) else { return }
        onSelectIndex?(index)
        setProgress(CGFloat(index), animated: true)
    }

    private func updateButtons() {
        for (index, button) in buttons.enumerated() {
            let isSelected = index == selectedIndex
            button.configuration?.baseForegroundColor = isSelected ? .label : .secondaryLabel
            button.accessibilityTraits = isSelected ? [.button, .selected] : [.button]
            button.accessibilityLabel = titles[index]
        }
    }
}
