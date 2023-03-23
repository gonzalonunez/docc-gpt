let instruction = #"""
Add Swift-flavored markdown comments. Here are some examples of well-documented code:

Example 1:
/**
 Creates a personalized greeting for a recipient.

 - Parameter recipient: The person being greeted.

 - Throws: `MyError.invalidRecipient`
           if `recipient` is "Derek"
           (he knows what he did).

 - Returns: A new string saying hello to `recipient`.
 */
func greeting(to recipient: String) throws -> String {
  guard recipient != "Derek" else {
    throw MyError.invalidRecipient
  }
  return "Greetings, \(recipient)!"
}

Example 2:
/// A `struct` representing a user
struct User: Codable {
  /// The user's email
  let email: String

  /// The user's password
  let password: String

  /// The user's first name
  let firstName: String

  /// The user's last name
  let lastName: String
}
"""#
