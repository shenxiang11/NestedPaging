# NestedPaging

微博 / 简书个人主页那种嵌套滚动：Header 滚走，分类栏吸顶，下面多个列表既能上下滚，也能左右切。

独立实现，**不依赖 JXPagingView**。最低 iOS 17。

## 安装

Xcode → 项目 → Package Dependencies → Add：

```
https://github.com/<your-account>/NestedPaging
```

或本地路径：

```swift
.package(path: "../NestedPaging")
```

然后 `import NestedPaging`。

## 跑 Demo

打开 `Demo/NestedPagingDemo.xcodeproj`，选 NestedPagingDemo 跑起来。

- **个人主页**：封面、导航栏渐变、table + collection
- **基础用法**：最小接入，方便对照代码

## 快速接入

```swift
import NestedPaging

final class PageViewController: UIViewController, NestedPagingViewDelegate {
    private let pagingView = NestedPagingView()
    private let headerView = YourHeaderView()
    private let pinBar = NestedPagingPinBar(titles: ["动态", "作品"])

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

子列表只要交出自己的 `UIScrollView`：

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

分类栏可以用自带的 `NestedPagingPinBar`，也可以换成自己的指示器。

## 原理

核心不是「两个 ScrollView 叠在一起各滚各的」，而是 **同一记垂直手势同时交给外层和内层，再用 `contentOffset` 决定谁真的能动**。

### 结构

外层用一张 plain `UITableView`：

```
┌─────────────────────────────┐
│ tableHeaderView             │  封面 + 资料
├─────────────────────────────┤
│ section header              │  分类栏，plain style 自带吸顶
├─────────────────────────────┤
│ 唯一的 cell                 │  高度 = 视口剩余高度
│   └─ 横向 pager             │
│        ├─ 列表 A            │
│        └─ 列表 B            │
└─────────────────────────────┘
```

cell 高度始终是「屏幕高度 − 分类栏 − 吸顶偏移」。分类栏贴顶之后，当前列表刚好铺满剩余视口。

### 垂直接力

```text
maxOffsetY = headerHeight - pinSectionHeaderVerticalOffset
```

默认会把 `pinSectionHeaderVerticalOffset` 对齐到 `safeAreaInsets.top`，分类栏停在导航栏下面；子列表会自动加上底部 / 左右安全区 inset，最后一行不会顶到 Home 指示条。若要把整个容器放在安全区内部，这两个值会变成 0，无需再手写。

| 手指 | 外层 offset | 内层 offset | 实际在动的 |
| --- | --- | --- | --- |
| 往上滑，Header 还露着 | 增加 | 被重置为 0 | 外层 |
| 继续往上，到达吸顶点 | 锁在 max | 开始增加 | 内层 |
| 往下滑，内层还没到顶 | 锁在 max | 减少 | 内层 |
| 内层回到 0 后再往下 | 减少 | 锁在 0 | 外层，Header 回来 |

横向切页是另一条独立的 paging `UIScrollView`。第一页再往右滑，手势让给系统返回。

### 几个容易踩的点

- `sectionHeaderTopPadding = 0`，否则吸顶条上方会多出一截
- 外层 `contentInsetAdjustmentBehavior = .never`，Header 才能顶到屏幕最上
- Header 未吸顶时关掉子列表 bounce
- 同一时间只让当前子列表 `scrollsToTop = true`

从 Header 用力一甩时，外层滚到吸顶点会刹住，惯性不会灌进子列表。这是这套模型的已知取舍。
