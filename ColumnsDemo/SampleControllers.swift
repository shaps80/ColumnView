import UIKit
import Columns

final class SeparatorView: UIView {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
    }
}

final class NavigationController: ColumnNavigationController {
    
    override func containerType(for traitCollection: UITraitCollection) -> ColumnNavigationController.ContainerType {
        return .columnView
    }
    
}

final class GroupsViewController: UITableViewController {
    
    deinit {
        print("\(#function) \(type(of: self))")
    }
    
    let model = Model()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#function) \(type(of: self))")
        
        title = "Groups"
//        columnNavigationController?.columnViewController.defaultColumnWidth = 400
//        columnNavigationController?.columnViewController.separatorClass = SeparatorView.self
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

final class ContactsViewController: UITableViewController {
    
    deinit {
        print("\(#function) \(type(of: self))")
    }
    
    private var _columnWidth: CGFloat = 250
    
    override func preferredColumnWidth(for traitCollection: UITraitCollection) -> CGFloat {
        return _columnWidth
    }
    
    var contacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        print("\(#function) \(type(of: self))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        UIView.animate(withDuration: TimeInterval(0.3), delay: TimeInterval(3), options: [.allowUserInteraction, .curveEaseOut], animations: {
//            self._columnWidth = 400
//            self.setNeedsColumnLayoutUpdate()
//        }, completion: nil)
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
        columnNavigationController?.pushViewController(controller, after: self, animated: true)
    }
    
}

final class ContactInfoViewController: UITableViewController {
    
    deinit {
        print("\(#function) \(type(of: self))")
    }
    
    override func preferredColumnWidth(for traitCollection: UITraitCollection) -> CGFloat {
        return 600
    }
    
    var contact: Contact!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = contact.name
        print("\(#function) \(type(of: self))")
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
        previewImageView.layer.cornerRadius = 20
    }
}
