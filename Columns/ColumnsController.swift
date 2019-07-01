import UIKit

/// ColumnsController managed a stack of view controllers similarly to a UINavigationController
/// It uses a standard navigation controller when horizontally compact, otherwise it utilizes
/// a stacked horizontal layout similar to the column view in Finder or Files (iOS 13).
///
/// Titles, navigation items and toolbar items are automatically managed to allow you to work with existing code.
/// In 99% of cases, updating your navigation controllers to use this subclass should be enough.
open class ColumnsController: UINavigationController {
    
    /// The underlying view controller that provides the stacked horizontal layout. This can be used to configure its settings.
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
    
    /// A convenience property that returns the current number of children, regardless of their current presentation
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
