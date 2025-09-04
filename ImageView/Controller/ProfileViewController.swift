import Kingfisher
import SwiftKeychainWrapper
import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Variables
    var presenter: ProfileControllerPresenterProtocol?

    // MARK: - UI Components
    private lazy var userName: UILabel = {
        let userName = UILabel()
        userName.font = UIFont.systemFont(ofSize: 13)
        userName.textColor = .gray
        userName.translatesAutoresizingMaskIntoConstraints = false
        return userName
    }()
    private lazy var fullName: UILabel = {
        let fullName = UILabel()
        fullName.font = UIFont.boldSystemFont(ofSize: 23)
        fullName.textColor = .white
        fullName.translatesAutoresizingMaskIntoConstraints = false
        return fullName
    }()
    private lazy var userBio: UILabel = {
        let bio = UILabel()
        bio.font = UIFont.systemFont(ofSize: 13)
        bio.textColor = .white
        bio.translatesAutoresizingMaskIntoConstraints = false
        return bio
    }()
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(resource: .placeholder)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    private lazy var logOutButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "logout"
        button.setImage(UIImage(resource: .exit), for: .normal)
        button.addTarget(
            nil, action: #selector(logOutButtonPressed),
            for: .touchUpInside)
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button

    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        setupUI()
        presenter?.updateProfileData()
        presenter?.updateAvatarPhoto()
    }
    
    //MARK: - Methods
    @objc private func logOutButtonPressed(_ sender: Any) {
        presenter?.pressedLogout()
    }
    //MARK: - Setup UI
    private func setupUI() {
        self.view.backgroundColor = UIColor.ypBg
        [profileImageView, fullName, userName, userBio, logOutButton].forEach({
            view.addSubview($0)
        })

        NSLayoutConstraint.activate([
            //ProfileImageView
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            //fullNameLabel
            fullName.topAnchor.constraint(
                equalTo: profileImageView.bottomAnchor, constant: 8),
            fullName.leadingAnchor.constraint(
                equalTo: profileImageView.leadingAnchor),

            //userNameLabel
            userName.topAnchor.constraint(
                equalTo: fullName.bottomAnchor, constant: 8),
            userName.leadingAnchor.constraint(
                equalTo: profileImageView.leadingAnchor),

            //userBio
            userBio.topAnchor.constraint(
                equalTo: userName.bottomAnchor, constant: 8),
            userBio.leadingAnchor.constraint(
                equalTo: profileImageView.leadingAnchor),

            //logOutButton
            logOutButton.widthAnchor.constraint(equalToConstant: 45),
            logOutButton.heightAnchor.constraint(equalToConstant: 45),
            logOutButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logOutButton.centerYAnchor.constraint(
                equalTo: profileImageView.centerYAnchor),
        ])
    }
}

//MARK: - ProfileControllerProtocol
extension ProfileViewController: ProfileControllerProtocol {
    func dismiss() {
        dismiss(animated: true)
    }
    
    func showAlertForLogout(_ alert: AlertModel) {
        AlertPresenter.showAlert(alertData: alert, id: "logOut", delegate: self)
    }

    func updateAvatar(with url: URL) {
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .placeholder),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
                .forceRefresh,
            ])
    }

    func updateProfileData(with profile: ProfileDataModel) {
        fullName.text = profile.fullname
        userName.text = profile.username
        userBio.text = profile.bio
    }

}
//MARK: - AlertPresenterDelegate
extension ProfileViewController: AlertPresenterDelegate {
    func didPresentAlert(alert: UIAlertController?) {
        guard let alert else { return }
        present(alert, animated: true)
    }
}
