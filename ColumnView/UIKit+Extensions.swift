import UIKit

public protocol ColumnSeparatorDelegate: class {
    func columnSeparator(_ separator: ColumnSeparator, didAdjustBy delta: CGFloat)
}

open class ColumnSeparator: UIView {
    
    /// this is used so we can automatically begin/end updates on touch
    internal weak var columnViewController: ColumnViewController?
    
    /// The delegate can be used to be notified of drag events
    public weak var delegate: ColumnSeparatorDelegate? {
        didSet { isUserInteractionEnabled = delegate != nil }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var previousLocation: CGPoint = .zero
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        columnViewController?.beginUpdating()
        previousLocation = touches.first?.location(in: self) ?? .zero
        print("Touches began at: \(previousLocation)")
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let location = touches.first?.location(in: self) ?? .zero
        let delta = location.x - previousLocation.x
        
        delegate?.columnSeparator(self, didAdjustBy: delta)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        columnViewController?.endUpdating()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        columnViewController?.endUpdating()
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rect = CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
        return rect.insetBy(dx: -20, dy: -50).contains(point) ? self : nil
    }
    
}

internal final class _ColumnSeparator: ColumnSeparator { }

extension UIViewController {
    
    /// Return a custom separator for this controller. This can be useful when you need a custom view or size for a specific controller.
    @objc open func columnSeparatorView() -> ColumnSeparator? {
        return nil
    }
    
    /// The preferred size for the view controller’s view
    ///
    /// The value in this property is used when displaying the view controller’s content in a column view. To change the value of this property while the view controller is being displayed, call `setNeedsColumnLayoutUpdate()` afterwards.
    @objc open var preferredColumnWidth: CGFloat {
        return columnNavigationController?.columnViewController.defaultColumnWidth ?? 0
    }
    
    /// In most cases you should not need to call this. However if you want to interactively modify the layout you can call this to prevent unintended
    /// scrolling and animation events. Don't forget to also call `endColumnLayoutUpdate()` to resume event handling
    public func beginColumnLayoutUpdate() {
        columnNavigationController?.columnViewController.beginUpdating()
    }
    
    /// Call this method to tell the column view to resume event handling.
    public func endColumnLayoutUpdate() {
        columnNavigationController?.columnViewController.endUpdating()
    }
    
    /// Call this method to cause an invalidation of the column layout. This is not animated by default.
    /// In order to animate the changes, wrap this inside of a UIView animation block.
    ///
    ///     self.columnWidth = 200
    ///     setNeedsColumnLayoutUpdate()
    public func setNeedsColumnLayoutUpdate() {
        columnNavigationController?.columnViewController.invalidateLayout()
        
        let controller = columnNavigationController?.columnViewController
        let oldWidth = view.layer.presentation()?.bounds.width ?? 0
        let newWidth = preferredColumnWidth
        let delta = newWidth - oldWidth
        let newBoundsMaxX = (controller?.underlyingScrollView.bounds.maxX ?? 0) + delta
        let viewMaxX = controller?.viewControllers.last?.view.frame.maxX ?? 0
        let shouldMaintainScrollPosition = viewMaxX <= newBoundsMaxX || self == controller?.topViewController
        
        // if the view's right edge is sitting alongside of the bounds, we'll keep the position
        // if the top controller == self we'll keep it in view
        
        columnNavigationController?.columnViewController.invalidateController(honorScrollBehavior: shouldMaintainScrollPosition, animated: false)
    }
    
    public var columnNavigationController: ColumnNavigationController? {
        return navigationController as? ColumnNavigationController
    }
}

internal extension UIColor {
    static var defaultColumnSeparator: UIColor {
        if #available(iOSApplicationExtension 13.0, *) {
            return UIColor.opaqueSeparator
        } else {
            return UIColor(white: 214/255, alpha: 1)
        }
    }
}
