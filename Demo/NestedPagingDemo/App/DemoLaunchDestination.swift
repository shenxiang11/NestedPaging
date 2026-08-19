import UIKit

enum DemoLaunchDestination: String {
    case home
    case profile
    case basic
    case headerOnly
    case douyin
    case xiaohongshu
    case x
    case instagram

    static var current: DemoLaunchDestination {
        let value = ProcessInfo.processInfo.environment["NESTED_PAGING_DEMO"] ?? "home"
        return DemoLaunchDestination(rawValue: value) ?? .home
    }

    func makeViewController() -> UIViewController? {
        switch self {
        case .home: nil
        case .profile: ProfileDemoViewController()
        case .basic: BasicDemoViewController()
        case .headerOnly: HeaderOnlyDemoViewController()
        case .douyin: DouyinDemoViewController()
        case .xiaohongshu: XiaohongshuDemoViewController()
        case .x: XDemoViewController()
        case .instagram: InstagramDemoViewController()
        }
    }
}
