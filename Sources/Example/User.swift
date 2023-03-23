import Foundation

/// A `struct` representing a user.
struct User: Codable {

  /// The user's email address.
  let email: String

  /// The user's password.
  let password: String

  /// The user's first name.
  let firstName: String

  /// The user's last name.
  let lastName: String
}
