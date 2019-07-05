import UIKit

/// For most cases you should use the `ColumnsController` class since it automatically manages a UINavigationController as well.
/// However if preferred, you can also use this class directly to present a horizontally stacked set of controllers that
/// behaves similarly to UINavigationController but with a presentation closer to column view in Finder or Files (iOS 13)
open class ColumnViewController: UIViewController {
    
    /// The width to use for each column that presents a controller
    open var columnWidth: CGFloat = 320 {
        didSet {
            invalidateLayout()
        }
    }
    
    /// The thickness to use for the separator in-between each controller
    open var separatorThickness: CGFloat = {
        return 1 / UIScreen.main.scale 
        }() {
        didSet {
            invalidateLayout()
        }
    }
    
    /// The color to use for the seperator in-between each controller
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
    
    /// If true, navigation elements will automatically update as controllers are pushed/popped. Defaults to true
    open var automaticallyAdjustsNavigationItems: Bool = true
    /// If true, toolbar elements will automatically update as controllers are pushed/popped. Defaults to true
    open var automaticallyAdjustsToolbarItems: Bool = true
    
    /// The cached separator views
    private var separatorViews: [UIView] = []
    
    /// Makes a new separator view
    private func makeSeparatorView() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = separatorColor
        view.autoresizingMask = .flexibleHeight
        return view
    }
    
    /// The view controller at the top of the navigation stack
    open var topViewController: UIViewController? {
        return _viewControllers.last
    }
    
    /// The view controllers that are currently visible in the navigation interface
    open var visibleViewControllers: [UIViewController] {
        return _viewControllers.lazy
            .enumerated()
            .filter { columnsView.bounds.intersects(frameForController(at: $0.offset)) }
            .map { $0.element }
    }
    
    private var _viewControllers: [UIViewController] = []
    
    /// The view controllers currently on the navigation stack.
    ///
    /// The root view controller is at index 0 in the array, the back view controller is at index n-2, and the top controller is at index n-1, where n is the number of items in the array.
    /// Assigning a new array of view controllers to this property is equivalent to calling the setViewControllers(_:animated:) method with the animated parameter set to false.
    open var viewControllers: [UIViewController] {
        get { return _viewControllers }
        set { setViewControllers(newValue, animated: false) }
    }
    
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
    
    /// Pushes a view controller onto the receiver’s stack and updates the display.
    ///
    /// The object in the viewController parameter becomes the top view controller on the navigation stack. Pushing a view controller causes its view to be embedded in the navigation interface. If the animated parameter is true, the view is animated into position; otherwise, the view is simply displayed in its final location.
    /// In addition to displaying the view associated with the new view controller at the top of the stack, this method also updates the navigation bar and tool bar accordingly
    
    /// - Parameter viewController: The view controller to push onto the stack.
    /// - Parameter animated: Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the controller at launch time.
    open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        addChildren([viewController])
        invalidateController(animated: animated)
    }
    
    /// Pops the top view controller from the navigation stack and updates the display.
    ///
    /// This method removes the top view controller from the stack and makes the new top of the stack the active view controller. If the view controller at the top of the stack is the root view controller, this method does nothing. In other words, you cannot pop the last item on the stack.
    /// In addition to displaying the view associated with the new view controller at the top of the stack, this method also updates the navigation bar and tool bar accordingly
    ///
    /// - Parameter animated: Set this value to true to animate the transition. Pass false if you are setting up a controller before its view is displayed.
    @discardableResult
    open func popViewController(animated: Bool) -> UIViewController? {
        guard let index = _viewControllers.indices.last else { return nil }
        let controllers = removeChildren(including: index)
        invalidateController(animated: animated)
        return controllers.first
    }
    
    /// Pops view controllers until the specified view controller is at the top of the navigation stack.
    ///
    /// In addition to displaying the view associated with the new view controller at the top of the stack, this method also updates the navigation bar and tool bar accordingly
    ///
    /// - Parameter viewController: The view controller that you want to be at the top of the stack. This view controller must currently be on the navigation stack.
    /// - Parameter animated: Set this value to true to animate the transition. Pass false if you are setting up a controller before its view is displayed.
    @discardableResult
    open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        guard let index = _viewControllers.firstIndex(where: { viewController === $0 }) else { return nil }
        let controllers = removeChildren(including: _viewControllers.index(after: index))
        invalidateController(animated: animated)
        return controllers
    }
    
    /// Pops all the view controllers on the stack except the root view controller and updates the display.
    ///
    /// In addition to displaying the view associated with the new view controller at the top of the stack, this method also updates the navigation bar and tool bar accordingly
    ///
    /// - Parameter animated: et this value to true to animate the transition. Pass false if you are setting up a controller before its view is displayed.
    @discardableResult
    open func popToRootViewController(animated: Bool) -> [UIViewController]? {
        guard _viewControllers.count > 1 else { return nil }
        let controllers = removeChildren(including: 1)
        invalidateController(animated: animated)
        return controllers
    }
    
    /// Replaces the view controllers currently managed by the navigation controller with the specified items
    ///
    /// Use this method to update or replace the current view controller stack without pushing or popping each controller explicitly. In addition, this method lets you update the set of controllers without animating the changes, which might be appropriate at launch time when you want to return the navigation controller to a previous state.
    ///
    /// - Parameter viewControllers: The view controllers to place in the stack. The front-to-back order of the controllers in this array represents the new bottom-to-top order of the controllers in the navigation stack. Thus, the last item added to the array becomes the top item of the navigation stack.
    /// - Parameter animated: If true, animate the pushing or popping of the top view controller. If false, replace the view controllers without any animations
    open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        removeChildren(including: 0) // remove any existing children so they get released correctly
        addChildren(viewControllers)
        invalidateController(animated: animated)
    }
    
    /// Interpreted as pushViewController:animated:
    open override func show(_ vc: UIViewController, sender: Any?) {
        pushViewController(vc, animated: true)
    }
    
    /// This represents children that are added before the view is even loaded.
    /// We store them until viewDidLoad so we don't force a load on each of the controllers unnecessarily
    private var pendingChildren: [UIViewController] = []
    
    /// Adds the specified children to the navigatio stack.
    ///
    /// This function is responsible for setting up the parent-child relationship as well as updating the layout and separators
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
            let separator = makeSeparatorView()
            separator.frame = CGRect(x: x, y: y, width: w, height: h)
            columnsView.addSubview(separator)
            
            separatorViews.append(separator)
        }
        
        invalidateBarItems()
    }
    
    /// Removes all children after (and including) the specified index from the navigation stack.
    ///
    /// This function is responsible for severing the parent-child relationship as well as updating the layout and removing separators
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
    
    /// Returns the frame for the controller at the specified index
    private func frameForController(at index: Int) -> CGRect {
        guard isViewLoaded else { return .zero }
        var frame = CGRect(origin: .zero, size: view.bounds.size)
        frame.origin.x += CGFloat(index) * columnWidth
        frame.origin.x += CGFloat(index) * separatorThickness
        frame.size.width = columnWidth
        return frame
    }
    
    /// Updates the contentSize and scrolls the top most controller into view
    private func invalidateController(animated: Bool) {
        invalidateContentSize(animated: animated)
        guard columnsView.contentSize.width > columnsView.bounds.width else { return }
        _viewControllers.last.map { scroll(to: $0, animated: animated) }
    }
    
    /// Scrolls the specified controller into view
    private func scroll(to controller: UIViewController, animated: Bool) {
        columnsView.scrollRectToVisible(controller.view.frame, animated: animated)
    }
    
    /// Updates the content size
    private func invalidateContentSize(animated: Bool) {
        var contentSize: CGSize = .zero
        contentSize.height = 1 // need to >0 to ensure scrolling works
        contentSize.width =
            (columnWidth * CGFloat(_viewControllers.count))
            + (separatorThickness * CGFloat(_viewControllers.count))

        if animated {
            UIView.animate(withDuration: 0.2) {
                self.columnsView.contentSize = contentSize
            }
        } else {
            columnsView.contentSize = contentSize
        }
    }
    
    /// Updates the layout for all controllers and their associated separators
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
    
    /// Retains the observers for all navigation and toolbar elements of the top most controller
    private var observers: [NSKeyValueObservation?] = []
    
    /// Removes all retained observers and invalidates them
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
            observers.append(controller?.observe(\.toolbarItems, options: [.initial, .new]) { [weak self] controller, _ in
                self?.toolbarItems = controller.toolbarItems
            })
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // When we rotate or change size classes, we try and scroll the most visible items back into view.
        coordinator.animate(alongsideTransition: { context in
            self.visibleViewControllers.last.map {
                self.scroll(to: $0, animated: context.isAnimated)
            }
        }, completion: nil)
    }
    
}

/// An internal layout view that provides a basic horizontally stacked layout
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
