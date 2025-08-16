import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let storage: KeychainWrapper = .standard
    private let tokenKey: String = "AuthToken"
    
    var token: String? {
        get {
            return storage.string(forKey: tokenKey)
        }
        set {
            if let newValue {
                storage.set(newValue, forKey: tokenKey)
            } else {
                storage.removeObject(forKey: tokenKey)
            }
        }
    }
}
