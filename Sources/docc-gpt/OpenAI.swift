import Foundation

/// A `struct` representing parameters for the completion endpoint
struct CompletionParameters: Encodable {
  /// ID of the model to use.
  var model: String

  /// The prompt text to use as a starting point for the completion.
  var messages: [Message]

  /// The maximum number of tokens to generate.
  var maxTokens: Int

  /// What sampling temperature to use, between 0 and 2
  var temperature: Double

  /// An alternative to sampling with temperature, called nucleus sampling
  var topP: Double

  /// The number of partial hypotheses to return
  var n: Double

  /// Whether to stream the results as they are generated
  var stream: Bool

  /// Whether to return the log probabilities of the generated tokens
  var logprobs: Int?

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

extension Array where Element == CompletionParameters.Message {

  /// The total tokens taken up by an array of messages
  var totalTokens: Int {
    reduce(0, { $0 + $1.totalTokens })
  }
}

extension CompletionParameters.Message {

  /// The total tokens taken up by a single message
  var totalTokens: Int {
    content.count + 6
  }
}
