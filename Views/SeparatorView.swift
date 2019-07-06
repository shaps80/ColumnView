import UIKit
import ColumnView

final class SeparatorView: ColumnSeparatorView, ReusableViewNibLoadable { }

final class Pill: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = bounds.width / 2
        
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
    }
    
}
