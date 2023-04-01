import Foundation

/// Options for writing a GIF file.
public struct GifWritingOptions {

  /// The duration of the GIF.
  public var duration: TimeInterval

  /// The scale of the GIF.
  public var scale: CGFloat = 1

  /// The loop behavior of the GIF.
  public var gifLoop: GifLoop = .infinite

  /// Whether to overwrite an existing file with the same name.
  public var shouldOverwrite: Bool = true

  /// The quality of service class to use for the write operation.
  public var qos: DispatchQoS.QoSClass = .default

  /// Whether to skip failed images when writing the GIF.
  public var skipsFailedImages: Bool = true
}
