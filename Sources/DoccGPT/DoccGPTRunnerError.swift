import Foundation

/// Errors that can be thrown by the `DoccGPTRunner` class.
enum DoccGPTRunnerError: Error {
  /// Thrown when the enumerator fails to be created.
  case failedToCreateEnumerator

  /// Thrown when the prompt is missing.
  case missingPrompt

  /// Thrown when the responses are missing.
  case missingResponses
}
