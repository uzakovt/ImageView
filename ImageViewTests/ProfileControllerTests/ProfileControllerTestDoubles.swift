import Foundation
import XCTest
@testable import ImageView

final class ProfileControllerSpy: ProfileControllerProtocol {
    var updateAvatarCalled: Bool = false
    var showAlertCalled: Bool = false
    var exp: XCTestExpectation?
    func showAlertForLogout(_ alert: ImageView.AlertModel) {
        showAlertCalled = true
    }
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
        exp?.fulfill()
    }
    
    func updateProfileData(with profile: ImageView.ProfileDataModel) {
        
    }
    
    func dismiss() {}
}

final class ProfilePresenterSpy: ProfileControllerPresenterProtocol {
    var updateAvatarCalled: Bool = false
    var updateProfileDataCalled: Bool = false
    func pressedLogout() {
        
    }
    
    func updateAvatarPhoto() {
        updateAvatarCalled = true
    }
    
    func updateProfileData() {
        updateProfileDataCalled = true
    }
}
