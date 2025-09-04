import UIKit

protocol AlertPresenterProtocol {
    static func showAlert(alertData: AlertModel?, id: String, delegate: AlertPresenterDelegate)
}

protocol AlertPresenterDelegate: AnyObject {
    func didPresentAlert(alert: UIAlertController?)
}

final class AlertPresenter: AlertPresenterProtocol {
    static func showAlert(alertData: AlertModel?, id: String, delegate: AlertPresenterDelegate) {
        guard let alertData else {
            delegate.didPresentAlert(alert: nil)
            return
        }

        let alert = UIAlertController(
            title: alertData.title, message: alertData.text,
            preferredStyle: .alert)
       
        alertData.actions.forEach({
            alert.addAction($0)
        })
        alert.view.accessibilityIdentifier = id
        delegate.didPresentAlert(alert: alert)
    }
}
