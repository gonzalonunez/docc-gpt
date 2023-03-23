let initialInstruction = #"""
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
enum Style {
  case road
  case touring
  case cruiser
  case hybrid
}
```

After:
```
/// Frame and construction style.
enum Style {
  /// A style for streets or trails.
  case road

  /// A style for long journeys.
  case touring

  /// A style for casual trips around town.
  case cruiser

  /// A style for general-purpose transportation.
  case hybrid
}
```

Please add Swift-flavored markdown comments to this code. Do not modify any of the code or any preexisting comments. Do not add any other types of comments, like file headers. Make sure that every single line of code is documented. Do not write new code. Only write new Swift-flavored markdown comments:
"""#
