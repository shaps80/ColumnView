import UIKit
import ColumnView

final class NavigationController: ColumnNavigationController {
    
    override func containerType(for traitCollection: UITraitCollection) -> ColumnNavigationController.ContainerType {
        // you could choose to force columnView always for example.
        return super.containerType(for: traitCollection)
    }
    
}

class ResizableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let key = String(describing:type(of: self))
        UserDefaults.standard.register(defaults: [
            key: Float(250)
        ])
    }
    
    private var columnWidth: CGFloat {
        get {
            let key = String(describing:type(of: self))
            let value = UserDefaults.standard.float(forKey: key)
            return CGFloat(value)
        }
        set {
            let key = String(describing:type(of: self))
            UserDefaults.standard.setValue(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    private var minimumColumnWidth: CGFloat = 200
    private var maximumColumnWidth: CGFloat = 600
    
    override func preferredColumnWidth(for traitCollection: UITraitCollection) -> CGFloat {
        return columnWidth
    }
    
    override func columnSeparatorView() -> ColumnSeparator? {
        let view = SeparatorView()
        view.closure = { [unowned self] state, delta in
            switch state {
            case .began:
                self.beginColumnLayoutUpdate()
            case .changed:
                let width = self.columnWidth + delta
                self.columnWidth = max(self.minimumColumnWidth, min(self.maximumColumnWidth, width))
                self.setNeedsColumnLayoutUpdate()
            default:
                self.endColumnLayoutUpdate()
            }
        }
        return view
    }
    
}
