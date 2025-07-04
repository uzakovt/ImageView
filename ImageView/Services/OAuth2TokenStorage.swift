import Foundation

final class OAuth2TokenStorage {
    private let storage: UserDefaults = .standard
    
    var token: String? {
        get {
            if let tokenString = storage.string(forKey: "token") {
                return tokenString
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                storage.set(newValue, forKey: "token")
            }
        }
    }
}
