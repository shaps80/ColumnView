import UIKit

/// ColumnsController managed a stack of view controllers similarly to a UINavigationController
/// It uses a standard navigation controller when horizontally compact, otherwise it utilizes
/// a stacked horizontal layout similar to the column view in Finder or Files (iOS 13).
///
/// Titles, navigation items and toolbar items are automatically managed to allow you to work with existing code.
/// In 99% of cases, updating your navigation controllers to use this subclass should be enough.
open class ColumnNavigationController: UINavigationController {
    
    public enum ContainerType {
        case columnView
        case navigationView
    }
    
    /// The underlying view controller that provides the stacked horizontal layout. This can be used to configure its settings.
    open private(set) lazy var columnViewController: ColumnViewController = {
        return ColumnViewController(nibName: nil, bundle: nil)
    }()
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setViewControllers([rootViewController], animated: false)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setViewControllers(viewControllers, animated: false)
    }
    
    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        switch containerType(for: traitCollection) {
        case .columnView:
            setViewControllers(viewControllers, animated: false)
        case .navigationView:
            break // navigation controller does this for us
        }
        
    }

    /// A convenience property that returns the current number of children, regardless of their current presentation
    open var childCount: Int {
        switch containerType(for: traitCollection) {
        case .columnView:
            return columnViewController.viewControllers.count
        case .navigationView:
            return viewControllers.count
        }
    }
    
    open var topChild: UIViewController? {
        switch containerType(for: traitCollection) {
        case .columnView:
            return columnViewController.topViewController
        case .navigationView:
            return topViewController
        }
    }
    
    open var visibleChildren: [UIViewController] {
        switch containerType(for: traitCollection) {
        case .columnView:
            return columnViewController.visibleViewControllers
        case .navigationView:
            return [visibleViewController].compactMap { $0 }
        }
    }
    
    open func containerType(for traitCollection: UITraitCollection) -> ContainerType {
        switch traitCollection.horizontalSizeClass {
        case .regular:
            return .columnView
        case .compact:
            return .navigationView
        default:
            return .navigationView
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // if the horizontal size class has changed, we need to update. Otherwise do nothing.
        guard previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass else { return }
        update(for: self.traitCollection)
    }
    
    private var _initialLayout: Bool = true
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard _initialLayout else { return }
        update(for: traitCollection)
        _initialLayout = false
    }
    
    private func update(for traitCollection: UITraitCollection) {
        switch containerType(for: traitCollection) {
        case .columnView:
            guard let child = super.topViewController, !(child is ColumnViewController) else { return }
            
            let controllers = super.viewControllers
            
            // when the app launches and `isCollapsed == true`, and then we transition to `isCollapsed == false`
            // UIKit seems to think the controllers are still attached to the navigation view, so we need to
            // manually remove their views from its hierarchy.
            controllers.forEach { $0.view.removeFromSuperview() }
            
            // update the columns controller with the navigation controllers children
            columnViewController.viewControllers = controllers
            
            // update our navigation controller to show our columns controller
            super.setViewControllers([columnViewController], animated: false)
        case .navigationView:
            guard let child = super.topViewController, child is ColumnViewController else { return }
            
            // first grab the children so they are not deallocated
            let controllers = columnViewController.viewControllers
            
            // now empty our columns controller to prevent unwanted retains
            columnViewController.viewControllers = []
            
            // update the navigation controller to show our controllers
            super.setViewControllers(controllers, animated: false)
        }
    }
    
    @discardableResult
    open func pushViewController(_ viewController: UIViewController, after existingViewController: UIViewController, animated: Bool) -> [UIViewController]? {
        switch containerType(for: traitCollection) {
        case .columnView:
            return columnViewController.pushViewController(viewController, after: existingViewController, animated: animated)
        case .navigationView:
            super.pushViewController(viewController, animated: animated)
            return nil
        }
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        switch containerType(for: traitCollection) {
        case .columnView:
            columnViewController.pushViewController(viewController, animated: animated)
        case .navigationView:
            super.pushViewController(viewController, animated: animated)
        }
    }

    @discardableResult
    open override func popViewController(animated: Bool) -> UIViewController? {
        switch containerType(for: traitCollection) {
        case .columnView:
            return columnViewController.popViewController(animated: animated)
        case .navigationView:
            return super.popViewController(animated: animated)
        }
    }

    @discardableResult
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        switch containerType(for: traitCollection) {
        case .columnView:
            return columnViewController.popToViewController(viewController, animated: animated)
        case .navigationView:
            return super.popToViewController(viewController, animated: animated)
        }
    }

    @discardableResult
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        switch containerType(for: traitCollection) {
        case .columnView:
            return columnViewController.popToRootViewController(animated: animated)
        case .navigationView:
            return super.popToRootViewController(animated: animated)
        }
    }
    
    open override var viewControllers: [UIViewController] {
        get { return super.viewControllers }
        set {
            switch containerType(for: traitCollection) {
            case .columnView:
                columnViewController.setViewControllers(newValue, animated: false)
            case .navigationView:
                super.setViewControllers(newValue, animated: false)
            }
        }
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        switch containerType(for: traitCollection) {
        case .columnView:
            columnViewController.setViewControllers(viewControllers, animated: animated)
        case .navigationView:
            super.setViewControllers(viewControllers, animated: animated)
        }
    }
    
}
