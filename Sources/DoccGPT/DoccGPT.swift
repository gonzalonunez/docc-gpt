import ArgumentParser
import Foundation

/// A command-line tool for generating documentation from source code.
@main
struct DoccGPT: AsyncParsableCommand {

  /// Runs the command.
  mutating func run() async throws {
    let directoryURL = URL(fileURLWithPath: directory)
    let runner = DoccGPTRunner(apiKey: key)
    try await runner.run(in: directoryURL)
  }

  // MARK: Internal

  /// The folder whose contents you want to document.
  @Argument(help: "The folder whose contents you want to document")
  var directory: String

  /// Your secret API key for OpenAI.
  @Option(name: .shortAndLong, help: "Your secret API key for OpenAI")
  var key: String
}

#if DEBUG
  extension DoccGPT {

    /// Initializes the command with the given parameters.
    init(directory: String, key: String) {
      self.directory = directory
      self.key = key
    }
  }
#endif
