import Foundation
import Logging

/// A class for running the OpenAI GPT API to document Swift files.
struct DoccGPTRunner {

  init(
    apiKey: String,
    logger: Logger,
    model: Model,
    skipFiles: Bool
  ) {
    self.apiService = OpenAIService(apiKey: apiKey, logger: logger)
    self.logger = logger
    self.model = model
    self.skipFiles = skipFiles
  }

  // MARK: Internal

  /// The OpenAI model to use with the OpenAI API.
  let model: Model

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

  /// The service used to communicate with the OpenAI API.
  private let apiService: OpenAIService

  /// The `FileManager` used to access the filesystem.
  private let fileManager = FileManager.default

  /// The logger used to emit log messages.
  private let logger: Logger

  /// A set of files to ignore when running the OpenAI API.
  private let ignoredFiles: Set<String> = [
    "Package.swift"
  ]

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
          let fileContents = try String(contentsOf: fileURL)
          let request = try Request(
            fewShotMessages: messages,
            fileContents: fileContents,
            fileURL: fileURL,
            model: model)

          try await documentFile(with: request)
        }
      }

      try await group.waitForAll()
    }
  }

  /**
   Documents a single Swift file using the OpenAI GPT API.

   - Parameter fileURL: The URL of the file to document.
   - Parameter messages: The messages to use when documenting the file.

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  private func documentFile(with request: Request) async throws {
    logger.info("᠅ Documenting \(request.fileURL.lastPathComponent)...")

    let commentThreshold = 1.1
    let remainingTokens = model.contextLength - request.parameters.messages.totalTokens
    if remainingTokens <= request.fileContents.approximateTokens && skipFiles {
      logger.warning(
        """

        ⚠︎ Skipping \(request.fileURL.lastPathComponent) due to number of tokens in prompt \
        (\(request.parameters.messages.totalTokens)).

        \tThe total tokens taken up by the prompt plus those needed for an appropriate response cannot
        \texceed the model's context length. The prompt for this file is using \(request.parameters.messages.totalTokens)
        \ttokens, which leaves \(remainingTokens) tokens. Your file is \(request.fileContents.approximateTokens)
        \ttokens.

        """)

      return

    } else if remainingTokens < Int(Double(request.fileContents.approximateTokens) * commentThreshold) {
      logger.warning(
        """

        ⚠︎ Warning: Close to token limit for \(request.fileURL.lastPathComponent). Please ensure that the entire file
        was given back to you by DoccGPT.

        """)
    }

    let newContent = try await apiService.perform(request: request)

    let replacementDirectory = try fileManager.url(
      for: .itemReplacementDirectory,
      in: .userDomainMask,
      appropriateFor: request.fileURL,
      create: true)

    let replacementURL = replacementDirectory.appendingPathComponent(request.fileURL.lastPathComponent)

    try newContent.write(
      to: replacementURL,
      atomically: true,
      encoding: .utf8)

    _ = try fileManager.replaceItemAt(request.fileURL, withItemAt: replacementURL)

    logger.info("✓ Finished documenting \(request.fileURL.lastPathComponent)")
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
