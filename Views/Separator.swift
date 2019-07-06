import UIKit
import ColumnView

final class SeparatorView: ColumnSeparator {

    private let pill = Pill()
    
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
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
