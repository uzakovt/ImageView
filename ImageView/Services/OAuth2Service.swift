import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

protocol OAuth2ServiceProtocol {
    func fetchOAuthToken(
        code: String, completion: @escaping (Result<String, Error>) -> Void)
}

class OAuth2Service: OAuth2ServiceProtocol {
    static let shared = OAuth2Service()
    private var lastCode: String? = nil
    private var task: URLSessionTask? = nil
    private let urlSession = URLSession.shared

    private init() {}

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseURL = URL(string: "https://unsplash.com")
        let url = URL(
            string: "/oauth/token"
                + "?client_id=\(Constants.accessKey)"
                + "&&client_secret=\(Constants.secretKey)"
                + "&&redirect_uri=\(Constants.redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
            relativeTo: baseURL
        )
        guard let url else {
            print("OAuth2Service/makeOauthRequest: URL error - Unable to unwrap URL")
            assertionFailure("Unable to unwrap URL for OAUTHTOKEN")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

    func fetchOAuthToken(
        code: String, completion: @escaping (Result<String, Error>) -> Void
    ) {
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }

        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            print("OAuth2Service/makeOauthRequest: UrlSession request error - Invalid Request")
            assertionFailure("Unable to unwrap makeOAuthTokenRequest")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let storage = OAuth2TokenStorage()

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let decodedData):
                storage.token = decodedData.accessToken
                self?.lastCode = nil
                self?.task = nil
                completion(.success(decodedData.accessToken))
            case .failure(let error):
                print("OAuth2Service/fetchOauthToken: UrlSession Task error - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
        }
        self.task = task
        task.resume()
    }
}
