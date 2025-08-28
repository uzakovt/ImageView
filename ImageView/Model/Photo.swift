import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool

    static func convert(from photoResult: PhotoResult) -> Photo {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime] 
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return Photo(
            id: photoResult.id,
            size: CGSize(width: photoResult.width, height: photoResult.height),
            createdAt: isoFormatter.date(from: photoResult.createdAt),
            welcomeDescription: photoResult.welcomeDescription,
            thumbImageURL: photoResult.urls.thumb,
            largeImageURL: photoResult.urls.full, isLiked: photoResult.isLiked)
    }
}
