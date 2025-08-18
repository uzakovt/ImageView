import Foundation

enum ProfileServiceError: Error {
    case invalidProfileRequest
}

final class ProfileService {
    static let shared = ProfileService()
    private var task: URLSessionTask? = nil
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?

    private init() {}

    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<ProfileResult, Error>) -> Void
    ) {
        self.task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            print("ProfileService/makeProfileRequest: UrlSession request error - Invalid Request")
            completion(.failure(ProfileServiceError.invalidProfileRequest))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let decodedData):
                let profile = Profile(
                    username: decodedData.username,
                    name: decodedData.name,
                    loginName: decodedData.loginName,
                    bio: decodedData.bio
                )
                self.profile = profile
                completion(.success(decodedData))
            case .failure(let error):
                print("ProfileSerice/fetchProfile: UrlSession Task error - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        let url = URL(string: "/me", relativeTo: Constants.defaultBaseURL)

        guard let url else {
            print("ProfileSerice/makeProfileRequest: URL error - Unable to unwrap URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
