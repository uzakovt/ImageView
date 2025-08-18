import Foundation

final class ImagesListService {
    private var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask? = nil
    private let urlSession = URLSession.shared
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()

    private init() {}

    private func makePhotosPageRequest(page: Int) -> URLRequest? {
        let tokenStorage = OAuth2TokenStorage()
        let token = tokenStorage.token
        guard let token else { return nil }
        let baseURL = URL(string: "https://api.unsplash.com")
        let url = URL(
            string: "/photos" + "?page=\(page)",
            relativeTo: baseURL
        )
        guard let url else {
            print(
                "ImageListService/makePhotosPageRequest: URL error - Unable to unwrap URL"
            )
            assertionFailure("Unable to unwrap URL for ImageListService")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func fetchPhotosNextPage() {
        if task != nil {
            print("ImageListService: UrlSession task already ongoing")
        }

        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotosPageRequest(page: nextPage) else {
            print(
                "ImagesListService: makePhotosPageRequest - cannot unwrap the request"
            )
            assertionFailure("Unable to unwrap the request")
            return
        }
        
        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<PhotosResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let decodedData):
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["photos": "updated"]
                )
                print("Photos loaded, notification sended")
            case .failure(let error):
                print(error.localizedDescription)
                print("ImageListService: fetchPhotosNextPage - task failed")

            }

        }
        self.task = task
        task.resume()
    }
}
