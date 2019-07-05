import UIKit
import Columns

final class GroupsViewController: UITableViewController {
    
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

        if (navigationController as? ColumnViewNavigationController)?.topChild == self {
            navigationController?.pushViewController(controller, animated: true)
        } else {
            navigationController?.popToViewController(self, animated: true)
            navigationController?.pushViewController(controller, animated: false)
        }
    }
    
}

final class ContactsViewController: UITableViewController {
    
    var contacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath) as! NameCell
        let data = contacts[indexPath.item]
        cell.nameLabel?.text = data.name
        cell.colorImageView.backgroundColor = data.color
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "ContactInfoViewController") as! ContactInfoViewController
        controller.contact = contacts[indexPath.item]

        // we should refactor this into ColumnsNavigationController so its handled by default
        if (navigationController as? ColumnViewNavigationController)?.topChild == self {
            navigationController?.pushViewController(controller, animated: true)
        } else {
            navigationController?.popToViewController(self, animated: true)
            navigationController?.pushViewController(controller, animated: false)
        }
    }
    
}

final class ContactInfoViewController: UITableViewController {
    
    var contact: Contact!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = contact.name
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : contact.keyValuePairs.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : "INFORMATION"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoPreviewCell", for: indexPath) as! InfoPreviewCell
            cell.previewImageView.backgroundColor = contact.color
            return cell
        case 1:
            let data = contact.keyValuePairs[indexPath.item]
            let cell = tableView.dequeueReusableCell(withIdentifier: "KeyValueCell", for: indexPath)
            cell.textLabel?.text = data.key
            cell.detailTextLabel?.text = data.value
            return cell
        default:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

final class NameCell: UITableViewCell {
    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorImageView.layer.cornerRadius = colorImageView.bounds.height / 2
    }
}

final class InfoPreviewCell: UITableViewCell {
    @IBOutlet weak var previewImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        previewImageView.layer.cornerRadius = 30
    }
}
