import UIKit
import Columns

final class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let count = columnsController?.viewControllers.count ?? 0
        title = "Column \(count + 1)"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(count + 1)", style: .plain, target: nil, action: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = columnsController?.viewControllers.count ?? 0
        
        if indexPath.section == 0 && indexPath.item == 0 {
            cell.textLabel?.text = "Push from \(count)"
        }
        
        if indexPath.section == 1 && indexPath.item == 0 {
            cell.textLabel?.text = "Pop to \(count)"
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            columnsController?.pushViewController(
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController"),
            animated: true)
        }
        
        if indexPath.section == 1 {
            guard (columnsController?.viewControllers.count ?? 0) > 1 else { return }
            columnsController?.popToViewController(self, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.showsVerticalScrollIndicator = true
    }
    
}
