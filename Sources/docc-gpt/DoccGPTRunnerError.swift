import Foundation

/// Errors that can be thrown by the `DoccGPTRunner` class.
enum DoccGPTRunnerError: Error, CustomDebugStringConvertible {
  /// Thrown when the enumerator fails to be created.
  case failedToCreateEnumerator

  /// Thrown when the prompt is missing.
  case missingPrompt

  /// Thrown when the responses are missing.
  case missingResponses

  /// Thrown when the OpenAI API returns an error
  case openAI(String)

  var debugDescription: String {
    switch self {
    case .failedToCreateEnumerator:
      return "Error: Failed to create a file enumerator."

    case .missingResponses:
      return "Error: Response from API returned zero completions."

    case .missingPrompt:
      return "Error: Unable to load prompt file."

    case .openAI(let message):
      return "Error: \(message)."
    }
  }
}
