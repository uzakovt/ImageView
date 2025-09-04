import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return isoFormatter
    }()
    
    static func convert(from photoResult: PhotoResult) -> Photo {
        
        return Photo(
            id: photoResult.id,
            size: CGSize(width: photoResult.width, height: photoResult.height),
            createdAt: dateFormatter.date(from: photoResult.createdAt),
            welcomeDescription: photoResult.welcomeDescription,
            thumbImageURL: photoResult.urls.thumb,
            largeImageURL: photoResult.urls.full, isLiked: photoResult.isLiked)
    }
}
