import Foundation
import UIKit

final class ProfileControllerPresenter: ProfileControllerPresenterProtocol {
    private let logOutService = ProfileLogOutService.shared
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    weak var view: ProfileControllerProtocol?

    init() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification, object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateAvatarPhoto()
        }
    }
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func pressedLogout() {
        let yesAction = UIAlertAction(
            title: "Да", style: .default,
            handler: {
                [weak self] _ in
                guard let self else { return }
                self.logOutService.logOut()
            })
        yesAction.accessibilityIdentifier = "yes"
        let cancelAction = UIAlertAction(
            title: "Нет", style: .default,
            handler: {
                [weak self] _ in
                guard let self else { return }
                self.view?.dismiss()
            })
        cancelAction.accessibilityIdentifier = "cancel"
        let alert = AlertModel(
            title: "Пока, пока!", text: "Уверены, что хотите выйти?",
            actions: [
                yesAction, cancelAction,
            ])
        view?.showAlertForLogout(alert)
    }

    func updateAvatarPhoto() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(with: url)
    }

    func updateProfileData() {
        guard let profile = profileService.profile else {
            assertionFailure("Cannot find profile data in profileService")
            return
        }
        let fullName =
            profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        let username =
            profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        let bio =
            ((profile.bio?.isEmpty ?? true)
                ? "Профиль не заполнен"
                : profile.bio) ?? "Профиль не заполнен"

        let profileData = ProfileDataModel(
            fullname: fullName, username: username, bio: bio)
        view?.updateProfileData(with: profileData)
    }
}
