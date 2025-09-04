import Foundation

protocol ProfileControllerProtocol: AnyObject {
    func showAlertForLogout(_ alert: AlertModel)
    func updateAvatar(with url: URL)
    func updateProfileData(with profile: ProfileDataModel)
    func dismiss()
}

protocol ProfileControllerPresenterProtocol {
    func pressedLogout()
    func updateAvatarPhoto()
    func updateProfileData()
}
