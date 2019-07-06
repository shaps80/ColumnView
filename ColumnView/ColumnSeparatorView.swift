import UIKit

public protocol ColumnSeparatorDelegate: class {
    func columnSeparator(_ separator: ColumnSeparatorView, didAdjustBy delta: CGFloat)
}

open class ColumnSeparatorView: UIView {
    
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
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rect = CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
        return rect.insetBy(dx: -20, dy: -50).contains(point) ? self : nil
    }
    
}

// An internal class to make it easy for us to disinguish between default and custom separators.
internal final class _ColumnSeparator: ColumnSeparatorView { }
