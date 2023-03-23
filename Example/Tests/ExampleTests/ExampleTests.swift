import XCTest

@testable import Example

final class ExampleTests: XCTestCase {

	func testExample() throws {
		XCTAssertEqual(Example().text, "Hello, World!")
	}
}
