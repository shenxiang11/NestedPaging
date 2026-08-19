# NestedPaging

[English](README.md) | [中文](README.zh-CN.md)

A UIKit nested-scrolling container for pages with a header that scrolls away, a category bar that pins, and multiple child lists that scroll vertically and page horizontally.

Standalone implementation. No third-party dependencies.

**Douyin**

<img src="Docs/screenshots/douyin.png" width="220" alt="Douyin">

**Xiaohongshu**

<img src="Docs/screenshots/xiaohongshu.png" width="220" alt="Xiaohongshu">

**X**

<img src="Docs/screenshots/x.png" width="220" alt="X">

**Instagram**

<img src="Docs/screenshots/instagram.png" width="220" alt="Instagram">

Example project: `Demo/NestedPagingDemo.xcodeproj`. The screens above share one `NestedPagingView`. Only the header, pin bar, and child lists differ. The Demo also includes **Header only**: a header plus one article `UIView`, with no category bar.

## Requirements

- iOS 17+
- Swift 5.9+
- UIKit

## Installation

### Swift Package Manager

In Xcode: File → Add Package Dependencies, then enter

```
https://github.com/shenxiang11/NestedPaging
```

No semantic version has been tagged yet. Depend on the `main` branch.

```swift
dependencies: [
    .package(url: "https://github.com/shenxiang11/NestedPaging", branch: "main")
]
```

Local path:

```swift
.package(path: "../NestedPaging")
```

```swift
import NestedPaging
```

## Usage

Implement `NestedPagingViewDelegate`, pin `NestedPagingView` to its container, then call `reloadData()`. Each child list implements `NestedPagingListViewDelegate` and must forward the callback from its own `scrollViewDidScroll(_:)`.

```swift
import NestedPaging
import UIKit

final class PageViewController: UIViewController, NestedPagingViewDelegate {
    private let pagingView = NestedPagingView()
    private let headerView = YourHeaderView()
    private let pinBar = NestedPagingPinBar(titles: ["Posts", "Works"])

    override func viewDidLoad() {
        super.viewDidLoad()

        pinBar.onSelectIndex = { [weak self] index in
            self?.pagingView.setCurrentListIndex(index, animated: true)
        }

        pagingView.delegate = self
        pagingView.listContainerDidScroll = { [weak self] _ in
            guard let self else { return }
            self.pinBar.setProgress(self.pagingView.currentListScrollProgress, animated: false)
        }

        view.addSubview(pagingView)
        pagingView.frame = view.bounds
        pagingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pagingView.reloadData()
    }

    func tableHeaderViewHeight(in pagingView: NestedPagingView) -> CGFloat { 200 }
    func tableHeaderView(in pagingView: NestedPagingView) -> UIView { headerView }
    func heightForPinSectionHeader(in pagingView: NestedPagingView) -> CGFloat { 48 }
    func viewForPinSectionHeader(in pagingView: NestedPagingView) -> UIView { pinBar }
    func numberOfLists(in pagingView: NestedPagingView) -> Int { 2 }
    func pagingView(_ pagingView: NestedPagingView, initListAt index: Int) -> NestedPagingListViewDelegate {
        YourListView()
    }
}
```

```swift
final class YourListView: UIView, NestedPagingListViewDelegate, UITableViewDelegate {
    private let tableView = UITableView()
    private var scrollCallback: ((UIScrollView) -> Void)?

    func listView() -> UIView { self }
    func listScrollView() -> UIScrollView { tableView }

    func listViewDidScrollCallback(_ callback: @escaping (UIScrollView) -> Void) {
        scrollCallback = callback
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }
}
```

Use `NestedPagingPinBar` for the pin header, or return any custom `UIView`.

When `NestedPagingView` is flush with the top of the screen, the category bar pins below the navigation bar by default. If the container is constrained below `safeAreaLayoutGuide.topAnchor`, the automatic pin offset is `0`.

## Header only (no tabs)

A page with no category bar should not nest a second `UIScrollView`. Return a plain `UIView` from `listView()`, implement `listPreferredContentHeight(forWidth:)`, and let the outer table scroll the header and content together.

```swift
func heightForPinSectionHeader(in pagingView: NestedPagingView) -> CGFloat { 0 }
func numberOfLists(in pagingView: NestedPagingView) -> Int { 1 }

func listPreferredContentHeight(forWidth width: CGFloat) -> CGFloat? {
    // Height of the article UIView at `width`
    articleHeight
}
```

In this mode NestedPaging sizes the cell to that height, skips vertical handoff, and applies the bottom safe-area inset to `mainTableView`. The Demo entry **Header only** shows a rounded white sheet that overlaps the header and can scroll under a transparent navigation bar.

## API

### NestedPagingView

| Member | Description |
| --- | --- |
| `delegate` | Supplies the header, pin bar, and child lists. |
| `pinSectionHeaderVerticalOffset` | Distance from the container top at which the category bar pins. |
| `automaticallyAdjustsPinSectionHeaderVerticalOffset` | Default `true`. When `true`, `pinSectionHeaderVerticalOffset` tracks `safeAreaInsets.top`. |
| `automaticallyAdjustsListContentInset` | Default `true`. Adds the container's bottom / left / right safe-area insets to each child list, or to `mainTableView` when the page reports a preferred content height. |
| `mainTableView` | Outer `UITableView` (plain). |
| `listContainerView` | Horizontal pager. Child lists are created on demand. |
| `currentListIndex` | Index of the current page. |
| `currentScrollingListView` | Child `UIScrollView` currently participating in the vertical handoff. |
| `currentListScrollProgress` | Horizontal page progress: `contentOffset.x / pageWidth`. |
| `mainTableViewMaxContentOffsetY` | Maximum outer offset: `headerHeight - pinSectionHeaderVerticalOffset`. |
| `reloadData()` | Reloads the delegate and refreshes the header, pager, and outer table. |
| `setCurrentListIndex(_:animated:)` | Switches the child list. |
| `mainTableViewDidScroll` | Vertical scroll callback for the outer table. |
| `listContainerDidScroll` | Horizontal pager scroll callback. |
| `didChangeListIndex` | Called when the current page index changes. |

`NSCoder` initialization is unavailable. The type is `@MainActor`.

### NestedPagingViewDelegate

| Method | Description |
| --- | --- |
| `tableHeaderViewHeight(in:)` | Header height. |
| `tableHeaderView(in:)` | Header view, assigned to the outer table’s `tableHeaderView`. |
| `heightForPinSectionHeader(in:)` | Pin bar height. |
| `viewForPinSectionHeader(in:)` | Pin bar view, used as the outer table’s section header. |
| `numberOfLists(in:)` | Number of child lists. |
| `pagingView(_:initListAt:)` | Creates the child list at `index`. Called only when that page enters the nearby range. |

### NestedPagingListViewDelegate

Any `UIScrollView` subclass can be a child list, including `UITableView` and `UICollectionView`. A plain `UIView` works when you report `listPreferredContentHeight(forWidth:)`.

| Method | Description |
| --- | --- |
| `listView()` | Root view embedded in the pager. |
| `listScrollView()` | Scroll view that participates in the vertical nest. Unused when the page reports a preferred content height. |
| `listViewDidScrollCallback(_:)` | Store the callback and invoke it from that scroll view's `scrollViewDidScroll(_:)`. If it is not forwarded, vertical handoff does not work. |
| `listPreferredContentHeight(forWidth:)` | Optional. Default `nil`. When non-`nil`, the cell uses this height and the outer table scrolls the page; there is no inner handoff. |

### NestedPagingPinBar

Equal-width title bar with a sliding indicator. Optional.

```swift
let pinBar = NestedPagingPinBar(titles: ["Posts", "Works"], indicatorColor: .label)
pinBar.onSelectIndex = { index in
    pagingView.setCurrentListIndex(index, animated: true)
}
pinBar.setProgress(pagingView.currentListScrollProgress, animated: false)
```

## Scroll model

The outer container is a plain `UITableView`:

```
┌─────────────────────────────┐
│ tableHeaderView             │  Header
├─────────────────────────────┤
│ section header              │  Category bar (pins via plain style)
├─────────────────────────────┤
│ Single cell                 │  Height = bounds.height − pin bar − pin offset
│   └─ Horizontal paging      │
│        ├─ List 0            │
│        └─ List 1            │
└─────────────────────────────┘
```

The outer table uses `contentInsetAdjustmentBehavior = .never` and `sectionHeaderTopPadding = 0`.

Vertically, the outer table and the current child list recognize the same `UIPanGestureRecognizer`. `contentOffset` decides which view actually moves.

```
maxOffsetY = tableHeaderViewHeight − pinSectionHeaderVerticalOffset
```

| Condition | Outer table | Child list |
| --- | --- | --- |
| Outer offset `< maxOffsetY` | Scrolls | Locked at top (including `adjustedContentInset.top`) |
| Outer offset reaches `maxOffsetY` | Locked | Scrolls |
| Child list has not returned to top | Locked at `maxOffsetY` | Scrolls |
| Pull down after the child list returns to top | Scrolls; header re-enters | Locked at top |

While the header is not pinned, child-list `bounces` is `false`. Only the current child list has `scrollsToTop = true`.

If `listPreferredContentHeight(forWidth:)` is non-`nil`, the cell height is that value and the outer table is the only scroller. The table is not locked at `maxOffsetY`.

Horizontal paging uses a separate paging `UIScrollView` and does not share the vertical gesture. A rightward swipe on the first page does not begin horizontal recognition, so the system interactive-pop gesture can proceed.

## Limitations

A fast flick from the header stops when the outer table reaches `maxOffsetY`. Remaining inertia is not transferred to the current child list. This is inherent to the offset-locking model, not an outstanding bug.
