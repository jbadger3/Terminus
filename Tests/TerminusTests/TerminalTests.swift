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
    
    func test_setInputMode_setsProperties() throws {
        let initialMode = sut.inputMode
        let initialEcho = sut.echo
        let expectedEcho = !initialEcho
        var expectedMode: InputMode = .raw
        switch initialMode {
        case .raw:
            expectedMode = .cbreak
        case .cbreak:
            expectedMode = .lineEditing
        case .lineEditing:
            expectedMode = .raw
        }
        sut.set(inputMode: expectedMode, echo: !initialEcho)
        
        let finalEcho = sut.echo
        let finalMode = sut.inputMode
        
        //turn echoing and cbreak back on
        sut.set(inputMode: .cbreak, echo: true)
        
        XCTAssertEqual(expectedMode, finalMode)
        XCTAssertEqual(expectedEcho, finalEcho)
    }
    
    func test_getKey_whenKeyPressed_returnsKey() throws {
        mockTerminalIO(terminal: sut)
        
        //simple standard key press
        var expectedKey = "t"
        write(expectedKey, toFileHandle: sut.standardInput)
        try! sut.standardInput.seek(toOffset: 0)
        var recievedKey = sut.getKey()
        XCTAssertEqual(recievedKey?.rawValue, expectedKey)
        
        //keypad up arrow
        expectedKey = CSI + "A"
        try! sut.standardInput.seek(toOffset: 0)
        write(expectedKey, toFileHandle: sut.standardInput)
        try! sut.standardInput.seek(toOffset: 0)
        recievedKey = sut.getKey()
        XCTAssertEqual(recievedKey?.rawValue, expectedKey)
        
        //multi codepoint character
        expectedKey = "👨‍❤️‍👨"
        try! sut.standardInput.seek(toOffset: 0)
        write(expectedKey, toFileHandle: sut.standardInput)
        try! sut.standardInput.seek(toOffset: 0)
        recievedKey = sut.getKey()
        XCTAssertEqual(recievedKey?.rawValue, expectedKey)
    }
    
    func test_read_whenBytesReadIsZero_returnsNil() {
        mockTerminalIO(terminal: sut) //dummy stdin file is empty
        let recievedOutput = sut.read(nBytes: 32)
        XCTAssertNil(recievedOutput)
    }
    
    func test_read_givenInpupPopulated_returnsString() {
        mockTerminalIO(terminal: sut)
        let expectedString = "Test"
        write(expectedString, toFileHandle: sut.standardInput)
        try! sut.standardInput.seek(toOffset: 0)
        
        let recievedString = sut.read(nBytes: 32)
        XCTAssertEqual(recievedString, expectedString)
    }
    
}
