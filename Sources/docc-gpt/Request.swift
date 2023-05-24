//

import Foundation

struct Request {

  init(
    fewShotMessages: [CompletionParameters.Message],
    fileContents: String,
    fileURL: URL,
    model: Model) throws
  {
    self.fewShotMessages = fewShotMessages
    self.fileContents = fileContents
    self.fileURL = fileURL
    self.model = model
  }

  var fewShotMessages: [CompletionParameters.Message]
  var fileContents: String
  var fileURL: URL
  var model: Model

  var parameters: CompletionParameters {
    let allMessages =
      fewShotMessages + [
        .init(
          role: "user",
          content: """
            <BEGIN>
            \(fileContents)
            <END>
            """)
      ]

    return CompletionParameters(
      model: model.id,
      messages: allMessages,
      temperature: 0,
      stop: "<END>")
  }
}
