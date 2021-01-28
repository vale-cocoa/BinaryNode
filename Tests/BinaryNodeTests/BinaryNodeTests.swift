import XCTest
@testable import BinaryNode

final class BinaryNodeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BinaryNode().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
