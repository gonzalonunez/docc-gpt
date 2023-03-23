import Foundation

/// Options for writing a GIF.
struct GifWritingOptions {

  /// The duration of each frame in the GIF.
  var duration: TimeInterval

  /// The scale of the GIF.
  var scale: CGFloat = 1

  /// The looping behavior of the GIF.
  var gifLoop: GifLoop = .infinite

  /// Whether to overwrite an existing file.
  var shouldOverwrite: Bool = true

  /// The quality of service for the writing operation.
  var qos: DispatchQoS.QoSClass = .default

  /// Whether to skip images that fail to encode.
  var skipsFailedImages: Bool = true
}
