import Foundation
import ImageIO

enum GifLoop {
  case absolute(Int)
  static var infinite = GifLoop.absolute(0) // 0 = infinite loop for kCGImagePropertyGIFLoopCount

  public var dict: [String: Int] {
    switch self {
    case .absolute(let loopCount):
      return [
        kCGImagePropertyGIFLoopCount as String: loopCount,
      ]
    }
  }
}
