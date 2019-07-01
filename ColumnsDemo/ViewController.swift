import UIKit
import Columns

final class TableViewController: UITableViewController {

    var count: Int = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "Column \(count + 1)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(count + 1)", style: .plain, target: nil, action: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.item == 0 {
            cell.textLabel?.text = "Push from \(count + 1)"
        }
        
        if indexPath.section == 1 && indexPath.item == 0 {
            cell.textLabel?.text = "Pop to \(count + 1)"
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let table = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
            table.count = (navigationController as? ColumnsController)?.childCount ?? 0
            navigationController?.pushViewController(table, animated: true)
        }
        
        if indexPath.section == 1 {
            navigationController?.popToViewController(self, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.showsVerticalScrollIndicator = true
    }
    
}
