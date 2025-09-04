import Foundation

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration?
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        let request = URLRequest(url: url)
        return request
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    func authURL() -> URL? {
        guard let configuration = self.configuration else { return nil }
        guard
            var urlComponents = URLComponents(
                string: configuration.authURLString)
        else {
            print("AuthHelper/ authURL - Unable init URLComponent")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope),
        ]
        guard let url = urlComponents.url else {
            assertionFailure("AuthHelper/ authURL - Unable to create URL from URLComponent")
            return nil
        }
        return url
    }

    init(configuration: AuthConfiguration?) {
        self.configuration = configuration
    }
}
