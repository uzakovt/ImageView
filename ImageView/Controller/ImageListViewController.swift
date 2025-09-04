import UIKit

 class ImageListViewController: UIViewController {

    //MARK: - Variables
    var presenter: ImageListPresenterProtocol?
    var helper: ImageListHelperProcol?

    //MARK: - UI Components
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBg
        tableView.allowsSelection = true
        tableView.register(
            ImageListCell.self,
            forCellReuseIdentifier: ImageListCell.reuseIdentifier)
        return tableView
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageListHelper = ImageListHelper()
        let ilPresenter = ImageListPresenter()
        ilPresenter.helper = imageListHelper
        self.helper = imageListHelper
        self.presenter = ilPresenter
        ilPresenter.view = self
        imageListHelper.view = self
        tableView.delegate = imageListHelper
        tableView.dataSource = imageListHelper
        presenter?.checkIfListIsEmpty()
        NotificationCenter.default.addObserver(
            forName: ImagesListService.shared.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            presenter?.updateTableView()
        }
        setupUI()
    }

    //MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .ypBg
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypBg
        tableView.separatorStyle = .none

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor),
        ])
    }
}

//MARK: - ImageListControllerProtocol
extension ImageListViewController: ImageListControllerProtocol {
    func getTableViewBounds() -> CGRect {
        return tableView.bounds
    }
    
    func updateTableViewAnimated(indexPath: [IndexPath]) {
        DispatchQueue.main.async {
            self.tableView.performBatchUpdates({
                self.tableView.insertRows(at: indexPath, with: .automatic)
            })
        }
    }

    func didSelectRowFor(selectedPhoto: Photo) {
        let singleImageVC = SingleImageController()
        singleImageVC.image = selectedPhoto
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
    }

    func getIndexPath(for cell: ImageListCell) -> IndexPath? {
        return tableView.indexPath(for: cell)
    }

    func showChangeLikeErrorAlert() {
        let alert = AlertModel(
            title: "Что-то пошло не так(",
            text: "Не удалось войти в систему",
            actions: [
                UIAlertAction(
                    title: "ОК", style: .default,
                    handler: {
                        [weak self] _ in
                        guard let self else { return }
                        self.dismiss(animated: true)
                    }
                )
            ]
        )
        AlertPresenter.showAlert(
            alertData: alert,
            id: "changeLike",
            delegate: self
        )
    }
}

//MARK: - AlertPresenterDelegate
extension ImageListViewController: AlertPresenterDelegate {
    func didPresentAlert(alert: UIAlertController?) {
        guard let alert else { return }
        present(alert, animated: true)
    }
}
