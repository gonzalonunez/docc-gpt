//

import Dependencies
import Foundation
import Logging

actor OpenAIService {

  init(
    apiKey: String,
    logger: Logger
  ) {
    self.apiKey = apiKey
    self.logger = logger
  }

  /// Performs a `Request` and returns its response.
  ///
  /// Prevents getting rate-limited by the OpenAI API in a thread-safe manner.
  func perform(request: Request) async throws -> String {
    defer {
      removeRequest(request)
    }
    await addRequest(request)
    return try await performRequest(request)
  }

  // MARK: Private

  /// The `NetworkSession` used to make network requests.
  @Dependency(\.networkSession) private var networkSession

  /// The API key used to authenticate with the OpenAI API.
  private let apiKey: String

  /// The URL for the OpenAI API.
  private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!

  /// The logger used to emit log messages.
  private let logger: Logger

  /// The expected prefix for messages from the OpenAI API
  private let expectedPrefix = "<BEGIN>\n"

  /// The `JSONEncoder` used to encode parameters for the OpenAI API.
  private let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }()

  /// The `JSONDecoder` used to decode responses from the OpenAI API.
  private let jsonDecoder: JSONDecoder = {
    let encoder = JSONDecoder()
    encoder.keyDecodingStrategy = .convertFromSnakeCase
    return encoder
  }()

  private var tokenCount = 0
  private let tokenLimit = 90_000

  private var requestCount = 0
  private let requestLimit = 3_500

  private func yield() async {
    await withCheckedContinuation { continuation in
      while tokenCount >= tokenLimit || requestCount >= requestLimit {
        continue
      }
      continuation.resume()
    }
  }

  private func addRequest(_ request: Request) async {
    await yield()
    tokenCount += request.parameters.messages.totalTokens
    requestCount += 1
    logger.debug("Token count: \(tokenCount)")
  }

  private func removeRequest(_ request: Request) {
    tokenCount -= request.parameters.messages.totalTokens
    requestCount -= 1
    logger.debug("Token count: \(tokenCount)")
  }

  private func performRequest(_ request: Request) async throws -> String {
    logger.debug("Performing request for \(request.fileURL.lastPathComponent)...")

    var urlRequest = URLRequest(url: apiURL)
    urlRequest.httpBody = try jsonEncoder.encode(request.parameters)
    urlRequest.httpMethod = "POST"
    urlRequest.allHTTPHeaderFields = [
      "Authorization": "Bearer \(apiKey)",
      "Content-Type": "application/json",
    ]

    let (data, urlResponse) = try await networkSession.data(for: urlRequest)
    if let httpResponse = urlResponse as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
      let errorResponse = try jsonDecoder.decode(ErrorResponse.self, from: data)
      throw DoccGPTRunnerError.openAI(errorResponse.error.message)
    }

    let completionResponse = try jsonDecoder.decode(CompletionResponse.self, from: data)

    guard let firstChoice = completionResponse.choices.first else {
      throw DoccGPTRunnerError.missingResponses
    }

    guard firstChoice.message.content.hasPrefix(expectedPrefix) else {
      throw DoccGPTRunnerError.missingPrefix
    }

    var newContent = firstChoice.message.content
    newContent.removeFirst(expectedPrefix.count)
    return newContent
  }
}
