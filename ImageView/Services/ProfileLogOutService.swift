import Foundation
import Kingfisher
import SwiftKeychainWrapper
import WebKit

final class ProfileLogOutService {
    static let shared = ProfileLogOutService()
    private init() {}
    func logOut() {
        cleanCookies()
        cleanToken()
        cleanProfile()
        cleanImageList()
        switchToAuthScreen()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            records.forEach({ record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            })
        }
    }
    private func cleanToken() {
        let removeToken: Bool = KeychainWrapper.standard.removeObject(
            forKey: "AuthToken")
        if !removeToken {
            print("Cannot clear the token")
        }
    }

    private func cleanProfile() {
        ProfileService.shared.cleanProfileData()
        ProfileImageService.shared.cleanProfileImageData()
    }

    private func cleanImageList() {
        ImagesListService.shared.cleanImageListData()
        KingfisherManager.shared.cache.clearCache()
    }
    
    private func switchToAuthScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("LogOutService/ siwtchToAuthScreen - unable to unwrap window")
            return
        }
        
        let splashVC = SplashScreenController()
        window.rootViewController = splashVC
    }
}
