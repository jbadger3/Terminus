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
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                            isDirectory: true)
        let stdinURL = temporaryDirectoryURL.appendingPathComponent("stdin.\(UUID())")
        
        let stdoutURL = temporaryDirectoryURL.appendingPathComponent("stdout.\(UUID())")
        let fileManager = FileManager.default
        fileManager.createFile(atPath: stdinURL.path, contents: nil)
        fileManager.createFile(atPath: stdoutURL.path, contents: nil)
        
        terminal.standardInput = try! FileHandle(forUpdating: stdinURL)
        terminal.standardOutput = try! FileHandle(forUpdating: stdoutURL)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        terminal = nil
    }
    

    func test_location_whenLocationSetToZeroZero_returnsLocationZeroZero() {
        var responseString = ControlSequence.CSI + "0;0R"
        terminal.write(&responseString, to: terminal.standardInput)
        try! terminal.standardInput.seek(toOffset: 0)
        let expectedLocation = Location(x: 0, y: 0)
        let cursorLocation = sut.location

        XCTAssertEqual(cursorLocation, expectedLocation)
        
    }
     
    
    
}
