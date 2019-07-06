import UIKit

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

