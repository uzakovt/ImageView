import UIKit

final class ImageListViewController: UIViewController {

    //MARK: - Variables
    private let photosNames: [String] = Array(0...20).map({ "\($0)" })
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    //MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBg
        tableView.allowsSelection = true
        tableView.register(
            ImageListCell.self,
            forCellReuseIdentifier: ImageListCell.reuseIdentifier)
        return tableView
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        setupUI()
    }

    //MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .ypBg
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypBg
        tableView.separatorStyle = .none

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor),
        ])
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ImageListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return photosNames.count
    }

    func tableView(
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        guard let image = UIImage(named: photosNames[indexPath.row]) else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth =
            tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight =
            image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell

    }

    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        let singleImageVC = SingleImageController()
        singleImageVC.image = UIImage(named: photosNames[indexPath.row])
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
    }

    func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        let cell = cell
        guard let image = UIImage(named: photosNames[indexPath.row]) else {
            return
        }
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        cell.likeButton.setImage(
            indexPath.row % 2 == 0
                ? UIImage(named: "likeButtonOn")
                : UIImage(named: "likeButtonOff"),
            for: .normal)
    }
}
