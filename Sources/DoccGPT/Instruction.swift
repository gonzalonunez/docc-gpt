let instruction = """
Add Swift-flavored markdown comments.

Here is an example. For this code:

struct User: Codable {
  let email: String
  let password: String
  let firstName: String
  let lastName: String
}

You should do this:

/// A `struct` representing a user
struct User: Codable {
  /// The user's email
  let email: String

  /// The user's password
  let password: String

  /// The user's first name
  let firstName: String

  /// The user's last name
  let lastName: String
}

Here is a more complete example. For complicated code, explain the code in more detail:

extension EffectPublisher {

  /// Creates an effect that executes some work in the real world that doesn't need to feed data
  /// back into the store. If an error is thrown, the effect will complete and the error will be
  /// ignored.
  ///
  /// This effect is handy for executing some asynchronous work that your feature doesn't need to
  /// react to. One such example is analytics:
  ///
  /// ```swift
  /// case .buttonTapped:
  ///   return .fireAndForget {
  ///     try self.analytics.track("Button Tapped")
  ///   }
  /// ```
  ///
  /// The closure provided to ``fireAndForget(priority:_:)`` is allowed to throw, and any error
  /// thrown will be ignored.
  ///
  /// - Parameters:
  ///   - priority: Priority of the underlying task. If `nil`, the priority will come from
  ///     `Task.currentPriority`.
  ///   - work: A closure encapsulating some work to execute in the real world.
  /// - Returns: An effect.
  public static func fireAndForget(
    priority: TaskPriority? = nil,
    _ work: @escaping @Sendable () async throws -> Void
  ) -> Self {
    Self.run(priority: priority) { _ in try? await work() }
  }
}
"""
