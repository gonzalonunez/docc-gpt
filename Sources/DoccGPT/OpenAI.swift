import Foundation

struct CompletionParameters: Encodable {
  var model: String
  var prompt: String
  var maxTokens: Int
  var temperature: Double
  var topP: Double
  var n: Double
  var stream: Bool
  var logprobs: Int?
  var stop: String
}

struct CompletionResponse: Decodable {
  var choices: [Choice]

  struct Choice: Decodable {
    var text: String
  }
}
