import UIKit

final class GroupsViewController: ResizableViewController {
    
    let model = Model()

    private lazy var placeholder: PlaceholderViewController = {
        UINib(nibName: "PlaceholderViewController", bundle: nil).instantiate(withOwner: nil, options: nil).first as! PlaceholderViewController
    }()

    override var columnAccessoryViewController: UIViewController? {
        return placeholder
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Groups"
        tableView.allowsMultipleSelection = true
        columnNavigationController?.columnViewController.underlyingScrollView.isScrollEnabled = false
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
        invalidateSelection()
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        invalidateSelection()
    }

    private func invalidateSelection() {
        defer {
            let count = tableView.indexPathsForSelectedRows?.count ?? 0

            switch count {
            case 0:
                placeholder.titleLabel.text = "Select a group"
            case 1:
                placeholder.titleLabel.text = nil
            default:
                placeholder.titleLabel.text = "\(count) selected"
            }
        }

        guard tableView.indexPathsForSelectedRows?.count == 1,
            let indexPath = tableView.indexPathForSelectedRow else {
                columnNavigationController?.popToViewController(self, animated: true)
                return
        }

        let controller = storyboard!.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        controller.contacts = model.folders[indexPath.item].contacts
        columnNavigationController?.pushViewController(controller, after: self, animated: true)
    }
    
}
