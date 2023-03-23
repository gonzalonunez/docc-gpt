import Foundation

struct GifWritingOptions {
  var duration: TimeInterval
  var scale: CGFloat = 1
  var gifLoop: GifLoop = .infinite
  var shouldOverwrite: Bool = true
  var qos: DispatchQoS.QoSClass = .default
  var skipsFailedImages: Bool = true
}
