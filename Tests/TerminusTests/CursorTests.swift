//  Created by Jonathan Badger on 3/25/22.
//

import Foundation
import XCTest

@testable import Terminus
class CursorTests: XCTestCase {
    var terminal: Terminal!
    var sut: Cursor!
    
    override func setUpWithError() throws {
        sut = Cursor()
        terminal = Terminal.shared
    }
    
    override func tearDownWithError() throws {
        sut = nil
        terminal = nil
    }

    func test_location_whenLocationSetToZeroZero_returnsLocationZeroZero() {
        mockTerminalIO(terminal: terminal)
        let responseString = CSI + "0;0R"
        write(responseString, toFileHandle: terminal.standardInput)
        //try! terminal.standardInput.seek(toOffset: 0)
        let expectedLocation = Location(x: 0, y: 0)
        let cursorLocation = sut.location

        XCTAssertEqual(cursorLocation, expectedLocation)
    }
    
    func test_moveToLocation_movesToSpecifiedLocation() {
        //first save cursor
        var saveCS = Esc + "7"
        write(STDOUT_FILENO, &saveCS, saveCS.lengthOfBytes(using: .utf8))
        let expectedLocation = Location(x: 25, y: 30)
        
        sut.move(toLocation: expectedLocation)
        let finalLocation = sut.location
        
        XCTAssertEqual(expectedLocation, finalLocation)
        var restoreCS = Esc + "8"
        write(STDOUT_FILENO, &restoreCS, restoreCS.lengthOfBytes(using: .utf8))
    }
}
