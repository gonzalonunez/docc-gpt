import ArgumentParser
import Foundation
import Logging

/// A command-line tool for generating documentation from source code.
@main
struct DoccGPT: AsyncParsableCommand {

  /// Runs the command.
  mutating func run() async throws {
    let directoryURL = URL(fileURLWithPath: directory)
    let runner = DoccGPTRunner(
      apiKey: key,
      logger: logger,
      model: model,
      skipFiles: skipFiles)

    try await runner.run(in: directoryURL)
  }

  // MARK: Internal

  /// The logger used to emit log messages.
  lazy var logger: Logger = {
    var logger = Logger(label: "com.gonzalonunez.DoccGPT")
    logger.logLevel = logLevel
    return logger
  }()

  /// The folder whose contents you want to document.
  @Argument(help: "The folder whose contents you want to document")
  var directory: String

  /// The id of the OpenAI model to run.
  @Option(name: .shortAndLong, help: "The id of the OpenAI model to run")
  var model: Model = .init(argument: "gpt-3.5-turbo")!

  /// Your secret API key for OpenAI.
  @Option(name: .shortAndLong, help: "Your secret API key for OpenAI")
  var key: String

  /// The desired log level.
  @Option(name: .shortAndLong, help: "The desired log level")
  var logLevel: Logger.Level = .info

  /// Whether or not files that are too long to documented should be skipped.
  @Option(name: .long, help: "Whether or not files that are too long to documented should be skipped")
  var skipFiles: Bool = true
}

extension Logger.Level: ExpressibleByArgument {}

#if DEBUG
  extension DoccGPT {

    /// Initializes the command with the given parameters.
    init(directory: String, key: String) {
      self.directory = directory
      self.key = key
    }
  }
#endif
