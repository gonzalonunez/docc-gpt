import Foundation

/// A `struct` representing a post.
struct Post: Codable {

  /// The post's unique identifier.
  var id: String

  /// The date the post was created.
  var createdAt: Date

  /// The date the post was last updated.
  var updatedAt: Date

  /**
   Creates a URL for the post.

   - Parameter baseURL: The base URL to use for the post.

   - Returns: A `URL` for the post, constructed from `baseURL` and `id`.
   */
  func url(baseURL: String) -> URL? {
    return URL(string: "\(baseURL)/posts/\(id)")
  }
}
