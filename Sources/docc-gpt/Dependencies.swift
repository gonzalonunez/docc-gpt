//

import Dependencies
import Foundation

private enum NetworkSessionKey: DependencyKey {
  static let liveValue: any NetworkSession = DefaultNetworkSession()
}

extension DependencyValues {

  var networkSession: NetworkSession {
    get { self[NetworkSessionKey.self] }
    set { self[NetworkSessionKey.self] = newValue }
  }
}
