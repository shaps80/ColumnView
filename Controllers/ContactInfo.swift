import UIKit

final class ContactInfoViewController: UITableViewController {
    
    var contact: Contact!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = contact.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
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
