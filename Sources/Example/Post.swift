import Foundation

/// A `struct` representing a post.
public struct Post: Codable {

  /// The unique identifier for the post.
  public var id: String

  /// The date the post was created.
  public var createdAt: Date

  /// The date the post was last updated.
  public var updatedAt: Date

  /**
   Returns a URL for the post.

   - Parameter baseURL: The base URL to use for the post.

   - Returns: A URL for the post.
   */
  public func url(baseURL: String) -> URL? {
    return URL(string: "\(baseURL)/posts/\(id)")
  }
}
