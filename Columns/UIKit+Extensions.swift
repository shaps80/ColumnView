import UIKit

public protocol ColumnSeparator: UIView {
    init(frame: CGRect)
}
extension UIView: ColumnSeparator { }

extension UIViewController {
    
    /// Override this function to return a preferred column width for the given traitCollection.
    /// - Parameter traitCollection: The current traitCollection of the controller
    @objc open func preferredColumnWidth(for traitCollection: UITraitCollection) -> CGFloat {
        return columnNavigationController?.columnViewController.defaultColumnWidth ?? 0
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
        let newWidth = preferredColumnWidth(for: traitCollection)
        let delta = newWidth - oldWidth
        let newBoundsMaxX = (controller?.underlyingScrollView.bounds.maxX ?? 0) + delta
        let viewMaxX = controller?.viewControllers.last?.view.frame.maxX
        let shouldMaintainScrollPosition = viewMaxX == newBoundsMaxX || self == controller?.topViewController
        
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
