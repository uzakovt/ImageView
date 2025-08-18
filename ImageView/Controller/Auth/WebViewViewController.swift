import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    //MARK: - Variables
    weak var delegate: WebViewViewControllerDelegate?
    private var webView = WKWebView()
    private var progressBar = UIProgressView()
    private var estimatedProgressObservation: NSKeyValueObservation?
    private let appearance = UINavigationBarAppearance()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        webView.navigationDelegate = self
        webViewLoad()
        loadAuthView()
        progressBarView()
        setNavigationItemAppearance()

        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new],
            changeHandler: { [weak self] _, _ in
                guard let self else { return }
                self.updateProgress()
            }
        )
    }
    
    //MARK: - Methods
    private func updateProgress() {
        progressBar.progress = Float(webView.estimatedProgress)
        progressBar.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }

    private func webViewLoad() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.backgroundColor = .white

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
    }
    
    private func setNavigationItemAppearance() {
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.compactAppearance = appearance
    }

    private func progressBarView() {
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)
        progressBar.progressViewStyle = .bar
        progressBar.tintColor = .ypBg
        progressBar.setProgress(0.1, animated: true)

        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressBar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    private func loadAuthView() {
        guard
            var urlComponents = URLComponents(
                string: WebViewConstants.unsplashAuthorizeURLString)
        else {
            print("Unable init URLComponent")
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope),
        ]
        guard let url = urlComponents.url else {
            assertionFailure("Unable to create URL from URLComponent")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
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
        if let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString =
        "https://unsplash.com/oauth/authorize"
}
