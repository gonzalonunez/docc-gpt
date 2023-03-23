import Foundation

/// A `struct` representing parameters for the completion endpoint
struct CompletionParameters: Encodable {
  /// ID of the model to use.
  var model: String

  /// The prompt text to use as a starting point for the completion.
  var prompt: String

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
}

/// A `struct` representing the response from the completion endpoint
struct CompletionResponse: Decodable {
  /// An array of `Choice`s
  var choices: [Choice]

  /// A `struct` representing a single choice
  struct Choice: Decodable {
    /// The text of the choice
    var text: String
  }
}

