import UIKit

/// For most cases you should use the `ColumnsController` class since it automatically manages a UINavigationController as well.
/// However if preferred, you can also use this class directly to present a horizontally stacked set of controllers that
/// behaves similarly to UINavigationController but with a presentation closer to column view in Finder or Files (iOS 13)
open class ColumnViewController: UIViewController {
    
    /// Specifies the various supported scroll behaves
    public enum ScrollBehavior {
        /// The controller will attempt to keep the topViewController visible except in the following cases:
        /// 1. When the topViewController is being replaced but remains even partially visible
        case automatic
        /// The controller will attempt to keep the topViewController visible at all times.
        case always
        /// The controller will do nothing to make the view visible.
        case none
    }
    
    open var scrollBehavior: ScrollBehavior = .automatic
    
    open var overscrollAmount: CGFloat = 0 {
        didSet { invalidateContentSize() }
    }
    
    /// Returns the underlying scrollView
    open var underlyingScrollView: UIScrollView {
        return columnView
    }
    
    /// The width to use for each column that presents a controller
    open var defaultColumnWidth: CGFloat = 320 {
        didSet { invalidateLayout() }
    }
    
    /// If true, navigation elements will automatically update as controllers are pushed/popped. Defaults to true
    open var automaticallyAdjustsNavigationItems: Bool = true
    /// If true, toolbar elements will automatically update as controllers are pushed/popped. Defaults to true
    open var automaticallyAdjustsToolbarItems: Bool = true
    
    /// The cached separator views
    private var separatorViews: [UIViewController: ColumnSeparator] = [:]
    
    /// The thickness to use for the separator in-between each controller.
    /// If `separatorClass != nil` and the view provides either an `intrinsicContentSize` or autolayout constraints,
    /// this value will be ignored
    open var defaultSeparatorThickness: CGFloat = 1 / UIScreen.main.scale {
        didSet { invalidateLayout() }
    }
    
    /// The color to use for the seperator in-between each controller.
    /// If `separatorClass != nil` this value will be ignored
    open var separatorColor: UIColor = .defaultColumnSeparator {
        didSet {
            separatorViews.values.lazy
                .filter { $0 is _ColumnSeparator }
                .forEach { $0.backgroundColor = separatorColor }
        }
    }
    
    // Returns a new instance of the default separator view
    private func makeDefaultSeparatorView() -> ColumnSeparator {
        let view = _ColumnSeparator(frame: .zero)
        view.backgroundColor = separatorColor
        view.autoresizingMask = .flexibleHeight
        return view
    }
    
    /// If `separatorClass != nil` a new instance of that class will be return, otherwise this method
    /// calls `makeDefaultSeparatorView()`
    private func makeSeparatorView(for controller: UIViewController) -> ColumnSeparator {
        return controller.columnSeparatorView() ?? makeDefaultSeparatorView()
    }
    
    /// The view controller at the top of the navigation stack
    open var topViewController: UIViewController? {
        return _viewControllers.last
    }
    
    /// The view controllers that are currently visible in the navigation interface
    open var visibleViewControllers: [UIViewController] {
        return _viewControllers.lazy
            .enumerated()
            .filter { columnView.bounds.intersects(frameForController(at: $0.offset)) }
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
    
    private var columnView: ColumnsLayoutView {
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
        invalidateController(honorScrollBehavior: true, animated: false)
    }
    
    /// Pushes a view controller onto the receiver’s stack and updates the display.
    ///
    /// The object in the viewController parameter becomes the top view controller on the navigation stack. Pushing a view controller causes its view to be embedded in the navigation interface. If the animated parameter is true, the view is animated into position; otherwise, the view is simply displayed in its final location.
    /// In addition to displaying the view associated with the new view controller at the top of the stack, this method also updates the navigation bar and tool bar accordingly
    
    /// - Parameter viewController: The view controller to push onto the stack.
    /// - Parameter animated: Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the controller at launch time.
    @discardableResult
    open func pushViewController(_ viewController: UIViewController, after existingViewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let previousCount = viewControllers.count
        
        if topViewController === existingViewController {
            pushViewController(viewController, animated: animated)
            return nil
        } else {
            guard let index = _viewControllers.firstIndex(where: { existingViewController === $0 }) else { return nil }
            let controllers = removeChildren(including: _viewControllers.index(after: index))
            addChildren([viewController])
            invalidateController(honorScrollBehavior: previousCount != viewControllers.count, animated: animated)
            return controllers
        }
    }
    
    open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        addChildren([viewController])
        invalidateController(honorScrollBehavior: true, animated: animated)
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
        invalidateController(honorScrollBehavior: true, animated: animated)
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
        invalidateController(honorScrollBehavior: true, animated: animated)
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
        invalidateController(honorScrollBehavior: true, animated: animated)
        return controllers
    }
    
    /// Replaces the view controllers currently managed by the navigation controller with the specified items
    ///
    /// Use this method to update or replace the current view controller stack without pushing or popping each controller explicitly. In addition, this method lets you update the set of controllers without animating the changes, which might be appropriate at launch time when you want to return the navigation controller to a previous state.
    ///
    /// - Parameter viewControllers: The view controllers to place in the stack. The front-to-back order of the controllers in this array represents the new bottom-to-top order of the controllers in the navigation stack. Thus, the last item added to the array becomes the top item of the navigation stack.
    /// - Parameter animated: If true, animate the pushing or popping of the top view controller. If false, replace the view controllers without any animations
    open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        removeChildren(including: 0)
        addChildren(viewControllers)
        invalidateController(honorScrollBehavior: true, animated: animated)
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
            columnView.addSubview(child.view)
            child.didMove(toParent: self)
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
        let controllers = _viewControllers[range]
        
        controllers.forEach {
            separatorViews[$0]?.removeFromSuperview()
            separatorViews[$0] = nil
        }
        
        controllers.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        
        _viewControllers.removeSubrange(range)
        invalidateBarItems()
        
        return Array(controllers)
    }
    
    private func minXForController(at index: Int) -> CGFloat {
        guard isViewLoaded else { return 0 }
        return (0..<index).reduce(0, { $0 + widthForController(at: $1) })
            + CGFloat(index) * defaultSeparatorThickness
    }
    
    private func widthForController(at index: Int) -> CGFloat {
        guard isViewLoaded else { return 0 }
        guard viewControllers.indices.contains(index) else { return 0 }
        let controller = viewControllers[index]
        let preferred = controller.preferredColumnWidth(for: controller.traitCollection)
        return preferred > 0 ? preferred : defaultColumnWidth
    }
    
    /// Returns the frame for the controller at the specified index
    private func frameForController(at index: Int) -> CGRect {
        guard isViewLoaded else { return .zero }
        var frame: CGRect = .zero
        frame.origin.x = minXForController(at: index)
        frame.origin.y = 0
        frame.size.width = widthForController(at: index)
        frame.size.height = view.bounds.height
        return frame
    }
    
    private func separator(for index: Int) -> ColumnSeparator {
        let controller = viewControllers[index]
        let separator = separatorViews[controller] ?? makeSeparatorView(for: controller)
        separatorViews[controller] = separator
        return separator
    }
    
    private func thicknessForSeparator(at index: Int) -> CGFloat {
        let separator = self.separator(for: index)
        
        let intrinsicWidth = separator.intrinsicContentSize.width
        if intrinsicWidth != UIView.noIntrinsicMetric { return intrinsicWidth }
        
        let layoutWidth = separator.systemLayoutSizeFitting(CGSize(width: 0, height: 0), withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required).width
        if layoutWidth > 0 { return layoutWidth }
        
        return defaultSeparatorThickness
    }
    
    private func frameForSeparator(at index: Int) -> CGRect {
        let controllerFrame = frameForController(at: index)
        let thickness = thicknessForSeparator(at: index)
        return CGRect(x: controllerFrame.maxX, y: controllerFrame.minY, width: thickness, height: controllerFrame.height)
    }
    
    /// Updates the contentSize and scrolls the top most controller into view
    internal func invalidateController(honorScrollBehavior: Bool, animated: Bool) {
        guard isViewLoaded else { return }
        
        UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration), delay: 0,
                       options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.invalidateContentSize()
            guard self.columnView.contentSize.width > self.columnView.bounds.width else { return }
            
            switch self.scrollBehavior {
            case .always:
                self._viewControllers.last.map { self.scroll(to: $0, animated: false) }
            case .automatic:
                guard let index = self.viewControllers.indices.last else { return }
                guard index > 0 else { return }
                let topChildFrame = self.frameForController(at: index)
                guard (honorScrollBehavior || !topChildFrame.intersects(self.columnView.bounds)) && !self.isUpdating else { return }
                self._viewControllers.last.map { self.scroll(to: $0, animated: false) }
            case .none:
                break
            }
        }, completion: nil)
    }
    
    private var isUpdating: Bool = false
    private var _overscrollAmount: CGFloat = 0
    internal func beginUpdating() {
        _overscrollAmount = overscrollAmount
        overscrollAmount = view.bounds.width
        isUpdating = true
    }
    internal func endUpdating() {
        isUpdating = false
        overscrollAmount = _overscrollAmount
        setNeedsColumnLayoutUpdate()
    }
    
    /// Scrolls the specified controller into view
    public func scroll(to controller: UIViewController, animated: Bool) {
        columnView.scrollRectToVisible(controller.view.frame, animated: !isUpdating && animated)
    }
    
    /// Updates the content size
    private func invalidateContentSize() {
        guard isViewLoaded else { return }
        guard let index = viewControllers.indices.last else { return }
        
        var contentSize: CGSize = .zero
        contentSize.height = 1 // need to >0 to ensure scrolling works
        contentSize.width = frameForSeparator(at: index).maxX
        contentSize.width += max(overscrollAmount, 0)
        
        columnView.contentSize = contentSize
    }
    
    /// Updates the layout for all controllers and their associated separators
    internal func invalidateLayout() {
        guard isViewLoaded else { return }
        
        // if views were added before our layout, we need to update their frames
        _viewControllers.enumerated().forEach {
            $0.element.view.frame = frameForController(at: $0.offset)
            let separator = self.separator(for: $0.offset)
            separator.frame = frameForSeparator(at: $0.offset)
            columnView.addSubview(separator)
        }
        
        invalidateContentSize()
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
