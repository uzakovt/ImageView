import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {

    //MARK: - Variables
    weak var view: WebViewControllerProtocol?
    var authHelper: AuthHelperProtocol?

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    //MARK: - Methods
    func viewDidLoad() {
        guard let request = authHelper?.authRequest() else {
            print(
                "WebviewPresenter/ viewDidLoad - Cannot get request for webview"
            )
            //TODO: - show alert for error
            return
        }
        didUpdateProgressValue(0)
        view?.load(request: request)
    }
    
    func code(from url: URL) -> String? {
        authHelper?.code(from: url)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
