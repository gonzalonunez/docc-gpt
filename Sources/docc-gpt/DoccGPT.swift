import ArgumentParser
import Foundation

/// A command-line tool for generating documentation from source code.
@main
struct DoccGPT: AsyncParsableCommand {

  /// Runs the command.
  mutating func run() async throws {
    let directoryURL = URL(fileURLWithPath: directory)
    let runner = DoccGPTRunner(apiKey: key, contextLength: contextLength, model: model, skipFiles: skipFiles)
    try await runner.run(in: directoryURL)
  }

  // MARK: Internal

  /// The folder whose contents you want to document.
  @Argument(help: "The folder whose contents you want to document")
  var directory: String

  /// The OpenAI model to run
  @Option(name: .shortAndLong, help: "The OpenAI model to run")
  var model: String = "text-davinci-003"

  /// The context length corresponding to the OpenAI model chosen
  @Option(name: .long, help: "The context length corresponding to the OpenAI model chosen.")
  var contextLength: Int = 4096

  /// Your secret API key for OpenAI.
  @Option(name: .shortAndLong, help: "Your secret API key for OpenAI")
  var key: String

  /// Whether or not files unlikely to documented should be skipped.
  @Option(name: .long, help: "Whether or not files unlikely to documented should be skipped")
  var skipFiles: Bool = true
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
