import Foundation

protocol AuthServiceDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
