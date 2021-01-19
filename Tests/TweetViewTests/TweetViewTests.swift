import XCTest
@testable import TweetView

final class TweetViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TweetView().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
