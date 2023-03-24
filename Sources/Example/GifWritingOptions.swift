import Foundation

/// Options for writing a GIF.
public struct GifWritingOptions {

  /// The duration of each frame in the GIF.
  public var duration: TimeInterval

  /// The scale of the GIF.
  public var scale: CGFloat = 1

  /// The looping behavior of the GIF.
  public var gifLoop: GifLoop = .infinite

  /// Whether to overwrite an existing file.
  public var shouldOverwrite: Bool = true

  /// The quality of service for the writing operation.
  public var qos: DispatchQoS.QoSClass = .default

  /// Whether to skip images that fail to encode.
  public var skipsFailedImages: Bool = true
}
