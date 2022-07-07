import XCTest
@testable import Terminus

final class TerminalTests: XCTestCase {
    var sut: Terminal!
    
    override func setUp() {
        sut = Terminal.shared
    }
    
    override func tearDown() {
        sut.quit()
        sut = nil
    }
    
    
    func test_getKey_whenKeyPressed_returnsKey() throws {
        mockTerminalIO(terminal: sut)
        
        //simple standard key press
        var expectedKey = "t"
        write(expectedKey, toFileHandle: sut.standardInput)
        try! sut.standardInput.seek(toOffset: 0)
        var recievedKey = try sut.getKey()
        XCTAssertEqual(recievedKey.rawValue, expectedKey)
        
        //keypad up arrow
        expectedKey = CSI + "A"
        try! sut.standardInput.seek(toOffset: 0)
        write(expectedKey, toFileHandle: sut.standardInput)
        try! sut.standardInput.seek(toOffset: 0)
        recievedKey = try sut.getKey()
        XCTAssertEqual(recievedKey.rawValue, expectedKey)
        
        //multi codepoint character
        expectedKey = "👨‍❤️‍👨"
        try! sut.standardInput.seek(toOffset: 0)
        write(expectedKey, toFileHandle: sut.standardInput)
        try! sut.standardInput.seek(toOffset: 0)
        recievedKey = try sut.getKey()
        XCTAssertEqual(recievedKey.rawValue, expectedKey)
    }
    
    func test_read_whenBytesReadIsZero_returnsNil() {
        mockTerminalIO(terminal: sut) //dummy stdin file is empty
        let recievedOutput = try! sut.read(nBytes: 32)
        XCTAssertNil(recievedOutput)
    }
    
    func test_read_givenInpupPopulated_returnsString() {
        mockTerminalIO(terminal: sut)
        let expectedString = "Test"
        write(expectedString, toFileHandle: sut.standardInput)
        try! sut.standardInput.seek(toOffset: 0)
        
        let recievedString = try! sut.read(nBytes: 32)
        XCTAssertEqual(recievedString, expectedString)
    }
    
}
