import ArgumentParser
import Foundation

/// A `struct` representing parameters for the completion endpoint
struct CompletionParameters: Encodable {
  /// ID of the model to use.
  var model: String

  /// The prompt text to use as a starting point for the completion.
  var messages: [Message]

  /// What sampling temperature to use, between 0 and 2
  var temperature: Double

  /// A string to stop the generation when it is encountered
  var stop: String

  /// A `struct` representing a message sent to the completion endpoint
  struct Message: Codable {
    /// The role of the message
    var role: String

    /// The content of the message
    var content: String
  }
}

/// A `struct` representing the response from the completion endpoint
struct CompletionResponse: Decodable {
  /// An array of `Choice`s
  var choices: [Choice]

  /// A `struct` representing a single choice
  struct Choice: Decodable {
    /// The message of the choice
    var message: CompletionParameters.Message
  }
}

#if DEBUG
  extension CompletionResponse: Encodable {}
  extension CompletionResponse.Choice: Encodable {}
#endif

/// A `struct` representing an error response from the completion endpoint
struct ErrorResponse: Decodable {
  /// The error returned by the response
  var error: ErrorInfo

  /// A `struct` representing information about an error
  struct ErrorInfo: Decodable {
    /// The message of the error
    var message: String
  }
}

#if DEBUG
  extension ErrorResponse: Encodable {}
  extension ErrorResponse.ErrorInfo: Encodable {}
#endif

struct Model: ExpressibleByArgument {
  let id: String
  let contextLength: Int

  init?(argument: String) {
    self.id = argument
    switch id {
    case "gpt-4", "gpt-4-0314":
      contextLength = 8192
    case "gpt-4-32k", "gpt-4-32k-0314":
      contextLength = 32_768
    case "gpt-3.5-turbo", "gpt-3.5-turbo-0301":
      contextLength = 4096
    default:
      return nil
    }
  }
}

extension Array where Element == CompletionParameters.Message {

  /// The total tokens taken up by an array of messages
  var totalTokens: Int {
    reduce(0, { $0 + $1.totalTokens })
  }
}

extension CompletionParameters.Message {

  /// The total tokens taken up by a single message
  var totalTokens: Int {
    content.approximateTokens + 6
  }
}

extension String {

  /// The approximate number of tokens taken up by the receiver
  ///
  /// From OpenAI: https://platform.openai.com/docs/introduction/key-concepts
  /// "As a rough rule of thumb, 1 token is approximately 4 characters or 0.75 words for English text."
  var approximateTokens: Int {
    let divided = Double(count) / 4
    return Int(divided.rounded(.up))
  }
}
