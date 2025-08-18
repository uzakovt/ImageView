import Kingfisher
import SwiftKeychainWrapper
import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Variables
    private var profileImageServiceObserver: NSObjectProtocol?
    private let authStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared

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
        let image = UIImage(named: "placeholder")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    private lazy var logOutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "exit"), for: .normal)
        button.addTarget(
            ProfileViewController.self, action: #selector(logOutButtonPressed),
            for: .touchUpInside)
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button

    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        setupUI()
        updateProfileData()

        // TODO: need to check if avatar is ready before adding observer
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification, object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateAvatar()
        }

        updateAvatar()
    }
    
    //MARK: - Methods
    @objc func logOutButtonPressed(_ sender: Any) {
        let removeToken: Bool = KeychainWrapper.standard.removeObject(
            forKey: "AuthToken")
        if removeToken == false {
            print("cannot logout")
        }
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        profileImageView.kf.indicatorType = .activity

        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholeder"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
                .forceRefresh,
            ])
    }

    private func updateProfileData() {
        guard let profile = profileService.profile else {
            assertionFailure("Cannot find profile data in profileService")
            return
        }
        fullName.text =
            profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        userName.text =
            profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        userBio.text =
            (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio
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
