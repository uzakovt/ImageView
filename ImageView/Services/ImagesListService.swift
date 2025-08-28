import Foundation

final class ImagesListService {
    var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var task: URLSessionTask? = nil
    private let urlSession = URLSession.shared
    let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    private let tokenStorage = OAuth2TokenStorage()

    private init() {}

    private func makePhotosPageRequest(page: Int) -> URLRequest? {
        let token = tokenStorage.token
        guard let token else { return nil }
        let baseURL = URL(string: "https://api.unsplash.com")
        let url = URL(
            string: "/photos" + "?page=\(page)" + "&per_page=10",
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
    
    func cleanImageListData() {
        self.photos = []
        self.task = nil
    }

    func fetchPhotosNextPage() {
        if task != nil {
            print("ImageListService: UrlSession task already ongoing")
        }

        let nextPage = lastLoadedPage + 1
        guard let request = makePhotosPageRequest(page: nextPage) else {
            print(
                "ImagesListService: makePhotosPageRequest - cannot unwrap the request"
            )
            assertionFailure("Unable to unwrap the request")
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let decodedData):
                decodedData.forEach({
                    self.photos.append(Photo.convert(from: $0))
                })
                NotificationCenter.default.post(
                    name: self.didChangeNotification,
                    object: self,
                    userInfo: ["photos": "updated"]
                )
                lastLoadedPage += 1
            case .failure(let error):
                print(error.localizedDescription)
                print("ImageListService: fetchPhotosNextPage - task failed: \(String(describing: error))")
            }
        }

        self.task = task
        task.resume()
    }

    func changeLike(
        photoId: String, isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let token = tokenStorage.token else { return }
        guard
            let url = URL(
                string: "/photos" + "/\(photoId)" + "/like",
                relativeTo: Constants.defaultBaseURL)
        else {
            print("ImageListService/ changeLikeState - cannot unwrap the url")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            if let error {
                completion(.failure(error))
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300
            {
                completion(
                    .failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            DispatchQueue.main.async {
                self.updatePhoto(id: photoId)
                completion(.success(()))
            }
        }
        task.resume()
    }

    private func updatePhoto(id: String) {
        if let index = self.photos.firstIndex(where: { $0.id == id }) {
            let photo = self.photos[index]
            let newPhoto = Photo(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                welcomeDescription: photo.welcomeDescription,
                thumbImageURL: photo.thumbImageURL,
                largeImageURL: photo.largeImageURL,
                isLiked: !photo.isLiked
            )
                self.photos[index] = newPhoto
        }
    }
}
