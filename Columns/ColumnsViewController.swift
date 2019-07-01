import UIKit

public extension UIViewController {
    var columnsController: ColumnsLayoutViewController? {
        return parent as? ColumnsLayoutViewController
    }
}

open class ColumnsController: UINavigationController {
    
    private lazy var _internalNav: UINavigationController = {
        return UINavigationController(nibName: nil, bundle: nil)
    }()
    
}

open class ColumnsLayoutViewController: UIViewController {
    
    open var columnWidth: CGFloat = 350
    open var separatorWidth: CGFloat = {
        return 1 / UIScreen.main.scale
    }() {
        didSet {
            invalidateLayout()
        }
    }
    
    open var automaticallyAdjustsNavigationItems: Bool = true
    open var automaticallyAdjustsToolbarItems: Bool = true
    
    open var separatorColor: UIColor = {
        if #available(iOSApplicationExtension 13.0, *) {
            return UIColor.opaqueSeparator
        } else {
            return UIColor(white: 214/255, alpha: 1)
        }
    }() {
        didSet {
            separatorViews.forEach { $0.backgroundColor = separatorColor }
        }
    }
    
    open var _separatorView: UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = separatorColor
        view.autoresizingMask = .flexibleHeight
        return view
    }
    
    open var topViewController: UIViewController? {
        return viewControllers.last
    }
    
    open var visibleViewControllers: [UIViewController] {
        return viewControllers.lazy
            .enumerated()
            .filter { columnsView.bounds.intersects(frameForController(at: $0.offset)) }
            .map { $0.element }
    }
    
    open var viewControllers: [UIViewController] = []
    private var separatorViews: [UIView] = []
    
    private var columnsView: ColumnsLayoutView {
        return view as! ColumnsLayoutView
    }
    
    public init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        pushViewController(rootViewController, animated: false)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func loadView() {
        super.loadView()
        let original = super.view
        
        view = ColumnsLayoutView(frame: .zero)
        view.backgroundColor = original?.backgroundColor
    }
    
    private var _initialLayout: Bool = true
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        defer {
            _initialLayout = false
        }
        
        invalidateLayout()
        guard _initialLayout else { return }
        invalidateController(animated: false)
    }
    
    open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        addChildren([viewController])
        invalidateController(animated: animated)
    }
    
    @discardableResult
    open func popViewController(animated: Bool) -> UIViewController? {
        guard let index = viewControllers.indices.last else { return nil }
        let controllers = removeChildren(after: index)
        invalidateController(animated: animated)
        return controllers.first
    }
    
    @discardableResult
    open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        guard let index = viewControllers.firstIndex(where: { viewController === $0 }) else { return nil }
        let controllers = removeChildren(after: viewControllers.index(after: index))
        invalidateController(animated: animated)
        return controllers
    }
    
    @discardableResult
    open func popToRootViewController(animated: Bool) -> [UIViewController]? {
        guard viewControllers.count > 1 else { return nil }
        let controllers = removeChildren(after: 1)
        invalidateController(animated: animated)
        return controllers
    }
    
    open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        addChildren(viewControllers)
        invalidateController(animated: animated)
    }
    
    open override func show(_ vc: UIViewController, sender: Any?) {
        pushViewController(vc, animated: true)
    }
    
    private func addChildren(_ children: [UIViewController]) {
        children.forEach {
            addChild($0)
            $0.view.frame = frameForController(at: viewControllers.count)
            $0.view.autoresizingMask = .flexibleHeight
            columnsView.addSubview($0.view)
            $0.didMove(toParent: self)
            viewControllers.append($0)
            
            let x = $0.view.frame.maxX
            let y = $0.view.frame.minY
            let w = separatorWidth
            let h = $0.view.frame.height
            let separator = _separatorView
            separator.frame = CGRect(x: x, y: y, width: w, height: h)
            columnsView.addSubview(separator)
            
            separatorViews.append(separator)
        }
        
        invalidateBarItems()
    }
    
    private func removeChildren(after index: Int) -> [UIViewController] {
        guard viewControllers.indices.contains(index) else { return [] }
        let range = index..<viewControllers.count
        let separators = separatorViews[range]
        let controllers = viewControllers[range]
        
        separators.forEach {
            $0.removeFromSuperview()
        }
        
        controllers.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        
        viewControllers.removeSubrange(range)
        separatorViews.removeSubrange(range)
        
        invalidateBarItems()
        
        return Array(controllers)
    }
    
    private func frameForController(at index: Int) -> CGRect {
        guard isViewLoaded else { return .zero }
        var frame = CGRect(origin: .zero, size: view.bounds.size)
        frame.origin.x += CGFloat(index) * columnWidth
        frame.origin.x += CGFloat(index) * separatorWidth
        frame.size.width = columnWidth
        return frame
    }
    
    private func invalidateController(animated: Bool) {
        invalidateContentSize(animated: animated)
        guard columnsView.contentSize.width > columnsView.bounds.width else { return }
        viewControllers.last.map { scroll(to: $0, animated: animated) }
    }
    
    private func scroll(to controller: UIViewController, animated: Bool) {
        columnsView.scrollRectToVisible(controller.view.frame, animated: animated)
    }
    
    private func invalidateContentSize(animated: Bool) {
        var contentSize: CGSize = .zero
        contentSize.height = 1 // need to >0 to ensure scrolling works
        contentSize.width =
            (columnWidth * CGFloat(viewControllers.count))
            + (separatorWidth * CGFloat(viewControllers.count))
        
        UIView.animate(withDuration: 0.2) {
            self.columnsView.contentSize = contentSize
        }
    }
    
    private func invalidateLayout() {
        // if views were added before our layout, we need to update their frames
        viewControllers.enumerated().forEach {
            $0.element.view.frame = frameForController(at: $0.offset)
            
            let separator = separatorViews[$0.offset]
            let x = $0.element.view.frame.maxX
            let y = $0.element.view.frame.minY
            let w = separatorWidth
            let h = $0.element.view.frame.height
            separator.frame = CGRect(x: x, y: y, width: w, height: h)
        }
        
        invalidateContentSize(animated: false)
    }
    
    private func invalidateBarItems() {
        if automaticallyAdjustsNavigationItems {
            title = viewControllers.last?.title
            navigationItem.title = title
            navigationItem.leftBarButtonItems = viewControllers.last?.navigationItem.leftBarButtonItems
            navigationItem.rightBarButtonItems = viewControllers.last?.navigationItem.rightBarButtonItems
            navigationItem.titleView = viewControllers.last?.navigationItem.titleView
            navigationItem.backBarButtonItem = viewControllers.last?.navigationItem.backBarButtonItem
            navigationItem.leftItemsSupplementBackButton = viewControllers.last?.navigationItem.leftItemsSupplementBackButton ?? false
        }
        
        if automaticallyAdjustsToolbarItems {
            toolbarItems = viewControllers.last?.toolbarItems
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            self.visibleViewControllers.last.map {
                self.scroll(to: $0, animated: context.isAnimated)
            }
        }, completion: nil)
    }
    
}

private final class ColumnsLayoutView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = true
        alwaysBounceHorizontal = true
        alwaysBounceVertical = false
        contentInsetAdjustmentBehavior = .never
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
