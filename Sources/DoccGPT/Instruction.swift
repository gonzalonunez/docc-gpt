let initialInstruction = #"""
Please add Swift-flavored markdown comments to this code. Do not modify any of the code or any preexisting comments. Do not add any other types of comments, like file headers. Make sure that every single line of code is documented. Do not write new code. Only write new Swift-flavored markdown comments:

Before:
```
import Foundation

struct User: Codable {
  let email: String
  let password: String
  let firstName: String
  let lastName: String
}
```

After:
```
import Foundation

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
```

Please add Swift-flavored markdown comments to this code. Do not modify any of the code or any preexisting comments. Do not add any other types of comments, like file headers. Make sure that every single line of code is documented. Do not write new code. Only write new Swift-flavored markdown comments:

Before:
```
import Foundation

struct Post: Codable {
  var id: String
  var createdAt: Date
  var updatedAt: Date

  func url(baseURL: String) -> URL? {
    return URL(string: "\(baseURL)/posts/\(id)")
  }
}
```

After:
```
import Foundation

/// A `struct` representing a Post
struct Post: Codable {

  /// The post's id
  var id: String

  /// The date the post was created
  var createdAt: Date

  /// The date the post was last updated at
  var updatedAt: Date

  /**
  Returns the `URL` of the post given a `baseURL`.

  - Parameter baseURL: the base `URL` of the post
  - Returns: the `URL` of the post relative to the `baseURL`
  */
  func url(baseURL: String) -> URL? {
    return URL(string: "\(baseURL)/posts/\(id)")
  }
}
```

Please add Swift-flavored markdown comments to this code. Do not modify any of the code or any preexisting comments. Do not add any other types of comments, like file headers. Make sure that every single line of code is documented. Do not write new code. Only write new Swift-flavored markdown comments:

Before:
```
func greeting(to recipient: String) throws -> String {
  guard recipient != "Derek" else {
    throw MyError.invalidRecipient
  }
  return "Greetings, \(recipient)!"
}
```

After:
```
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
```

Please add Swift-flavored markdown comments to this code. Do not modify any of the code or any preexisting comments. Do not add any other types of comments, like file headers. Make sure that every single line of code is documented. Do not write new code. Only write new Swift-flavored markdown comments:

"""#
