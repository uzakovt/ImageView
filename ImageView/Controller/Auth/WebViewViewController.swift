import UIKit
import WebKit

final class WebViewViewController: UIViewController, WebViewControllerProtocol {

    //MARK: - Variables
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    private var estimatedProgressObservation: NSKeyValueObservation?
    private let appearance = UINavigationBarAppearance()

    //MARK: - UI Components
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.accessibilityIdentifier = "UnsplashWebView"
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.backgroundColor = .white
        return webView
    }()
    private lazy var progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressViewStyle = .bar
        progressBar.tintColor = .ypBg
        return progressBar
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        setupUI()
        presenter?.viewDidLoad()

        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new],
            changeHandler: { [weak self] _, _ in
                guard let self else { return }
                self.presenter?.didUpdateProgressValue(
                    self.webView.estimatedProgress)
            }
        )
    }

    //MARK: - Methods
    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressBar.setProgress(newValue, animated: true)
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressBar.isHidden = isHidden
    }

    //MARK: - Setup UI
    private func setupUI() {
        [webView, progressBar].forEach({
            view.addSubview($0)
        })

        NSLayoutConstraint.activate([
            //WebView
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),

            //ProgressBar
            progressBar.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressBar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        //Navigation Appearance
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.compactAppearance = appearance
    }
}

//MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        } else {
            return nil
        }
    }
}
