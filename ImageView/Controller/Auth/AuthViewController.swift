import ProgressHUD
import UIKit

final class AuthViewController: UIViewController {

    //MARK: - Variables
    weak var delegate: AuthServiceDelegate?
    private var authService: OAuth2ServiceProtocol?
    private var alertPresenter: AlertPresenterProtocol?

    //MARK: - UI Components
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        let logoImage = UIImage(named: "auth_screen_logo")
        imageView.image = logoImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var enterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.layer.backgroundColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(logInButtonPressed),
            for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        authService = OAuth2Service.shared
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        setupUI()
    }

    //MARK: - Methods
    private func navigateToWebView() {
        let webViewVC = WebViewViewController()
        webViewVC.delegate = self
        webViewVC.modalPresentationStyle = .fullScreen
        show(webViewVC, sender: self)
    }
    
    @objc private func logInButtonPressed() {
        navigateToWebView()
    }

    //MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .ypBg
        navigationController?.navigationBar.backIndicatorImage = UIImage(
            named: "backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage =
            UIImage(named: "backward")
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack

        [enterButton, imageView].forEach({ view.addSubview(($0)) })
        NSLayoutConstraint.activate([
            //logInButton
            enterButton.heightAnchor.constraint(equalToConstant: 50),
            enterButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            enterButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            enterButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            
            //profileImageVIew
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

//MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController, didAuthenticateWithCode code: String
    ) {
        UIBlockingProgressHUD.show()

        fetchOAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
                vc.dismiss(animated: true)
            case .failure(let error):
                let alertdata = AlertModel(
                    title: "Что-то пошло не так",
                    text: "Не удалось войти в систему", buttonText: "Ок",
                    completion: { [weak self] in
                        guard let self else { return }
                        self.dismiss(animated: true)
                    }
                )
                alertPresenter?.showAlert(
                    alertData: alertdata, id: "authErrorAlert")
                print(
                    "AuthViewController/ fetchOauthToken: auth error - \(error.localizedDescription)"
                )
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController {
    private func fetchOAuthToken(
        _ code: String, completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let authService else { return }
        authService.fetchOAuthToken(code: code) { result in
            completion(result)
        }
    }
}

// MARK: - AlertPresenterDelegate
extension AuthViewController: AlertPresenterDelegate {
    func didPresentAlert(alert: UIAlertController?) {
        guard let alert else { return }
        present(alert, animated: true)
    }
}
