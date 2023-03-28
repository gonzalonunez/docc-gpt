import Foundation

/// A class for running the OpenAI GPT-3 API to document Swift files.
struct DoccGPTRunner {

  // MARK: Internal

  /// The API key used to authenticate with the OpenAI API.
  let apiKey: String

  /// The context length corresponding to the OpenAI model chosen.
  let contextLength: Int

  /// The OpenAI model to use with the OpenAI API.
  let model: String

  /// Whether or not files unlikely to documented should be skipped.
  let skipFiles: Bool

  /**
   Runs the OpenAI GPT-3 API to document Swift files in a directory.

   - Parameter directoryURL: The URL of the directory containing the Swift files to document.

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  func run(in directoryURL: URL) async throws {
    try await documentFiles(in: directoryURL)
  }

  // MARK: Private

  /// The URL for the OpenAI API.
  private let apiURL = URL(string: "https://api.openai.com/v1/completions")!

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
   Documents a single Swift file using the OpenAI GPT-3 API.

   - Parameter fileURL: The URL of the file to document.

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  private func documentFile(fileURL: URL) async throws {
    print("᠅ Documenting \(fileURL.lastPathComponent)...")

    let fileContents = try String(contentsOf: fileURL)
    guard let promptURL = Bundle.module.url(forResource: "prompt", withExtension: "txt") else {
      throw DoccGPTRunnerError.missingPrompt
    }

    let initialPrompt = try String(contentsOf: promptURL)
    let prompt =
      initialPrompt + """

      Before:
      ```
      \(fileContents)
      ```

      After:
      ```

      """

    let maxTokens = contextLength - prompt.count
    if maxTokens <= 0 && skipFiles {
      print(
        """

        ⚠︎ Skipping \(fileURL.lastPathComponent) due to number of tokens in prompt (\(prompt.count)). This can \
        happen for a number of reasons:

        \t1. Make sure that the --context-length argument (\(contextLength)) is appropriate for the model that
        \tyou've chosen to use. Most models have a context length of 2048 tokens (except for the newest models,
        \twhich support 4096).

        \t2. The token count of your prompt plus max_tokens cannot exceed the model's context length. The
        \tprompt for this file is using \(prompt.count) tokens, which leaves \(maxTokens) tokens
        \tremaining.

        """)
      return
    }

    let parameters = CompletionParameters(
      model: model,
      prompt: prompt,
      maxTokens: maxTokens,
      temperature: 0,
      topP: 1,
      n: 1,
      stream: false,
      stop: "```")

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

    let replacementDirectory = try fileManager.url(
      for: .itemReplacementDirectory,
      in: .userDomainMask,
      appropriateFor: fileURL,
      create: true)

    let replacementURL = replacementDirectory.appendingPathComponent(fileURL.lastPathComponent)

    try firstChoice.text.write(
      to: replacementURL,
      atomically: true,
      encoding: .utf8)

    _ = try fileManager.replaceItemAt(fileURL, withItemAt: replacementURL)

    print("✓ Finished documenting \(fileURL.lastPathComponent)")
  }

  /**
   Documents files in a directory using the OpenAI GPT-3 API.

   Sadly, I had to write this last comment myself because I can't get around the token limit!

   - Parameter directoryURL: The URL of the directory to document.

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  private func documentFiles(in directoryURL: URL) async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
      guard let enumerator = fileManager.enumerator(atPath: directoryURL.path) else {
        throw DoccGPTRunnerError.failedToCreateEnumerator
      }

      while let file = enumerator.nextObject() as? String {
        guard file.hasSuffix(".swift") && !ignoredFiles.contains(file) else {
          continue
        }
        group.addTask {
          let fileURL = directoryURL.appendingPathComponent(file)
          try await documentFile(fileURL: fileURL)
        }
      }

      try await group.waitForAll()
    }
  }
}
