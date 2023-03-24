import Foundation

/// Options for writing a movie.
public struct MovieWritingOptions {

  /// The duration of the loop in seconds.
  public var loopDuration: TimeInterval

  /// The duration of the movie in seconds. Defaults to 10.
  public var duration: Int = 10

  /// Whether to overwrite existing files. Defaults to true.
  public var shouldOverwrite: Bool = true
}
