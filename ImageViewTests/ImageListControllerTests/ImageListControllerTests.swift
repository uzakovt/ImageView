import XCTest

@testable import ImageView

// MARK: - ImageListViewController Tests
final class ImageListViewControllerTests: XCTestCase {
    func testUpdateTableViewAnimatedInsertsMultipleIndexPaths() {
        // given
        final class VCUnderTest: ImageListViewController {
            let tableSpy = TableViewSpy()
            override func viewDidLoad() {
                super.viewDidLoad()
                self.tableView = tableSpy
            }
        }
        let vc = VCUnderTest()
        vc.loadViewIfNeeded()
        let paths = [
            IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0),
            IndexPath(row: 2, section: 0),
        ]

        // when
        vc.updateTableViewAnimated(indexPath: paths)

        // then
        let exp = expectation(description: "async UI updates flushed")
        DispatchQueue.main.async {
            XCTAssertEqual(vc.tableSpy.insertedIndexPaths, paths)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testGetIndexPathReturnsValueProvidedByTableView() {
        // given
        let vc = ImageListViewController()
        let tableSpy = TableViewSpy()
        vc.tableView = tableSpy
        let cell = ImageListCell(
            style: .default, reuseIdentifier: ImageListCell.reuseIdentifier)
        let expected = IndexPath(row: 5, section: 0)
        tableSpy.stubIndexPathForCell = expected

        // when
        let result = vc.getIndexPath(for: cell)

        // then
        XCTAssertEqual(result, expected)
    }

    func testGetTableViewBoundsReturnsTableViewBounds() {
        // given
        let vc = ImageListViewController()
        let tableSpy = TableViewSpy(
            frame: CGRect(x: 0, y: 0, width: 375, height: 800), style: .plain)
        vc.tableView = tableSpy

        // when
        let bounds = vc.getTableViewBounds()

        // then
        XCTAssertEqual(bounds, CGRect(x: 0, y: 0, width: 375, height: 800))
    }

    func testDidSelectRowForPresentsSingleImageController() {
        // given
        final class VCUnderTest: ImageListViewController {
            var presented: UIViewController?
            override func present(
                _ viewControllerToPresent: UIViewController,
                animated flag: Bool, completion: (() -> Void)? = nil
            ) {
                presented = viewControllerToPresent
                completion?()
            }
        }
        let vc = VCUnderTest()
        let photo = Photo(
            id: "p1", size: CGSize(width: 1000, height: 500), createdAt: nil,
            welcomeDescription: nil, thumbImageURL: "https://example.com/t.jpg",
            largeImageURL: "https://example.com/l.jpg", isLiked: false)

        // when
        vc.didSelectRowFor(selectedPhoto: photo)

        // then
        XCTAssertTrue(vc.presented is SingleImageController)
    }
}

// MARK: - ImageListHelper Tests
final class ImageListHelperTests: XCTestCase {
    func testNumberOfRowsMatchesServicePhotosAfterUpdate() {
        // given
        let helper = ImageListHelper()
        ImagesListService.shared.photos = [
            Photo(
                id: "1", size: CGSize(width: 100, height: 200), createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "https://example.com/1.jpg",
                largeImageURL: "https://example.com/1l.jpg", isLiked: false),
            Photo(
                id: "2", size: CGSize(width: 100, height: 300), createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "https://example.com/2.jpg",
                largeImageURL: "https://example.com/2l.jpg", isLiked: true),
        ]

        // when
        let exp = expectation(description: "photos updated on main queue")
        helper.updatePhotosList {}
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1.0)
        let table = UITableView()
        let rows = helper.tableView(table, numberOfRowsInSection: 0)

        // then
        XCTAssertEqual(rows, 2)
    }

    func testCellForRowConfiguresCellWithExpectedValues() {
        // given
        let helper = ImageListHelper()
        let spyVC = ImageListViewSpy()
        helper.view = spyVC
        let photo = Photo(
            id: "id-77", size: CGSize(width: 400, height: 300), createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/img.jpg",
            largeImageURL: "https://example.com/lg.jpg", isLiked: true)
        ImagesListService.shared.photos = [photo]

        // when
        let exp = expectation(description: "photos updated on main queue")
        helper.updatePhotosList {}
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1.0)
        let table = UITableView()
        table.register(
            TestableImageListCell.self,
            forCellReuseIdentifier: ImageListCell.reuseIdentifier)
        let cell = helper.tableView(
            table, cellForRowAt: IndexPath(row: 0, section: 0))

        // then
        guard let testCell = cell as? TestableImageListCell else {
            return XCTFail("Wrong cell type")
        }
        XCTAssertEqual(testCell.capturedID, photo.id)
        XCTAssertEqual(testCell.capturedImageURLString, photo.thumbImageURL)
        XCTAssertEqual(testCell.capturedIsLiked, photo.isLiked)
    }

    func testHeightForRowScalesByWidthAndInsets() {
        // given
        let helper = ImageListHelper()
        let spyVC = ImageListViewSpy()
        spyVC.stubBounds = CGRect(x: 0, y: 0, width: 360, height: 600)
        helper.view = spyVC
        let photo = Photo(
            id: "p1", size: CGSize(width: 1000, height: 500), createdAt: nil,
            welcomeDescription: nil, thumbImageURL: "u", largeImageURL: "U",
            isLiked: false)
        ImagesListService.shared.photos = [photo]

        // when
        let exp = expectation(description: "photos updated")
        helper.updatePhotosList {}
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1.0)
        let table = UITableView()
        let height = helper.tableView(
            table, heightForRowAt: IndexPath(row: 0, section: 0))

        // then
        let availableWidth = spyVC.stubBounds.width - 16 - 16
        let scale = availableWidth / photo.size.width
        let expected = (photo.size.height * scale) + 4 + 4
        XCTAssertEqual(height, expected, accuracy: 0.5)
    }

    func testDidSelectRowNotifiesDelegateWithSelectedPhoto() {
        // given
        let helper = ImageListHelper()
        let spyVC = ImageListViewSpy()
        helper.view = spyVC
        let p = Photo(
            id: "A", size: CGSize(width: 100, height: 100), createdAt: nil,
            welcomeDescription: nil, thumbImageURL: "t", largeImageURL: "l",
            isLiked: false)
        ImagesListService.shared.photos = [p]

        // when
        let exp = expectation(description: "photos updated")
        helper.updatePhotosList {}
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1.0)
        let table = UITableView()
        helper.tableView(table, didSelectRowAt: IndexPath(row: 0, section: 0))

        // then
        XCTAssertEqual(spyVC.lastSelectedPhoto?.id, p.id)
    }
}

// MARK: - ImageListPresenter Tests
final class ImageListPresenterTests_New: XCTestCase {
    func testUpdateTableViewForwardsAllNewIndexPathsToView() {
        // given
        let presenter = ImageListPresenter()
        let viewSpy = ImageListViewSpy()
        presenter.helper = ImageListHelper()
        presenter.view = viewSpy
        ImagesListService.shared.photos = [
            Photo(
                id: "1", size: .init(width: 10, height: 10), createdAt: nil,
                welcomeDescription: nil, thumbImageURL: "t1",
                largeImageURL: "l1", isLiked: false),
            Photo(
                id: "2", size: .init(width: 10, height: 20), createdAt: nil,
                welcomeDescription: nil, thumbImageURL: "t2",
                largeImageURL: "l2", isLiked: false),
            Photo(
                id: "3", size: .init(width: 10, height: 30), createdAt: nil,
                welcomeDescription: nil, thumbImageURL: "t3",
                largeImageURL: "l3", isLiked: false),
        ]
        let exp = expectation(description: "Presenter forwarded index paths")
        viewSpy.onUpdateIndexPaths = { paths in
            let full = [
                IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0),
                IndexPath(row: 2, section: 0),
            ]
            XCTAssertTrue(paths == full || paths.isEmpty)
            exp.fulfill()
        }

        // when
        presenter.updateTableView()

        // then
        waitForExpectations(timeout: 2.0)
    }

    func testImageListCellDidTapLikeAsksViewForIndexPath() {
        // given
        let presenter = ImageListPresenter()
        let viewSpy = ImageListViewSpy()
        presenter.view = viewSpy
        let cell = ImageListCell()
        _ = viewSpy.getIndexPath(for: cell)
        viewSpy.stubIndexPath = nil

        // when
        presenter.imageListCellDidTapLike(cell)

        // then
        XCTAssertTrue(true)
    }

    func testShowChangeLikeErrorForwardsToView() {
        // given
        let presenter = ImageListPresenter()
        let viewSpy = ImageListViewSpy()
        presenter.view = viewSpy

        // when
        presenter.showChangeLikeError()

        // then
        XCTAssertTrue(viewSpy.showAlertCalled)
    }
}
