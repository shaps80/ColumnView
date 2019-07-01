import UIKit

open class ColumnsViewController: UIViewController {
    
    open var columnWidth: CGFloat = 350
    open var separatorThickness: CGFloat = {
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
    
    private var _separatorView: UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = separatorColor
        view.autoresizingMask = .flexibleHeight
        return view
    }
    
    open var topViewController: UIViewController? {
        return _viewControllers.last
    }
    
    open var visibleViewControllers: [UIViewController] {
        return _viewControllers.lazy
            .enumerated()
            .filter { columnsView.bounds.intersects(frameForController(at: $0.offset)) }
            .map { $0.element }
    }
    
    private var _viewControllers: [UIViewController] = []
    open var viewControllers: [UIViewController] {
        get { return _viewControllers }
        set { setViewControllers(newValue, animated: false) }
    }
    
    private var separatorViews: [UIView] = []
    
    private var columnsView: ColumnsLayoutView {
        return view as! ColumnsLayoutView
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        addChildren([rootViewController])
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func loadView() {
        super.loadView()
        view = ColumnsLayoutView(frame: .zero)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildren(pendingChildren)
        pendingChildren.removeAll()
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
        guard let index = _viewControllers.indices.last else { return nil }
        let controllers = removeChildren(including: index)
        invalidateController(animated: animated)
        return controllers.first
    }
    
    @discardableResult
    open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        guard let index = _viewControllers.firstIndex(where: { viewController === $0 }) else { return nil }
        let controllers = removeChildren(including: _viewControllers.index(after: index))
        invalidateController(animated: animated)
        return controllers
    }
    
    @discardableResult
    open func popToRootViewController(animated: Bool) -> [UIViewController]? {
        guard _viewControllers.count > 1 else { return nil }
        let controllers = removeChildren(including: 1)
        invalidateController(animated: animated)
        return controllers
    }
    
    open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        removeChildren(including: 0) // remove any existing children so they get released correctly
        addChildren(viewControllers)
        invalidateController(animated: animated)
    }
    
    open override func show(_ vc: UIViewController, sender: Any?) {
        pushViewController(vc, animated: true)
    }
    
    /// This represents children that are added before the view is even loaded.
    /// We store them until viewDidLoad so we don't force a load on each of the controllers unnecessarily
    private var pendingChildren: [UIViewController] = []
    
    private func addChildren(_ children: [UIViewController]) {
        guard isViewLoaded else {
            pendingChildren.append(contentsOf: children)
            return
        }
        
        for child in children {
            _viewControllers.append(child)
            
            addChild(child)
            child.view.frame = frameForController(at: _viewControllers.count - 1)
            child.view.autoresizingMask = .flexibleHeight
            columnsView.addSubview(child.view)
            child.didMove(toParent: self)
            
            let x = child.view.frame.maxX
            let y = child.view.frame.minY
            let w = separatorThickness
            let h = child.view.frame.height
            let separator = _separatorView
            separator.frame = CGRect(x: x, y: y, width: w, height: h)
            columnsView.addSubview(separator)
            
            separatorViews.append(separator)
        }
        
        invalidateBarItems()
    }
    
    @discardableResult
    private func removeChildren(including index: Int) -> [UIViewController] {
        guard isViewLoaded else {
            guard pendingChildren.indices.contains(index) else { return [] }
            let range = index..<pendingChildren.count
            pendingChildren.removeSubrange(range)
            return []
        }
        
        guard _viewControllers.indices.contains(index) else { return [] }
        removeObservers()
        
        let range = index..<_viewControllers.count
        let separators = separatorViews[range]
        let controllers = _viewControllers[range]
        
        separators.forEach {
            $0.removeFromSuperview()
        }
        
        controllers.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        
        _viewControllers.removeSubrange(range)
        separatorViews.removeSubrange(range)
        
        invalidateBarItems()
        
        return Array(controllers)
    }
    
    private func frameForController(at index: Int) -> CGRect {
        guard isViewLoaded else { return .zero }
        var frame = CGRect(origin: .zero, size: view.bounds.size)
        frame.origin.x += CGFloat(index) * columnWidth
        frame.origin.x += CGFloat(index) * separatorThickness
        frame.size.width = columnWidth
        return frame
    }
    
    private func invalidateController(animated: Bool) {
        invalidateContentSize(animated: animated)
        guard columnsView.contentSize.width > columnsView.bounds.width else { return }
        _viewControllers.last.map { scroll(to: $0, animated: animated) }
    }
    
    private func scroll(to controller: UIViewController, animated: Bool) {
        columnsView.scrollRectToVisible(controller.view.frame, animated: animated)
    }
    
    private func invalidateContentSize(animated: Bool) {
        var contentSize: CGSize = .zero
        contentSize.height = 1 // need to >0 to ensure scrolling works
        contentSize.width =
            (columnWidth * CGFloat(_viewControllers.count))
            + (separatorThickness * CGFloat(_viewControllers.count))
        
        UIView.animate(withDuration: 0.2) {
            self.columnsView.contentSize = contentSize
        }
    }
    
    private func invalidateLayout() {
        // if views were added before our layout, we need to update their frames
        _viewControllers.enumerated().forEach {
            $0.element.view.frame = frameForController(at: $0.offset)
            
            let separator = separatorViews[$0.offset]
            let x = $0.element.view.frame.maxX
            let y = $0.element.view.frame.minY
            let w = separatorThickness
            let h = $0.element.view.frame.height
            separator.frame = CGRect(x: x, y: y, width: w, height: h)
        }
        
        invalidateContentSize(animated: false)
    }
    
    deinit {
        removeObservers()
    }
    
    private var observers: [NSKeyValueObservation?] = []
    
    private func removeObservers() {
        observers.forEach { $0?.invalidate() }
        observers.removeAll()
    }
    
    private func invalidateBarItems() {
        let controller = _viewControllers.last
        
        if automaticallyAdjustsNavigationItems {
            observers.append(controller?.observe(\.title, options: [.initial, .new]) { [weak self] controller, _ in
                self?.title = controller.title
            })
            
            observers.append(controller?.observe(\.navigationItem.title, options: [.initial, .new]) { [weak self] controller, _ in
                self?.navigationItem.title = controller.navigationItem.title
            })
            
            observers.append(controller?.observe(\.navigationItem.leftBarButtonItem, options: [.initial, .new]) { [weak self] controller, _ in
                self?.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem
            })
            
            observers.append(controller?.observe(\.navigationItem.rightBarButtonItem, options: [.initial, .new]) { [weak self] controller, _ in
                self?.navigationItem.rightBarButtonItem = controller.navigationItem.rightBarButtonItem
            })
            
            observers.append(controller?.observe(\.navigationItem.leftBarButtonItems, options: [.initial, .new]) { [weak self] controller, _ in
                self?.navigationItem.leftBarButtonItems = controller.navigationItem.leftBarButtonItems
            })
            
            observers.append(controller?.observe(\.navigationItem.rightBarButtonItems, options: [.initial, .new]) { [weak self] controller, _ in
                self?.navigationItem.rightBarButtonItems = controller.navigationItem.rightBarButtonItems
            })
            
            observers.append(controller?.observe(\.navigationItem.titleView, options: [.initial, .new]) { [weak self] controller, _ in
                self?.navigationItem.titleView = controller.navigationItem.titleView
            })
        }
        
        if automaticallyAdjustsToolbarItems {
            toolbarItems = _viewControllers.last?.toolbarItems
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
