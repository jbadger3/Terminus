//
//  Created by Jonathan Badger on 4/11/22.
//

import Foundation
import ArgumentParser
import Terminus


struct RunTests: ParsableCommand {
    @Option(name: [.short, .customLong("logFile")], help: "Output file for test logs.")
    var logFile: String
    
    mutating func run() throws {
        setUp()
        runTestCases()
        tearDown()
    }
    
    func setUp() {
        let fileManager = FileManager.default
        fileManager.createFile(atPath: logFile, contents: nil)
        let fileHandle = FileHandle(forWritingAtPath: logFile)
        let testLogger = TestLogger.shared
        testLogger.fileHandle = fileHandle
    }
    
    func runTestCases() {
        let testCases = [CursorTests()]
        for testCase in testCases {
            testCase.runTests()
        }
    }
    
    func tearDown() {
        let testLogger = TestLogger.shared
        try? testLogger.fileHandle?.close()
    }
    
}


let terminal = Terminal.shared

var shouldquit = false

//terminal.executeControlSequence(ANSIEscapeCode.colorSetBackground(index: 80))
//terminal.executeControlSequence(ANSIEscapeCode.colorSetForegroundRGB(r: 240, g: 0, b: 240))
let palette = XTermPalette()
let colorPair = ColorPair(foreground: palette.Lime, background: palette.DarkBlue)
terminal.write("Hello", attributes: [.colorPair(colorPair)])
while !shouldquit {
    if let key = terminal.getKey() {
        terminal.write(key.rawValue)
        if key.rawValue == "q" {
            terminal.quit()
        }
    }
}
 

RunTests.main()





