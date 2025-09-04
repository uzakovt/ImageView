import Foundation
@testable import ImageView
import UIKit

// MARK: - Test Doubles
final class TableViewSpy: UITableView {
    var insertedIndexPaths: [IndexPath] = []
    var beginUpdatesCount = 0
    var endUpdatesCount = 0
    var stubIndexPathForCell: IndexPath?

    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        updates?()
        completion?(true)
    }
    override func beginUpdates() { beginUpdatesCount += 1 }
    override func endUpdates() { endUpdatesCount += 1 }
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertedIndexPaths.append(contentsOf: indexPaths)
    }
    override func indexPath(for cell: UITableViewCell) -> IndexPath? { stubIndexPathForCell }
}

final class ImageListViewSpy: ImageListControllerProtocol {
    var presenter: (any ImageView.ImageListPresenterProtocol)?
    var showAlertCalled = false
    var lastSelectedPhoto: Photo?
    var lastInsertedIndexPaths: [IndexPath]?
    var stubBounds = CGRect(x: 0, y: 0, width: 320, height: 600)
    var stubIndexPath: IndexPath? = IndexPath(row: 0, section: 0)
    var onUpdateIndexPaths: (([IndexPath]) -> Void)?

    func showChangeLikeErrorAlert() { showAlertCalled = true }
    func didSelectRowFor(selectedPhoto: Photo) { lastSelectedPhoto = selectedPhoto }
    func updateTableViewAnimated(indexPath: [IndexPath]) {
        lastInsertedIndexPaths = indexPath
        onUpdateIndexPaths?(indexPath)
    }
    func getIndexPath(for cell: ImageListCell) -> IndexPath? { stubIndexPath }
    func getTableViewBounds() -> CGRect { stubBounds }
}

final class TestableImageListCell: ImageListCell {
    var capturedID: String?
    var capturedDate: Date?
    var capturedImageURLString: String?
    var capturedIsLiked: Bool?

    override func configureCell(id: String, date: Date?, image: String, isLiked: Bool) {
        self.capturedID = id
        self.capturedDate = date
        self.capturedImageURLString = image
        self.capturedIsLiked = isLiked
    }
}
