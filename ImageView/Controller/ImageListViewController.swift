import UIKit

final class ImageListViewController: UIViewController {

    //MARK: - Variables
    private let imageListService = ImagesListService.shared
    private var photos: [Photo] = []

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
        if photos.isEmpty {
            imageListService.fetchPhotosNextPage()
        }
        NotificationCenter.default.addObserver(
            forName: imageListService.didChangeNotification, object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateTableViewAnimated()
        }
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

    //MARK: - Methods
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        self.photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates({
                let indexPath = (oldCount..<newCount).map({ i in
                    IndexPath(row: i, section: 0)
                })
                tableView.insertRows(at: indexPath, with: .automatic)
            })
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ImageListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return photos.count
    }

    func tableView(
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let image = photos[indexPath.row]
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
        guard let imageListCell = cell as? ImageListCell
        else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        let photo = photos[indexPath.row]
        imageListCell.configureCell(
            id: photo.id,
            date: photo.createdAt,
            image: photo.thumbImageURL,
            isLiked: photo.isLiked
        )
        return imageListCell

    }

    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        let singleImageVC = SingleImageController()
        singleImageVC.image = photos[indexPath.row]
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
    }

    func tableView(
        _ tableView: UITableView, willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == photos.count - 1 {
            imageListService.fetchPhotosNextPage()
        }
    }

}

//MARK: - ImagesListCellDelegate
extension ImageListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImageListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) {
            [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
            //TODO: - SHOW ALERT FOR ERROR
            }
        }
    }
}
