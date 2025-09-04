import UIKit

protocol ImageListControllerProtocol: AnyObject {
    var presenter: ImageListPresenterProtocol? { get }
    func showChangeLikeErrorAlert()
    func didSelectRowFor(selectedPhoto: Photo)
    func updateTableViewAnimated(indexPath: [IndexPath])
    func getIndexPath(for cell: ImageListCell) -> IndexPath?
    func getTableViewBounds() -> CGRect
}

protocol ImageListPresenterProtocol {
    func updateTableView()
    func checkIfListIsEmpty()
}
