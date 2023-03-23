import ArgumentParser
import Foundation

@main
struct DoccGPT: AsyncParsableCommand {

  mutating func run() async throws {
    let directoryURL = URL(fileURLWithPath: directory)
    let runner = DoccGPTRunner(apiKey: key)
    try await runner.run(in: directoryURL)
  }

  // MARK: Internal

  @Argument(help: "The folder whose contents you want to document")
  var directory: String

  @Option(name: .shortAndLong, help: "Your secret API key for OpenAI")
  var key: String
}

#if DEBUG
extension DoccGPT {

  init(directory: String, key: String) {
    self.directory = directory
    self.key = key
  }
}
#endif
