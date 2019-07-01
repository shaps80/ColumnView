import UIKit
import Columns

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window?.backgroundColor = .white
        
        ((window?.rootViewController as? ColumnsController)?
            .topViewController as? ColumnsLayoutViewController)?.setViewControllers([
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController")
            ], animated: false)
        
        return true
    }

}
