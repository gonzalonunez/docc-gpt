import Foundation

/// A class for running the OpenAI GPT-3 API to document Swift files.
struct DoccGPTRunner {

  // MARK: Internal

  /// The API key used to authenticate with the OpenAI API.
  let apiKey: String

  /**
   Runs the OpenAI GPT-3 API to document Swift files in a directory.

   - Parameter directoryURL: The URL of the directory containing the Swift files to document.

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  func run(in directoryURL: URL) async throws {
    try await documentFiles(in: directoryURL)
  }

  // MARK: Private

  /// The base URL for the OpenAI API.
  private let baseURL = URL(string: "https://api.openai.com/v1/completions")!

  /// The `FileManager` used to access the filesystem.
  private let fileManager = FileManager.default

  /// A set of files to ignore when running the OpenAI API.
  private let ignoredFiles: Set<String> = [
    "Package.swift",
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
    defer {
      print("✓ Finished documenting \(fileURL.lastPathComponent)")
    }

    let fileContents = try String(contentsOf: fileURL)
    guard let promptURL = Bundle.module.url(forResource: "prompt", withExtension: "txt") else {
      throw DoccGPTRunnerError.missingPrompt
    }

    let initialPrompt = try String(contentsOf: promptURL)
    let prompt = initialPrompt + """
    
    Before:
    ```
    \(fileContents)
    ```

    After:
    ```

    """

    let parameters = CompletionParameters(
      model: "text-davinci-003",
      prompt: prompt,
      maxTokens: 2048,
      temperature: 0,
      topP: 1,
      n: 1,
      stream: false,
      stop: "```")

    var request = URLRequest(url: baseURL)
    request.httpBody = try jsonEncoder.encode(parameters)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = [
      "Authorization": "Bearer \(apiKey)",
      "Content-Type": "application/json"
    ]

    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try jsonDecoder.decode(CompletionResponse.self, from: data)

    guard let firstChoice = response.choices.first else {
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
  }

  /**
   Documents files in a directory using the OpenAI GPT-3 API.

   - Parameter directoryURL: The URL of the directory to document.

   - Throws: `DoccGPTRunnerError` if an error occurs.
   */
  private func documentFiles(in directoryURL: URL) async throws {
    guard let enumerator = fileManager.enumerator(atPath: directoryURL.path) else {
      throw DoccGPTRunnerError.failedToCreateEnumerator
    }

    while let file = enumerator.nextObject() as? String {
      guard file.hasSuffix(".swift") && !ignoredFiles.contains(file) else {
        continue
      }
      let fileURL = directoryURL.appendingPathComponent(file)
      try await documentFile(fileURL: fileURL)
    }
  }
}
