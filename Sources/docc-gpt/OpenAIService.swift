//

import Dependencies
import Foundation
import Logging

final class OpenAIService {

  init(
    apiKey: String,
    logger: Logger
  ) {
    self.apiKey = apiKey
    self.logger = logger
  }

  func canAddRequest(_ request: Request) async -> Bool {
    let newTokenCount = await rateLimiter.tokenCount + request.parameters.messages.totalTokens
    let newRequestCount = await rateLimiter.requestCount + 1
    return newTokenCount <= rateLimiter.tokenLimit && newRequestCount <= rateLimiter.requestLimit
  }

  /// Performs a `Request` and returns its response.
  func performRequest(_ request: Request) async throws -> String {
    while await !canAddRequest(request) {
      try await Task.sleep(nanoseconds: 1 * 1_000_000)
    }
    
    await rateLimiter.addRequest(request)
    logger.debug("Performing request for \(request.fileURL.lastPathComponent)...")

    var urlRequest = URLRequest(url: apiURL)
    urlRequest.httpBody = try jsonEncoder.encode(request.parameters)
    urlRequest.httpMethod = "POST"
    urlRequest.allHTTPHeaderFields = [
      "Authorization": "Bearer \(apiKey)",
      "Content-Type": "application/json",
    ]

    let (data, urlResponse) = try await networkSession.data(for: urlRequest)

    logger.debug("Received response for \(request.fileURL.lastPathComponent)...")
    await rateLimiter.removeRequest(request)

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

  private let rateLimiter = RateLimiter()
}
