import Foundation

struct Post: Codable {
  var id: String
  var createdAt: Date
  var updatedAt: Date

  func url(baseURL: String) -> URL? {
    return URL(string: "\(baseURL)/posts/\(id)")
  }
}
