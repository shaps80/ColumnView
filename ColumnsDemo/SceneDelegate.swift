import UIKit
import ColumnView

@available(iOS 13.0, *)
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let columns = window?.rootViewController as? ColumnNavigationController {
            columns.columnViewController.sizingBehaviour = .fillFirst
        }
        
        window?.backgroundColor = .systemBackground
    }

}
