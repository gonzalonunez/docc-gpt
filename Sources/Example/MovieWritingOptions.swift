import Foundation

/// Options for writing a movie file.
public struct MovieWritingOptions {

  /// The duration of one loop of the movie.
  public var loopDuration: TimeInterval

  /// The total duration of the movie.
  public var duration: Int = 10

  /// Whether to overwrite an existing file with the same name.
  public var shouldOverwrite: Bool = true
}
