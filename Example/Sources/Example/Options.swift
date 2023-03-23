import Foundation

public struct MovieWritingOptions {
  var loopDuration: TimeInterval
  var duration: Int
  var shouldOverwrite: Bool
  
  public init(
    loopDuration: TimeInterval,
    duration: Int = 10,
    shouldOverwrite: Bool = true) 
  {
    self.loopDuration = loopDuration
    self.duration = duration
    self.shouldOverwrite = shouldOverwrite
  }
}

public struct GifWritingOptions {
  var duration: TimeInterval
  var scale: CGFloat
  var gifLoop: GifLoop
  var shouldOverwrite: Bool
  var qos: DispatchQoS.QoSClass
  var skipsFailedImages: Bool
  
  public init(
    duration: TimeInterval,
    scale: CGFloat = 1, 
    gifLoop: GifLoop = .infinite,
    shouldOverwrite: Bool = true, 
    qos: DispatchQoS.QoSClass = .default, 
    skipsFailedImages: Bool = true)
  {
    self.duration = duration
    self.scale = scale
    self.gifLoop = gifLoop
    self.shouldOverwrite = shouldOverwrite
    self.qos = qos
    self.skipsFailedImages = skipsFailedImages
  }
}
