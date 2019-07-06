import UIKit
import ColumnView

final class NavigationController: ColumnNavigationController {
    
    override func containerType(for traitCollection: UITraitCollection) -> ColumnNavigationController.ContainerType {
        // you could choose to force columnView always for example.
        return super.containerType(for: traitCollection)
    }
    
}

class ResizableViewController: UITableViewController {
    
    /// Set this to `true` to have all columns adjust their widths at the same
    /// time to the same value automatically.
    private let resizeColumnsUniformly: Bool = true
    
    private var userDefaultsKey: String {
        return resizeColumnsUniformly
            ? "column-width"
            : String(describing:type(of: self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         This is a fairly rudimentary approach but essentially we want to start all new instances
         with the users stored default value. This allows multiple windows to have separate 'live'
         values for their column widths.
         
         The key used here is just the 'type' of the controller, in a more complete example this
         could be generated from the content itself allowing for more fine grained defaults.
         */
        
        UserDefaults.standard.register(defaults: [
            userDefaultsKey: Float(320)
        ])
        
        // we need to restore our last saved value to ensure our view is in-sync with our model
        columnWidth = CGFloat(UserDefaults.standard.float(forKey: userDefaultsKey))
    }
    
    private var _columnWidth: CGFloat = 0
    private var columnWidth: CGFloat {
        get {
            if resizeColumnsUniformly {
                /// in order to have all controllers resize we need to read from our current defaults
                return CGFloat(UserDefaults.standard.float(forKey: userDefaultsKey))
            } else {
                return _columnWidth
            }
        }
        set {
            _columnWidth = newValue
            
            if resizeColumnsUniformly {
                /// in order to have all controllers resize, we need to update our defaults immediately
                UserDefaults.standard.setValue(_columnWidth, forKey: userDefaultsKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    private var minimumColumnWidth: CGFloat = 200
    private var maximumColumnWidth: CGFloat = 600
    
    override var preferredColumnWidth: CGFloat {
        return columnWidth
    }
    
    override func columnSeparatorView() -> ColumnSeparator? {
        let view = SeparatorView()
        view.delegate = self
        return view
    }
    
}

extension ResizableViewController: ColumnSeparatorDelegate {
    
    func columnSeparator(_ separator: ColumnSeparator, didAdjustBy delta: CGFloat) {
        let width = self.columnWidth + delta
        self.columnWidth = max(self.minimumColumnWidth, min(self.maximumColumnWidth, width))
        self.setNeedsColumnLayoutUpdate()
    }
    
}