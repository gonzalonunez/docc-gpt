//

import Foundation
import Logging

protocol NetworkSession {
  func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

final class DefaultNetworkSession: NetworkSession {

  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    try await URLSession.shared.data(for: request)
  }
}

#if DEBUG
final class MockNetworkSession: NetworkSession {
  var data: Data = {
    let response = CompletionResponse(choices: [
      .init(message: .init(
        role: "assistant",
        content: "<BEGIN>\nHello, world!"))
    ])
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return try! encoder.encode(response)
  }()

  var urlResponse: HTTPURLResponse = .init(
    url: URL(string: "https://www.google.com")!,
    statusCode: 200,
    httpVersion: "1",
    headerFields: [:])!

  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    (data, urlResponse)
  }
}
#endif
