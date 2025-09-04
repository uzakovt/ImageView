import Foundation

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let welcomeDescription: String?
    let isLiked: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
        case urls
    }
}

struct LikedPhotoResult: Codable {
    let photo: PhotoResult?
}

