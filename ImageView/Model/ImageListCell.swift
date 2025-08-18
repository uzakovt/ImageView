import UIKit

class ImageListCell: UITableViewCell {
    static let reuseIdentifier = "ImageListCell"
    var date: String?
    var image: UIImage?
    var isLiked: Bool?

    //MARK: UI Components
     lazy var cellImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

     lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.textColor = .white
        dateLabel.textAlignment = .left
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }()

     lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    //MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func likeButtonPressed(_ sender: Any) {
    }

    //MARK: Setup UI

    private func setupUI() {
        self.contentView.backgroundColor = .ypBg

        self.contentView.addSubview(cellImage)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(likeButton)

        NSLayoutConstraint.activate([
            //Cell ImageView
            cellImage.topAnchor.constraint(
                equalTo: self.contentView.topAnchor, constant: 4),
            cellImage.bottomAnchor.constraint(
                equalTo: self.contentView.bottomAnchor, constant: -4),
            cellImage.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor, constant: -16),
            cellImage.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor, constant: 16),
            
            // Date label
            dateLabel.bottomAnchor.constraint(
                equalTo: cellImage.bottomAnchor, constant: -12),
            dateLabel.leadingAnchor.constraint(
                equalTo: cellImage.leadingAnchor, constant: 24),
            
            //likeButton
            likeButton.widthAnchor.constraint(equalToConstant: 45),
            likeButton.heightAnchor.constraint(equalToConstant: 45),
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(
                equalTo: cellImage.trailingAnchor),
        ])
    }
}
