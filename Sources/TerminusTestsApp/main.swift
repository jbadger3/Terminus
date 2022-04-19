//
//  Created by Jonathan Badger on 4/11/22.
//

import Foundation
import ArgumentParser
import Terminus

enum Palette: String {
    case basic
    case xterm
    case x11web
}



struct RunTests: ParsableCommand {
    @Option(name: [.short, .customLong("logFile")], help: "Output file for test logs.")
    var logFile: String?
    
    @Option(name: [.short, .customLong("palette")], help: "Displays one of the built-in color paletts.  Options are 'basic', 'xterm', or 'x11web'")
    var paletteString: String?
    
    mutating func run() throws {
        if let paletteString = paletteString {
            if let palette = Palette(rawValue: paletteString) {
                switch palette {
                case .basic:
                    showColors(colorPalette: BasicColorPalette() as ColorPalette)
                case .xterm:
                    showColors(colorPalette: XTermPalette() as ColorPalette)
                case .x11web:
                    showColors(colorPalette: X11WebPalette() as ColorPalette)
                }
            } else { print("Palette \(paletteString) unknown.  Please choose one from (basic, xterm, x11web)")}
        } else {
            setUp()
            runTestCases()
            tearDown()
            
        }
    }
    
    func setUp() {
        guard let logFile = logFile else {
            return
        }

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
    
    func showColors(colorPalette: ColorPalette) {
        let darkColors = ["Black", "Grey3", "Grey7","Grey11","Grey15", "Grey19", "Grey23", "Navy", "Grey0", "NavyBlue", "DarkBlue", "MidnightBlue", "Maroon","DarkSlateGray", "Indigo", "MediumBlue"]
        let terminal = Terminal.shared
        for color in colorPalette.allColors() {
            if darkColors.contains(color.name) {
                terminal.write(" \(color.name)".padding(toLength: 18, withPad: " ", startingAt: 0), attributes: [.colorPair(ColorPair(foreground: color.color, background: Color(r: 200, g: 200, b: 200))), .reverse])
            } else {
                terminal.write(" \(color.name)".padding(toLength: 18, withPad: " ", startingAt: 0), attributes: [.colorPair(ColorPair(foreground: color.color, background: Color(r: 20, g: 20, b: 20))),.reverse])
            }
            
        }
    }
}

RunTests.main()





