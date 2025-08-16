import UIKit

final class SplashScreenController: UIViewController {
    
    //MARK: Variables
    
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = storage.token {
            fetchProfile(token)
        } else {
            navigateToAuth()
        }
    }
    
    
    //MARK: Methods
    private func navigateToAuth() {
        let authVC = AuthViewController()
        authVC.delegate = self
        let authNavController = UINavigationController(rootViewController: authVC)
        authNavController.modalPresentationStyle = .fullScreen
        
        present(authNavController, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        

        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    private func setUpUI() {
        view.backgroundColor = .ypBg
        let image = UIImage(named: "LaunchScreenIcon")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 75),
        ])
    }
}

//MARK: AuthService Delegate

extension SplashScreenController: AuthServiceDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = storage.token else {
            assertionFailure("Cannot load token in SplashScreen")
            return
        }
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                profileImageService.fetchProfileImageURL(profile.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                print(error)
                // TODO: show error for profile loading
                break
            }
        }
    }
}
