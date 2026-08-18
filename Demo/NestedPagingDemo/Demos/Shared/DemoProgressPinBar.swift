import NestedPaging
import UIKit

@MainActor
protocol DemoProgressPinBar: UIView {
    var onSelectIndex: ((Int) -> Void)? { get set }
    func setProgress(_ progress: CGFloat, animated: Bool)
}

extension NestedPagingPinBar: DemoProgressPinBar {}

@MainActor
final class DemoIconPinBar: UIView, DemoProgressPinBar {
    var onSelectIndex: ((Int) -> Void)?

    private let symbols: [String]
    private let buttons: [UIButton]
    private let indicator = UIView()
    private let separator = UIView()
    private let selectedColor: UIColor
    private var progress: CGFloat = 0
    private var selectedIndex = 0

    init(symbols: [String], titles: [String]? = nil, selectedColor: UIColor = .label) {
        self.symbols = symbols
        self.selectedColor = selectedColor
        self.buttons = symbols.enumerated().map { index, name in
            var configuration = UIButton.Configuration.plain()
            configuration.image = UIImage(systemName: name)
            configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
            let button = UIButton(configuration: configuration)
            button.tag = index
            button.accessibilityLabel = titles?[index] ?? name
            return button
        }
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        accessibilityTraits = .tabBar
        for button in buttons {
            button.addAction(UIAction { [weak self] action in
                guard let button = action.sender as? UIButton else { return }
                self?.onSelectIndex?(button.tag)
                self?.setProgress(CGFloat(button.tag), animated: true)
            }, for: .touchUpInside)
            addSubview(button)
        }
        indicator.backgroundColor = selectedColor
        addSubview(indicator)
        separator.backgroundColor = .separator
        addSubview(separator)
        updateButtons()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func setProgress(_ progress: CGFloat, animated: Bool) {
        let maxIndex = CGFloat(max(symbols.count - 1, 1))
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

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !buttons.isEmpty else { return }
        let buttonWidth = bounds.width / CGFloat(buttons.count)
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: bounds.height)
        }
        separator.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1 / traitCollection.displayScale)
        let indicatorWidth = buttonWidth * 0.36
        indicator.frame = CGRect(
            x: (progress + 0.5) * buttonWidth - indicatorWidth / 2,
            y: bounds.height - 2,
            width: indicatorWidth,
            height: 2
        )
    }

    private func updateButtons() {
        for (index, button) in buttons.enumerated() {
            let selected = index == selectedIndex
            button.configuration?.baseForegroundColor = selected ? selectedColor : .secondaryLabel
            button.accessibilityTraits = selected ? [.button, .selected] : [.button]
        }
    }
}
