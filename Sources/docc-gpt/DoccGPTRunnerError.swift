import Foundation

/// Errors that can be thrown by the `DoccGPTRunner` class.
enum DoccGPTRunnerError: Error, CustomDebugStringConvertible {
  /// Thrown when the enumerator fails to be created.
  case failedToCreateEnumerator

  /// Thrown when the prefix is missing.
  case missingPrefix

  /// Thrown when the prompt is missing.
  case missingPrompt(String)

  /// Thrown when the responses are missing.
  case missingResponses

  /// Thrown when the OpenAI API returns an error.
  case openAI(String)

  /// A description of the error used for debugging.
  var debugDescription: String {
    switch self {
    case .failedToCreateEnumerator:
      return "Error: Failed to create a file enumerator."

    case .missingPrefix:
      return "Error: Response from API is missing the expected prefix."

    case .missingPrompt(let name):
      return "Error: Unable to load prompt with name \(name)"

    case .missingResponses:
      return "Error: Response from API returned zero completions."

    case .openAI(let message):
      return "Error: \(message)."
    }
  }
}
