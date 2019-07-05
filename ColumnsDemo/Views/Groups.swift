import UIKit
import ColumnView

final class GroupsViewController: UITableViewController {
    
    private var columnWidth: CGFloat = 250
    private var minimumColumnWidth: CGFloat = 200
    private var maximumColumnWidth: CGFloat = 400
    
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
    
    let model = Model()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Groups"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.folders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath) as! NameCell
        let folder = model.folders[indexPath.item]
        cell.colorImageView?.backgroundColor = folder.color
        cell.nameLabel?.text = folder.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        controller.contacts = model.folders[indexPath.item].contacts
        columnNavigationController?.pushViewController(controller, after: self, animated: true)
    }
    
}
