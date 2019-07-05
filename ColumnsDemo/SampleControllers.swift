import UIKit
import Columns

final class SeparatorView: ColumnSeparator {
    
    final class Pill: UIView {
        
        var closure: (UIGestureRecognizer.State, CGFloat) -> Void = { _, _ in }
        
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 4, height: 42))
            
            if #available(iOS 13.0, *) {
                backgroundColor = UIColor.systemGray
            } else {
                backgroundColor = UIColor.gray
            }
            
            layer.cornerRadius = 2
            autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            
            if #available(iOS 13.0, *) {
                layer.cornerCurve = .continuous
            }
            
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(handle(gesture:)))
            addGestureRecognizer(gesture)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return bounds.insetBy(dx: -50, dy: -50).contains(point)
        }
        
        @objc private func handle(gesture: UIPanGestureRecognizer) {
            let delta = gesture.translation(in: gesture.view).x
            closure(gesture.state, delta)
            gesture.setTranslation(.zero, in: gesture.view)
        }
        
        override var intrinsicContentSize: CGSize {
            return CGSize(width: 4, height: UIView.noIntrinsicMetric)
        }
        
    }
    
    private let pill = Pill()
    
    var closure: (UIGestureRecognizer.State, CGFloat) -> Void {
        get { pill.closure }
        set { pill.closure = newValue }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13.0, *) {
            backgroundColor = .tertiarySystemGroupedBackground
        } else {
            backgroundColor = .black
        }
        
        pill.center = center
        addSubview(pill)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 10, height: UIView.noIntrinsicMetric)
    }
}

final class NavigationController: ColumnNavigationController {
    
    override func containerType(for traitCollection: UITraitCollection) -> ColumnNavigationController.ContainerType {
        return super.containerType(for: traitCollection)
    }
    
}

final class GroupsViewController: UITableViewController {
    
    private var columnWidth: CGFloat = 250
    private var minimumColumnWidth: CGFloat = 200
    private var maximumColumnWidth: CGFloat {
        return columnNavigationController?.view.bounds.width ?? minimumColumnWidth
    }
    
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
        columnNavigationController?.pushViewController(controller, after: self, animated: true)
    }
    
}

final class ContactInfoViewController: UITableViewController {
    
    override func preferredColumnWidth(for traitCollection: UITraitCollection) -> CGFloat {
        return 600
    }
    
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
        previewImageView.layer.cornerRadius = 20
    }
}
