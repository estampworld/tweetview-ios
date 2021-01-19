import XCTest
@testable import TweetView

final class TweetViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        XCTAssertNotNil(TweetView(id: "736726372966502400"))
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
