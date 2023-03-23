struct Post: Codable {
  var id: String
  var createdAt: Date
  var updatedAt: Date
  var url: URL
  
  func url(baseURL: String) -> URL? {
    return URL(string: "\(baseURL)/posts/\(id)")
  }
}