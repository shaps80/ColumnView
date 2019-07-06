import UIKit

/// A delegate for responding to drag events
public protocol ColumnSeparatorDelegate: class {
    
    /// Called when the user drags a separator using its draggable area.
    ///
    /// You can use this to resize your columns as such:
    ///
    ///     columnWidth += delta
    ///
    /// - Parameter separator: The separator being dragged.
    /// - Parameter delta: The delta for the drag.
    func columnSeparator(_ separator: ColumnSeparatorView, didAdjustBy delta: CGFloat)
    
}

/// Represents the base class for a column separator. You can subclass this and return it to
/// provide a custom separator from your view controllers.
open class ColumnSeparatorView: UIView {
    
    /// This is used so we can automatically begin/end updates on touch
    internal weak var columnViewController: ColumnViewController?
    
    /// The delegate can be used to be notified of drag events.
    /// If `delegate == nil` dragging will be disabled
    public weak var delegate: ColumnSeparatorDelegate? {
        didSet { isUserInteractionEnabled = delegate != nil }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = false
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        // TODO: if we can get touchesBegan to work this won't be required, although its an extremely cheap operation.
        columnViewController?.beginUpdating()
        
        let translation = touch.location(in: self).x - touch.previousLocation(in: self).x
        delegate?.columnSeparator(self, didAdjustBy: translation)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        columnViewController?.endUpdating()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        columnViewController?.endUpdating()
    }
    
    /// By default `self` is returned if the corresponding point is inside a rect close to the visual center of the separator.
    /// You can override this function to accept a larger or smaller touch area.
    ///
    /// The following is used to represent the draggable area:
    ///
    ///     CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
    ///         .insetBy(dx: -20, dy: -50)
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
            .insetBy(dx: -20, dy: -50)
            .contains(point) ? self : nil
    }
    
}

// An internal class to make it easy for us to disinguish between default and custom separators.
internal final class _ColumnSeparator: ColumnSeparatorView { }
