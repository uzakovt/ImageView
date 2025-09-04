import Foundation
import UIKit

final class ImageListHelper: NSObject, UITableViewDelegate,
    UITableViewDataSource, ImageListHelperProcol
{
    //MARK: - Variables
    private var photos: [Photo] = []
    private let imageListService = ImagesListService.shared
    weak var view: ImageListControllerProtocol?

    //MARK: - ImageListHelperProtocol
    func getPhotosCount() -> Int {
        photos.count
    }

    func updatePhotosList(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.photos = self.imageListService.photos
            completion()
        }
    }

    func getPhotoByIndexPath(indexPath: IndexPath) -> Photo? {
        return photos[indexPath.row]
    }

    private func updatePhotosListSyncFromService() {
        photos = imageListService.photos
    }

    //MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        photos.count
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
        imageListCell.delegate = view?.presenter as? ImagesListCellDelegate
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
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        guard let view = view else { return 0 }
        let image = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let tableViewBounds = view.getTableViewBounds()
        let imageViewWidth =
            tableViewBounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight =
            image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        let selectedPhoto = photos[indexPath.row]
        view?.didSelectRowFor(selectedPhoto: selectedPhoto)
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
