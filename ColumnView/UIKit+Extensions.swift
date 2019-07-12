import UIKit

extension UIViewController {
    
    /// Return a custom separator for this controller. This can be useful when you need a custom view or size for a specific controller.
    @objc open func columnSeparatorView() -> ColumnSeparatorView? {
        return nil
    }
    
    /// The preferred size for the view controller’s view
    ///
    /// The value in this property is used when displaying the view controller’s content in a column view. To change the value of this property while the view controller is being displayed, call `setNeedsColumnLayoutUpdate()` afterwards.
    @objc open var preferredColumnWidth: CGFloat {
        return columnNavigationController?.columnViewController.defaultColumnWidth ?? 0
    }

    /// If you return a view here, the column view will show this in the remaining space until you push another view on top of it.
    /// This is useful for showing an empty selection for example.
    ///
    /// Note: The view will be 'collapsed' if there is no available space. Furthermore if you support resizing columns, the placeholder will adjust accordingly.
    @objc open var columnAccessoryViewController: UIViewController? {
        return nil
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
        
        /// Refactor to make use of a similar API to `targetContentOffsetForProposedContentOffset`
        ///
        let controller = columnNavigationController?.columnViewController
        let oldWidth = view.layer.presentation()?.bounds.width ?? 0
        let newWidth = preferredColumnWidth
        let delta = newWidth - oldWidth
        let newBoundsMaxX = (controller?.underlyingScrollView.bounds.maxX ?? 0) + delta
        let viewMaxX = controller?.viewControllers.last?.view.frame.maxX ?? 0
        let shouldMaintainScrollPosition: Bool
        
        switch traitCollection.layoutDirection {
        case .rightToLeft:
            shouldMaintainScrollPosition = controller?.topViewController?.view.frame.minX == controller?.underlyingScrollView.contentOffset.x
        default:
            shouldMaintainScrollPosition = viewMaxX <= newBoundsMaxX || self == controller?.topViewController
        }
        
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
