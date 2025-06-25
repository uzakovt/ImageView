import UIKit

final class ImageListCell: UITableViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var buttonView: UIButton!
    @IBOutlet weak var dateLabelView: UILabel!
    static let reuseIdentifier = "ImageListCell"
}
