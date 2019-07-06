import UIKit

final class GroupsViewController: ResizableViewController {
    
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
