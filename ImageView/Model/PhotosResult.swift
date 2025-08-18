import Foundation

struct UrlsResult: Codable {
    let full: String
    let regular: String
    let thumb: String
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let welcomeDescription: String
    let isLiked: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case width = "width"
        case height = "height"
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
        case urls = "urls"
    }
}

struct PhotosResult: Codable {
    let photos: [PhotoResult]
}
