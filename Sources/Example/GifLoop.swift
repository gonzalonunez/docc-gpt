import Foundation
import ImageIO

/// Represents the loop count of a GIF.
enum GifLoop {
  /// The GIF will loop a specific number of times.
  case absolute(Int)

  /// The GIF will loop infinitely.
  static var infinite = GifLoop.absolute(0)

  /// A dictionary representation of the loop count.
  public var dict: [String: Int] {
    switch self {
    case .absolute(let loopCount):
      return [
        kCGImagePropertyGIFLoopCount as String: loopCount
      ]
    }
  }
}
