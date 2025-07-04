import UIKit

final class AuthViewController: UIViewController {

    private var imageView = UIImageView()
    private var enterButton = UIButton()
    private var authService: OAuth2ServiceProtocol?
    weak var delegate: AuthServiceDelegate?

    override func viewDidLoad() {
        authService = OAuth2Service()
        view.backgroundColor = .ypBg
        logoImageView()
        logInButton()
        configureBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            guard let destination = segue.destination as? WebViewViewController
            else {
                assertionFailure("Unable to prepare for segue (showWebView)")
                return
            }
            destination.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(
            named: "backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage =
            UIImage(named: "backward")
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }

    private func logInButton() {
        enterButton = UIButton.systemButton(
            with: UIImage(), target: self, action: #selector(logInButtonPressed)
        )
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(enterButton)
        enterButton.setTitle("Log In", for: .normal)
        enterButton.setTitleColor(.ypBlack, for: .normal)
        enterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        enterButton.layer.cornerRadius = 16
        enterButton.layer.backgroundColor = UIColor.white.cgColor

        NSLayoutConstraint.activate([
            enterButton.heightAnchor.constraint(equalToConstant: 50),
            enterButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            enterButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            enterButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
        ])
    }
    private func logoImageView() {
        let logoImage = UIImage(named: "auth_screen_logo")!
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        imageView.image = logoImage
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @IBAction private func logInButtonPressed() {
        performSegue(withIdentifier: "showWebView", sender: self)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController, didAuthenticateWithCode code: String
    ) {
        vc.dismiss(animated: true)
        guard let authService else { return }
        print("Recieved the code")

        authService.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                assertionFailure(error.localizedDescription)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }

}
