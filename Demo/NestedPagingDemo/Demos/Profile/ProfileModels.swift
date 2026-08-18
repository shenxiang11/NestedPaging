import UIKit

enum ProfileTab: Int, CaseIterable {
    case feed
    case works
    case likes

    var title: String {
        switch self {
        case .feed: "动态"
        case .works: "作品"
        case .likes: "喜欢"
        }
    }
}

struct ProfileFeedItem: Hashable {
    let id: String
    let title: String
    let subtitle: String
    let symbolName: String
    let tint: UIColor
}

struct ProfileWorkItem: Hashable {
    let id: String
    let title: String
    let subtitle: String
    let symbolName: String
    let tint: UIColor
}

enum ProfilePalette {
    static let coverTop = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.20, blue: 0.36, alpha: 1)
            : UIColor(red: 0.31, green: 0.42, blue: 0.78, alpha: 1)
    }

    static let coverBottom = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.10, green: 0.12, blue: 0.20, alpha: 1)
            : UIColor(red: 0.45, green: 0.58, blue: 0.90, alpha: 1)
    }

    static let accent = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.62, green: 0.72, blue: 1.0, alpha: 1)
            : UIColor(red: 0.29, green: 0.40, blue: 0.78, alpha: 1)
    }
}

enum ProfileContent {
    static let name = "阿爪"
    static let handle = "@nestedpaging"
    static let bio = "外层吸顶，内层接手。主列表和子列表同时识别手势，再用 offset 决定谁真正在滚。"

    static let workItems: [ProfileWorkItem] = [
        .init(id: "w1", title: "Morph Slider", subtitle: "Metal 转场", symbolName: "slider.horizontal.below.square.filled.and.square", tint: .systemIndigo),
        .init(id: "w2", title: "潮汐", subtitle: "符号起伏", symbolName: "water.waves", tint: .systemTeal),
        .init(id: "w3", title: "挂绳工牌", subtitle: "物理摆动", symbolName: "person.text.rectangle", tint: .systemOrange),
        .init(id: "w4", title: "Profile Card", subtitle: "倾斜光泽", symbolName: "person.crop.rectangle", tint: .systemPink),
        .init(id: "w5", title: "文字描边", subtitle: "描边排版", symbolName: "textformat", tint: .systemPurple),
        .init(id: "w6", title: "双端滑块", subtitle: "区间选择", symbolName: "alternatingcurrent", tint: .systemBlue),
        .init(id: "w7", title: "验证码", subtitle: "逐格输入", symbolName: "number.square", tint: .systemGreen),
        .init(id: "w8", title: "自定义 Tab Bar", subtitle: "玻璃底栏", symbolName: "rectangle.bottomhalf.inset.filled", tint: .systemRed),
        .init(id: "w9", title: "环绕图标", subtitle: "轨道运动", symbolName: "circle.circle", tint: .systemIndigo),
        .init(id: "w10", title: "嵌套滚动", subtitle: "本页效果", symbolName: "rectangle.split.3x1", tint: .systemTeal),
    ]

    static func items(for tab: ProfileTab) -> [ProfileFeedItem] {
        switch tab {
        case .feed: feedItems
        case .likes: likeItems
        case .works: []
        }
    }

    private static let feedItems: [ProfileFeedItem] = [
        .init(id: "f1", title: "主列表和子列表同时识别垂直 pan，再用 contentOffset 决定谁能滚。", subtitle: "刚刚 · 原理", symbolName: "hand.draw", tint: .systemIndigo),
        .init(id: "f2", title: "Header 还露着的时候，子列表被锁在 0，所有位移都交给外层 table。", subtitle: "10 分钟前 · 外层", symbolName: "arrow.up.to.line", tint: .systemBlue),
        .init(id: "f3", title: "分类栏吸顶之后，外层锁住，当前子列表才开始真正滚动。", subtitle: "32 分钟前 · 内层", symbolName: "pin", tint: .systemTeal),
        .init(id: "f4", title: "左右滑切换页面走独立的横向 pager，和垂直嵌套互不抢手势。", subtitle: "1 小时前 · 分页", symbolName: "rectangle.split.3x1", tint: .systemPurple),
        .init(id: "f5", title: "子列表只要给出自己的 UIScrollView，table / collection 都能嵌进去。", subtitle: "今天 · 协议", symbolName: "scroll", tint: .systemOrange),
        .init(id: "f6", title: "从顶部用力一甩时，标准实现会在吸顶点刹住。", subtitle: "今天 · 细节", symbolName: "tornado", tint: .systemPink),
        .init(id: "f7", title: "不同子列表可以保留各自的滚动位置，切回来还在原地。", subtitle: "昨天 · 状态", symbolName: "bookmark", tint: .systemGreen),
        .init(id: "f8", title: "导航栏透明度跟着外层 offset 走，封面滚走后标题才显现。", subtitle: "昨天 · 导航", symbolName: "menubar.rectangle", tint: .systemIndigo),
        .init(id: "f9", title: "边缘右滑在第一页让给系统返回，避免和横向 pager 打架。", subtitle: "本周 · 手势", symbolName: "chevron.backward", tint: .systemBlue),
        .init(id: "f10", title: "sectionHeaderTopPadding 必须清零，否则吸顶条会凭空多出一截。", subtitle: "本周 · 坑", symbolName: "ruler", tint: .systemRed),
        .init(id: "f11", title: "子列表在 Header 未吸顶时关掉 bounce，能少掉不少回弹抢位移。", subtitle: "本周 · bounce", symbolName: "arrow.up.and.down", tint: .systemTeal),
        .init(id: "f12", title: "cell 高度始终是视口剩余高度，而不是 Header 下方那一小截。", subtitle: "本周 · 布局", symbolName: "rectangle.portrait", tint: .systemPurple),
        .init(id: "f13", title: "点击状态栏只滚当前子列表，避免多个 scrollsToTop 同时响应。", subtitle: "更早 · 状态栏", symbolName: "arrow.up.to.line.compact", tint: .systemOrange),
        .init(id: "f14", title: "微博、简书、QQ 联系人，都是这一套外层吸顶 + 内层接手。", subtitle: "更早 · 参考", symbolName: "quote.bubble", tint: .systemPink),
        .init(id: "f15", title: "分类栏本身是 table 的 section header，所以吸顶是免费的。", subtitle: "更早 · Table", symbolName: "tablecells", tint: .systemGreen),
        .init(id: "f16", title: "列表懒加载：真正滑到这一页才创建。", subtitle: "更早 · 性能", symbolName: "hare", tint: .systemIndigo),
        .init(id: "f17", title: "回拉子列表到顶之后，下一次下拉才会把 Header 重新带出来。", subtitle: "更早 · 回程", symbolName: "arrow.down.to.line", tint: .systemBlue),
        .init(id: "f18", title: "横向 pager 打开 directional lock，斜着滑也不会又切页又滚列表。", subtitle: "更早 · 方向锁", symbolName: "lock.rotation", tint: .systemTeal),
        .init(id: "f19", title: "主 table 隐藏滚动条，指示条只出现在正在滚的那一个子列表上。", subtitle: "更早 · 指示条", symbolName: "line.3.horizontal", tint: .systemPurple),
        .init(id: "f20", title: "再往下全是占位内容，保证每个 tab 都能独立滚出一段距离。", subtitle: "更早 · 占位", symbolName: "ellipsis.circle", tint: .systemOrange),
        .init(id: "f21", title: "如果要做首页下拉刷新，刷新头挂在外层 mainTableView 上。", subtitle: "更早 · 刷新", symbolName: "arrow.clockwise", tint: .systemPink),
        .init(id: "f22", title: "子列表自己的上拉加载，则挂在各自的 listScrollView 上。", subtitle: "更早 · 加载", symbolName: "arrow.down.circle", tint: .systemGreen),
    ]

    private static let likeItems: [ProfileFeedItem] = [
        .init(id: "l1", title: "微博个人主页", subtitle: "外层吸顶的经典样本", symbolName: "person.crop.circle", tint: .systemOrange),
        .init(id: "l2", title: "简书主页", subtitle: "作品 / 动态分段", symbolName: "book", tint: .systemRed),
        .init(id: "l3", title: "QQ 联系人", subtitle: "多列表左右切换", symbolName: "person.2", tint: .systemBlue),
        .init(id: "l4", title: "UIScrollView 同时识别", subtitle: "UIGestureRecognizerDelegate", symbolName: "hand.tap", tint: .systemTeal),
        .init(id: "l5", title: "Section Header 吸顶", subtitle: "UITableView plain style", symbolName: "pin.circle", tint: .systemPurple),
        .init(id: "l6", title: "横向 pagingEnabled", subtitle: "独立的 list container", symbolName: "rectangle.split.2x1", tint: .systemIndigo),
        .init(id: "l7", title: "contentOffset 钳制", subtitle: "谁在滚，谁就不能越界", symbolName: "lock", tint: .systemGreen),
        .init(id: "l8", title: "点击状态栏回顶", subtitle: "只滚当前 list", symbolName: "chevron.up.circle", tint: .systemOrange),
        .init(id: "l9", title: "横竖屏切换", subtitle: "容器宽度变化后重排", symbolName: "rotate.right", tint: .systemTeal),
        .init(id: "l10", title: "Header 高度动态变化", subtitle: "刷新后重算 maxOffset", symbolName: "arrow.up.and.down.text.horizontal", tint: .systemBlue),
        .init(id: "l11", title: "Collection 网格子页", subtitle: "不一定非要用 table", symbolName: "square.grid.2x2", tint: .systemOrange),
        .init(id: "l12", title: "嵌套滚动调试时，先把两边的 scroll indicator 打开。", subtitle: "占位 · 调试", symbolName: "wrench.and.screwdriver", tint: .systemTeal),
        .init(id: "l13", title: "再来几条，让这个 tab 也能独立滚起来。", subtitle: "占位 · 喜欢", symbolName: "heart", tint: .systemPink),
        .init(id: "l14", title: "最后一条。回到顶部，Header 应该能被重新拉下来。", subtitle: "占位 · 回顶", symbolName: "arrow.uturn.up", tint: .systemIndigo),
        .init(id: "l15", title: "Swift Package 接入后，业务页只负责 Header 和子列表。", subtitle: "占位 · SPM", symbolName: "shippingbox", tint: .systemPurple),
        .init(id: "l16", title: "分类栏可以用自带 PinBar，也可以换成自己的指示器。", subtitle: "占位 · 自定义", symbolName: "paintbrush", tint: .systemBlue),
        .init(id: "l17", title: "第一页往右滑会让给系统返回手势。", subtitle: "占位 · 返回", symbolName: "arrow.left", tint: .systemGreen),
        .init(id: "l18", title: "外层 bounce 只在顶部开启，方便以后挂下拉刷新。", subtitle: "占位 · 刷新", symbolName: "arrow.clockwise", tint: .systemOrange),
        .init(id: "l19", title: "切走再切回来，每个 tab 的滚动位置还在。", subtitle: "占位 · 状态", symbolName: "bookmark", tint: .systemTeal),
        .init(id: "l20", title: "这就是 NestedPaging 的全部心智模型。", subtitle: "占位 · 结束", symbolName: "checkmark.circle", tint: .systemIndigo),
    ]
}
