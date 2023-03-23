import Foundation

struct MovieWritingOptions {
  var loopDuration: TimeInterval
  var duration: Int = 10
  var shouldOverwrite: Bool = true
}

struct GifWritingOptions {
  var duration: TimeInterval
  var scale: CGFloat = 1
  var gifLoop: GifLoop = .infinite
  var shouldOverwrite: Bool = true
  var qos: DispatchQoS.QoSClass = .default
  var skipsFailedImages: Bool = true
}
