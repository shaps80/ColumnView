import UIKit

open class ColumnsController: UINavigationController {
    
    open private(set) lazy var columnsViewController: ColumnsViewController = {
        return ColumnsViewController(nibName: nil, bundle: nil)
    }()
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // if the horizontal size class has changed, we need to update. Otherwise do nothing.
        guard previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass else { return }
        update(for: self.traitCollection)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isCollapsed {
            // if we're already collapsed, we don't need to do anything
            update(for: traitCollection)
        }
    }
    
    /// Returns true if ` traitCollection.horizontalSizeClass == .compact`
    private var isCollapsed: Bool {
        return traitCollection.horizontalSizeClass == .compact
    }
    
    private func update(for traitCollection: UITraitCollection) {
        if traitCollection.horizontalSizeClass == .regular {
            // update the columns controller with the navigation controllers children
            columnsViewController.viewControllers = viewControllers
            // update our navigation controller to show our columns controller
            setViewControllers([columnsViewController], animated: false)
        } else {
            // first grab the children so they are not dealloced
            let controllers = columnsViewController.viewControllers
            // now empty our columns controller to prevent unwanted retains
            columnsViewController.viewControllers = []
            // update the navigation controller to show our controllers
            setViewControllers(controllers, animated: false)
        }
    }
    
    open var childCount: Int {
        return isCollapsed ? viewControllers.count : columnsViewController.viewControllers.count
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if isCollapsed {
            super.pushViewController(viewController, animated: animated)
        } else {
            columnsViewController.pushViewController(viewController, animated: animated)
        }
    }

    @discardableResult
    open override func popViewController(animated: Bool) -> UIViewController? {
        if isCollapsed {
            return super.popViewController(animated: animated)
        } else {
            return columnsViewController.popViewController(animated: animated)
        }
    }

    @discardableResult
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if isCollapsed {
            return super.popToViewController(viewController, animated: animated)
        } else {
            return columnsViewController.popToViewController(viewController, animated: animated)
        }
    }

    @discardableResult
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if isCollapsed {
            return super.popToRootViewController(animated: animated)
        } else {
            return columnsViewController.popToRootViewController(animated: animated)
        }
    }
    
}
