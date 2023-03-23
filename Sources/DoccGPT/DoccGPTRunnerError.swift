import Foundation

enum DoccGPTRunnerError: Error {
  case failedToCreateEnumerator
  case missingPrompt
  case missingResponses
}
