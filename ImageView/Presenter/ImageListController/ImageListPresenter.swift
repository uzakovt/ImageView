import UIKit

final class ImageListPresenter: ImageListPresenterProtocol {

    //MARK: - Variables
    private let imageListService = ImagesListService.shared
    var helper: ImageListHelperProcol?
    weak var view: ImageListControllerProtocol?

    //MARK: - Methods
    func checkIfListIsEmpty() {
        let photos = helper?.getPhotosCount()
        if photos == 0 {
            imageListService.fetchPhotosNextPage()
        }
    }
    func updateTableView() {
        let oldCount = helper?.getPhotosCount()
        helper?.updatePhotosList { [weak self] in
            guard let self else { return }
            let newCount = self.helper?.getPhotosCount()
            if oldCount != newCount {
                guard let oldCount, let newCount else { return }
                let indexPaths = (oldCount..<newCount).map {
                    IndexPath(row: $0, section: 0)
                }
                self.view?.updateTableViewAnimated(indexPath: indexPaths)
            }
        }
    }
    func showChangeLikeError() {
        view?.showChangeLikeErrorAlert()
    }
}

extension ImageListPresenter: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImageListCell) {
        guard let indexPath = view?.getIndexPath(for: cell),
              let photo = helper?.getPhotoByIndexPath(indexPath: indexPath)
        else { return }
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) {
            [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                helper?.updatePhotosList {
                    [weak self] in
                    guard let self,
                          let isLiked = self.helper?.getPhotoByIndexPath(
                            indexPath: indexPath)?.isLiked
                    else {
                        return
                    }
                    cell.setIsLiked(isLiked: isLiked)
                }

            case .failure:
                UIBlockingProgressHUD.dismiss()
                showChangeLikeError()
            }
        }
    }
}
