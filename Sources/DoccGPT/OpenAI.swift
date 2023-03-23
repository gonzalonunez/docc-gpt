import Foundation

struct EditParameters: Encodable {
  var model: String
  var input: String
  var instruction: String
  var temperature: Int
  var topP: Int
}

struct EditResponse: Decodable {
  var choices: [EditResponse.Choice]

  struct Choice: Decodable {
    var text: String
  }
}
