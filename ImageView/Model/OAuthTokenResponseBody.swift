import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case scope = "scope"
    }
}
