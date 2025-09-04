import XCTest

@testable import ImageView

final class WebViewControllerTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoadRequest() {
        //given
        let viewControllerSpy = WebViewControllerSpy()
        let authHelper = AuthHelper(configuration: .standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewControllerSpy.presenter = presenter
        presenter.view = viewControllerSpy

        //when
        presenter.viewDidLoad()

        //then
        XCTAssertTrue(viewControllerSpy.presenterCalledLoad)
    }

    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper(configuration: .standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        //then
        XCTAssertFalse(shouldHideProgress)
    }

    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper(configuration: .standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0

        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        //then
        XCTAssertTrue(shouldHideProgress)
    }

    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        let url = authHelper.authURL()

        //when
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth url is nil")
            return
        }
        guard let configuration else {
            XCTFail("Configuration is nil")
            return
        }

        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }

    func testCodeFromURL() {
        //given

        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        var urlComponents = URLComponents(
            string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = [
            URLQueryItem(name: "code", value: "test code")
        ]

        //when
        guard let url = urlComponents?.url else {
            XCTFail("url is nil")
            return

        }
        let code = authHelper.code(from: url)

        //then
        XCTAssertEqual(code, "test code")
    }
}
