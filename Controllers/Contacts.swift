import UIKit

final class ContactsViewController: ResizableViewController {
    
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
        columnNavigationController?.pushViewController(controller, after: self, animated: true)
    }
    
}
