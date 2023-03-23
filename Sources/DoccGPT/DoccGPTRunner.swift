import Foundation

struct DoccGPTRunner {

  // MARK: Internal

  let apiKey: String

  func run(in directoryURL: URL) async throws {
    try await documentFiles(in: directoryURL)
  }

  // MARK: Private

  private let baseURL = URL(string: "https://api.openai.com/v1/edits")!
  private let fileManager = FileManager.default

  private let ignoredFiles: Set<String> = [
    "Package.swift",
  ]

  private let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }()

  private let jsonDecoder: JSONDecoder = {
    let encoder = JSONDecoder()
    encoder.keyDecodingStrategy = .convertFromSnakeCase
    return encoder
  }()

  private func documentFile(fileURL: URL) async throws {
    let fileContents = try String(contentsOf: fileURL)
    let parameters = EditParameters(
      model: "code-davinci-edit-001",
      input: fileContents,
      instruction: instruction,
      temperature: 0,
      topP: 1)

    var request = URLRequest(url: baseURL)
    request.httpBody = try jsonEncoder.encode(parameters)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = [
      "Authorization": "Bearer \(apiKey)",
      "Content-Type": "application/json"
    ]

    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try jsonDecoder.decode(EditResponse.self, from: data)

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
