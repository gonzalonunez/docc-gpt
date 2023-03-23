import Foundation

/// Options for writing a movie.
struct MovieWritingOptions {

  /// The duration of the loop in seconds.
  var loopDuration: TimeInterval

  /// The duration of the movie in seconds. Defaults to 10.
  var duration: Int = 10

  /// Whether to overwrite existing files. Defaults to true.
  var shouldOverwrite: Bool = true
}
