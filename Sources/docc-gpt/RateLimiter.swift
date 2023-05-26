//

import Dependencies
import Foundation
import Logging

actor RateLimiter {

  private(set) var tokenCount = 0
  private(set) var requestCount = 0

  let tokenLimit = 90_000
  let requestLimit = 3_500

  func addRequest(_ request: Request) {
    tokenCount += request.parameters.messages.totalTokens
    assert(tokenCount <= tokenLimit)

    requestCount += 1
    assert(requestCount <= requestLimit)
  }

  func removeRequest(_ request: Request) {
    tokenCount -= request.parameters.messages.totalTokens
    requestCount -= 1
  }
}
