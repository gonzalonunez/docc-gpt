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

Before:
```
struct MovieWritingOptions {
  var loopDuration: TimeInterval
  var duration: Int = 10
  var shouldOverwrite: Bool = true
}

struct GifWritingOptions {
  var duration: TimeInterval
  var scale: CGFloat = 1
  var gifLoop: GifLoop = .infinite
  var shouldOverwrite: Bool = true
  var qos: DispatchQoS.QoSClass = .default
  var skipsFailedImages: Bool = true
}
```

After:
```
/// A `struct` representing options for writing a movie
struct MovieWritingOptions {
  /// The duration of the loop
  var loopDuration: TimeInterval

  /// The overall duration of the movie
  var duration: Int = 10

  /// Whether or not the movie file should be overwritten if it already exists
  var shouldOverwrite: Bool = true
}

/// A `struct` representing options for writing a gif
struct GifWritingOptions {

  /// The duration of the gif
  var duration: TimeInterval

  /// The scaling to apply to the gif
  var scale: CGFloat = 1

  /// The `GifLoop` of the underlying gif
  var gifLoop: GifLoop = .infinite

  /// Whether or not the gif file should be overwritten if it already exists
  var shouldOverwrite: Bool = true

  /// The quality of service for the writing queue
  var qos: DispatchQoS.QoSClass = .default

  /// Whether or not images that fail to be written to the file should be skipped
  var skipsFailedImages: Bool = true
}
```

Please add Swift-flavored markdown comments to this code. Do not modify any of the code or any preexisting comments. Do not add any other types of comments, like file headers. Make sure that every single line of code is documented. Do not write new code. Only write new Swift-flavored markdown comments:
"""#
