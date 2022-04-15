import XCTest
@testable import Terminus

final class TerminalTests: XCTestCase {
    var sut: Terminal!
    
    override class func setUp() {
        sut = Terminal.shared
    }
    
    override class func tearDown() {
        sut.quit()
        sut = nil
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
    }
}
