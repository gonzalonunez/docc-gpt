import Foundation

/// A `struct` representing a user.
public struct User: Codable {

  /// The user's email address.
  public let email: String

  /// The user's password.
  public let password: String

  /// The user's first name.
  public let firstName: String

  /// The user's last name.
  public let lastName: String
}
