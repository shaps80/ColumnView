import UIKit
import ColumnView

final class SeparatorView: ColumnSeparator {
    
    private let pill = Pill()
    
    var closure: (UIGestureRecognizer.State, CGFloat) -> Void {
        get { pill.closure }
        set { pill.closure = newValue }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13.0, *) {
            backgroundColor = .tertiarySystemGroupedBackground
        } else {
            backgroundColor = .black
        }
        
        pill.center = center
        addSubview(pill)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 10, height: UIView.noIntrinsicMetric)
    }
}

extension SeparatorView {
    
    final class Pill: UIView {
        
        var closure: (UIGestureRecognizer.State, CGFloat) -> Void = { _, _ in }
        
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 4, height: 42))
            
            if #available(iOS 13.0, *) {
                backgroundColor = UIColor.systemGray
            } else {
                backgroundColor = UIColor.gray
            }
            
            layer.cornerRadius = 2
            autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            
            if #available(iOS 13.0, *) {
                layer.cornerCurve = .continuous
            }
            
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(handle(gesture:)))
            addGestureRecognizer(gesture)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return bounds.insetBy(dx: -50, dy: -50).contains(point)
        }
        
        @objc private func handle(gesture: UIPanGestureRecognizer) {
            let delta = gesture.translation(in: gesture.view).x
            closure(gesture.state, delta)
            gesture.setTranslation(.zero, in: gesture.view)
        }
        
        override var intrinsicContentSize: CGSize {
            return CGSize(width: 4, height: UIView.noIntrinsicMetric)
        }
        
    }
    
}
