//
//  File.swift
//  
//
//  Created by Jonathan Badger on 4/19/22.
//

import Foundation
@testable import Terminus

class TerminalTests: TestCase {
    var sut: Terminal!
    
    override func setUp() {
        sut = Terminal.shared
    }
    
    override func tearDown() {
        sut = nil
    }
    
    init() {
        super.init(name: "TerminalTests")
        tests = [Test(name: "test_write_givenOneStyleAttribute_appliesCorrectStyling", testFunction: test_write_givenOneStyleAttribute_appliesCorrectStyling, interactive: true),
                 Test(name: "test_write_givenMultipleStyleAttributes_appliesCorrectStyling", testFunction: test_write_givenMultipleStyleAttributes_appliesCorrectStyling, interactive: true),
                 Test(name: "test_write_givenStyleAndColorAttributes_appliesColorsAndStylesCorrectly", testFunction: test_write_givenStyleAndColorAttributes_appliesColorsAndStylesCorrectly, interactive: true),
                 Test(name: "test_textAreaSize_returnsSize", testFunction: test_textAreaSize_returnsSize, interactive: false)
        ]
    }
    
    func test_write_givenOneStyleAttribute_appliesCorrectStyling() throws {
        sut.executeControlSequence(ANSIEscapeCode.clearScreen)
        sut.executeControlSequence(ANSIEscapeCode.cursorMoveToHome)
        
        sut.write("Single style attribute tests.")
        sut.write("Dafault\n", attributes: [.resetToDefault])
        sut.write("Bold\n", attributes: [.bold])
        sut.write("Dim\n", attributes: [.dim])
        sut.write("Italic\n", attributes: [.italic])
        sut.write("blinking\n", attributes: [.blinking])
        sut.write("reverse\n", attributes: [.reverse])
        sut.write("Hello", attributes: [.hidden])
        sut.write(" The word 'Hello' is hidden at the front of this line.\n", attributes: [])
        sut.write("Strikethrough\n", attributes: [.strikethrough])
        try promptUserForVisualTest(prompt: "Is each line of text styled correctly?")
    }
    
    func test_write_givenMultipleStyleAttributes_appliesCorrectStyling() throws {
        sut.executeControlSequence(ANSIEscapeCode.clearScreen)
        sut.executeControlSequence(ANSIEscapeCode.cursorMoveToHome)
        sut.write("Multiple style attribute tests.\n", attributes: [])
        sut.write("Bold italic\n", attributes: [.bold, .italic])
        sut.write("Blinking bold\n", attributes: [.blinking, .bold])
        sut.write("Reverse dim\n", attributes: [.reverse, .dim])
        sut.write("Bold strikethrough reverse\n", attributes: [.bold, .strikethrough, .reverse])
        try promptUserForVisualTest(prompt: "Is each line of text styled with the appropriate attributes?")
    }
    
    func test_write_givenStyleAndColorAttributes_appliesColorsAndStylesCorrectly() throws {
        sut.executeControlSequence(ANSIEscapeCode.clearScreen)
        sut.executeControlSequence(ANSIEscapeCode.cursorMoveToHome)
        sut.write("Style and Color tests.\n", attributes: [])
        let palette = XTermPalette()
        sut.write("Italic green text.\n", attributes: [.italic, .color(palette.Green4)])
        sut.write("Bold light blue blackground.\n", attributes: [.bold, .colorPair(ColorPair(foreground: palette.White, background: palette.LightSkyBlue1))])
        try promptUserForVisualTest(prompt: "Are color and styling applied correctly in each line?")
    }
    
    func test_textAreaSize_returnsSize() throws {
        sut.executeControlSequence(ANSIEscapeCode.clearScreen)
        sut.executeControlSequence(ANSIEscapeCode.cursorMoveToHome)
        let size = sut.textAreaSize()
        TAssertNotEqual(size.width, -1)
        TAssertNotEqual(size.height, -1)
    }
 
}
