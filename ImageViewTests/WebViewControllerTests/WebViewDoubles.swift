import Foundation

@testable import ImageView

final class WebViewControllerSpy: WebViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var presenterCalledLoad: Bool = false

    func load(request: URLRequest) {
        presenterCalledLoad = true
    }

    func setProgressValue(_ newValue: Float) {}
    func setProgressHidden(_ isHidden: Bool) {}
}

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: WebViewControllerProtocol?
    var viewDidLoadCalled: Bool = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {}
    func code(from url: URL) -> String? {
        return nil
    }
}
