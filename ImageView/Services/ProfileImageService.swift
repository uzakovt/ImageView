import Foundation

enum ProfileImageServiceError: Error {
    case invalidProfileImageRequest
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(
        "ProfileImageProviderDidChange")
    private var task: URLSessionTask? = nil
    private(set) var avatarURL: String?
    private let oauthStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared

    private init() {}

    func fetchProfileImageURL(
        _ username: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        self.task?.cancel()

        guard let token = oauthStorage.token else {
            print("ProfileImageSerice/fetchProfile: Token error - Unable to unwrap Token from storage")
            assertionFailure("Cant unwrap token for fetchProfileImageURL")
            completion(
                .failure(
                    NSError(
                        domain: "ProfileImageService", code: 401,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Authorization token missing"
                        ]
                    )
                )
            )
            return
        }

        guard
            let request = makeProfileImageRequest(
                token: token, username: username)
        else {
            print("ProfileImageService/makeProfileImageRequest: UrlSession request error - Invalid Request")
            assertionFailure("Cannot unwrap profileImageRequest")
            completion(
                .failure(ProfileImageServiceError.invalidProfileImageRequest))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let decodedData):
                self.avatarURL = decodedData.profileImage.large
                completion(.success(decodedData.profileImage.large))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": decodedData.profileImage.small]
                )
            case .failure(let error):
                print("ProfileImageSerice/fetchProfileImage: UrlSession Task error - \(error.localizedDescription)")
                assertionFailure(error.localizedDescription)
                completion(.failure(error))
                return
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }

    private func makeProfileImageRequest(token: String, username: String)
        -> URLRequest?
    {
        let url = URL(
            string: "/users/\(username)", relativeTo: Constants.defaultBaseURL)

        guard let url else {
            print("ProfileImageSerice/makeProfileImageRequest: URL error - Unable to unwrap URL")
            assertionFailure(
                "Cant unwrap url or token for fetchProfileImageURL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
