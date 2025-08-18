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
        let action = UIAlertAction(title: alertData.buttonText, style: .default)
        { _ in
            DispatchQueue.main.async {
                alertData.completion()
            }
        }
        alert.addAction(action)
        alert.view.accessibilityIdentifier = id
        delegate.didPresentAlert(alert: alert)
    }
}
