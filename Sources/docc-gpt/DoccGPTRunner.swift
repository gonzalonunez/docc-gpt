import Foundation
import Logging

/// A class for running the OpenAI GPT API to document Swift files.
struct DoccGPTRunner {

  // MARK: Internal

  /// The API key used to authenticate with the OpenAI API.
  let apiKey: String

  /// The context length corresponding to the OpenAI model chosen.
  let contextLength: Int

  /// The logger used to emit log messages.
  let logger: Logger

  /// The OpenAI model to use with the OpenAI API.
  let model: String

  /// Whether or not files that are too long to documented should be skipped.
  let skipFiles: Bool

  /**
   Runs the OpenAI GPT API to document Swift files in a directory.

   - Parameter directoryURL: The URL of the directory containing the Swift files to document.

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  func run(in directoryURL: URL) async throws {
    try await documentFiles(in: directoryURL)
  }

  // MARK: Private

  /// The URL for the OpenAI API.
  private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!

  /// The expected prefix for messages from the OpenAI API
  private let expectedPrefix = "<BEGIN>\n"

  /// The `FileManager` used to access the filesystem.
  private let fileManager = FileManager.default

  /// A set of files to ignore when running the OpenAI API.
  private let ignoredFiles: Set<String> = [
    "Package.swift"
  ]

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

  /**
   Documents a single Swift file using the OpenAI GPT API.

   - Parameter fileURL: The URL of the file to document.
   - Parameter messages: The messages to use when documenting the file.

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  private func documentFile(fileURL: URL, with messages: [CompletionParameters.Message]) async throws {
    logger.info("᠅ Documenting \(fileURL.lastPathComponent)...")

    let commentThreshold = 1.1
    let fileContents = try String(contentsOf: fileURL)
    let allMessages =
      messages + [
        .init(
          role: "user",
          content: """
            <BEGIN>
            \(fileContents)
            <END>
            """)
      ]

    let remainingTokens = contextLength - allMessages.totalTokens
    if remainingTokens <= fileContents.approximateTokens && skipFiles {
      logger.warning(
        """

        ⚠︎ Skipping \(fileURL.lastPathComponent) due to number of tokens in prompt \
        (\(allMessages.totalTokens)). This can happen for a number of reasons:

        \t1. Make sure that the --context-length argument (\(contextLength)) is appropriate for the model that
        \tyou've chosen to use. Most models have a context length of 2048 tokens (except for the newest models,
        \twhich support 4096).

        \t2. The total tokens taken up by the prompt plus those needed for an appropriate response cannot
        \texceed the model's context length. The prompt for this file is using \(allMessages.totalTokens)
        \ttokens, which leaves \(remainingTokens) tokens. Your file is \(fileContents.approximateTokens)
        \ttokens.

        """)
      return
    } else if remainingTokens < Int(Double(fileContents.approximateTokens) * commentThreshold) {
      logger.warning(
        """

        ⚠︎ Warning: Close to token limit for \(fileURL.lastPathComponent). Please ensure that the entire file
        was given back to you by DoccGPT.

        """)
    }

    let parameters = CompletionParameters(
      model: model,
      messages: allMessages,
      temperature: 0,
      topP: 1,
      n: 1,
      stream: false,
      stop: "<END>")

    var request = URLRequest(url: apiURL)
    request.httpBody = try jsonEncoder.encode(parameters)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = [
      "Authorization": "Bearer \(apiKey)",
      "Content-Type": "application/json",
    ]

    let (data, urlResponse) = try await URLSession.shared.data(for: request)
    if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode != 200 {
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

    let replacementDirectory = try fileManager.url(
      for: .itemReplacementDirectory,
      in: .userDomainMask,
      appropriateFor: fileURL,
      create: true)

    let replacementURL = replacementDirectory.appendingPathComponent(fileURL.lastPathComponent)

    try newContent.write(
      to: replacementURL,
      atomically: true,
      encoding: .utf8)

    _ = try fileManager.replaceItemAt(fileURL, withItemAt: replacementURL)

    logger.info("✓ Finished documenting \(fileURL.lastPathComponent)")
  }

  /**
   Documents files in a directory using the OpenAI GPT API.

   Sadly, I had to write this comment myself because I can't get around the token limit!

   - Parameter directoryURL: The URL of the directory to document.

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  private func documentFiles(in directoryURL: URL) async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
      guard let enumerator = fileManager.enumerator(atPath: directoryURL.path) else {
        throw DoccGPTRunnerError.failedToCreateEnumerator
      }

      let messages = try loadPromptMessages()

      while let file = enumerator.nextObject() as? String {
        guard file.hasSuffix(".swift") && !ignoredFiles.contains(file) else {
          continue
        }
        group.addTask {
          let fileURL = directoryURL.appendingPathComponent(file)
          try await documentFile(fileURL: fileURL, with: messages)
        }
      }

      try await group.waitForAll()
    }
  }

  /**
   Loads prompt messages to use with the OpenAI GPT API.

   Sadly, I had to write this comment myself because I can't get around the token limit!

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  private func loadPromptMessages() throws -> [CompletionParameters.Message] {
    return [
      try loadPromptMessage(name: "system", role: "system"),
      try loadPromptMessage(name: "ex1-user", role: "user"),
      try loadPromptMessage(name: "ex1-assistant", role: "assistant"),
      try loadPromptMessage(name: "ex2-user", role: "user"),
      try loadPromptMessage(name: "ex2-assistant", role: "assistant"),
      try loadPromptMessage(name: "ex3-user", role: "user"),
      try loadPromptMessage(name: "ex3-assistant", role: "assistant"),
    ]
  }

  /**
   Loads a single prompt message to use with the OpenAI GPT API.

   Sadly, I had to write this comment myself because I can't get around the token limit!

   - Parameter name: The name of the message file in the bundle.
   - Parameter role: The role to assign to the loaded message.

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  private func loadPromptMessage(name: String, role: String) throws -> CompletionParameters.Message {
    guard let url = Bundle.module.url(forResource: name, withExtension: "txt") else {
      throw DoccGPTRunnerError.missingPrompt(name)
    }
    return .init(
      role: role,
      content: try .init(contentsOf: url))
  }
}
