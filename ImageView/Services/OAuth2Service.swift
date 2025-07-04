import Foundation

protocol OAuth2ServiceProtocol {
    func fetchOAuthToken(
        code: String, completion: @escaping (Result<String, Error>) -> Void)
}

class OAuth2Service: OAuth2ServiceProtocol {
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
            print("Unable to unwrap URL for OAUTHTOKEN")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

    func fetchOAuthToken(
        code: String, completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            assertionFailure("Unable to unwrap makeOAuthTokenRequest")
            return
        }
        let storage = OAuth2TokenStorage()

        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(
                        OAuthTokenResponseBody.self, from: data)
                    storage.token = response.accessToken
                    completion(.success(response.accessToken))
                } catch {
                    assertionFailure("Unable to decode response for Access Token")
                    completion(.failure(error))
                    return
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
