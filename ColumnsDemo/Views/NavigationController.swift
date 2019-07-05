import UIKit
import ColumnView

final class NavigationController: ColumnNavigationController {
    
    override func containerType(for traitCollection: UITraitCollection) -> ColumnNavigationController.ContainerType {
        return super.containerType(for: traitCollection)
    }
    
}
