import Foundation

protocol ImageListHelperProcol {
    func getPhotosCount() -> Int
    func updatePhotosList(completion: @escaping () -> Void)
    func getPhotoByIndexPath(indexPath: IndexPath) -> Photo?
}
