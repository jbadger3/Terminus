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
    
    
    
}
