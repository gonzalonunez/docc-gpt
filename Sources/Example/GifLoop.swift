#if canImport(ImageIO)
  import Foundation
  import ImageIO

  /// An enumeration representing the looping behavior of a GIF.
  public enum GifLoop {

    /// The GIF should loop a specific number of times.
    case absolute(Int)

    /// The GIF should loop infinitely.
    public static var infinite = GifLoop.absolute(0)

    /// A dictionary representation of the loop behavior.
    public var dict: [String: Int] {
      switch self {
      case .absolute(let loopCount):
        return [
          kCGImagePropertyGIFLoopCount as String: loopCount
        ]
      }
    }
  }
#endif
