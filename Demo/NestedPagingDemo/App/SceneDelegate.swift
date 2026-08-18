import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController = DemoNavigationController(rootViewController: HomeViewController())
        if let destination = DemoLaunchDestination.current.makeViewController() {
            navigationController.pushViewController(destination, animated: false)
        }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
