//  Created by Jonathan Badger on 3/25/22.
//

import Foundation
@testable import Terminus


class CursorTests: TestCase {
    var terminal: Terminal!
    var sut: Cursor!
    
    override func setUp() {
        sut = Cursor()
        terminal = Terminal.shared

    }
    
    override func tearDown() {
        sut = nil
        terminal = nil
    }
    
    
    init() {
        super.init(name: "CursorTests")
        tests = [
            Test(name: "test_location_whenLocationSetTo2_3_returnsLocation2_3", testFunction: test_location_whenLocationSetTo2_3_returnsLocation2_3),
            Test(name: "test_moveToLocation_movesToSpecifiedLocation", testFunction: test_moveToLocation_movesToSpecifiedLocation),
            Test(name: "test_moveNDirection_whenGivenNUnitsAndDirection_movesCursorAccordingly", testFunction: test_moveNDirection_whenGivenNUnitsAndDirection_movesCursorAccordingly),
            Test(name: "test_moveToHome_movesCursorLocationTo1_1", testFunction: test_moveToHome_movesCursorLocationTo1_1),
            Test(name: "test_setStyle_whenBlinkingBlock_changesToBlinkingBlock", testFunction: test_setStyle_whenBlinkingBlock_changesToBlinkingBlock, interactive: true),
            Test(name: "test_setStyle_whenBlinkingBlockDefault_changesToBlinkingBlock", testFunction: test_setStyle_whenBlinkingBlockDefault_changesToBlinkingBlock, interactive: true),
            Test(name: "test_setStyle_whenSteadyBlock_changesToSteadyBlock", testFunction: test_setStyle_whenSteadyBlock_changesToSteadyBlock, interactive: true),
            Test(name: "test_setStyle_whenBlinkingUnderline_changesToBlinkingUnderline", testFunction: test_setStyle_whenBlinkingUnderline_changesToBlinkingUnderline, interactive: true),
            Test(name: "test_setStyle_whenSteadyUnderline_changesToSteadyUnderline", testFunction: test_setStyle_whenSteadyUnderline_changesToSteadyUnderline, interactive: true),
            Test(name: "test_setStyle_whenBlinkingBar_changesToBlinkingBar", testFunction: test_setStyle_whenBlinkingBar_changesToBlinkingBar, interactive: true),
            Test(name: "test_setStyle_whenSteadyBar_changesToSteadyBar", testFunction: test_setStyle_whenSteadyBar_changesToSteadyBar, interactive: true),
            Test(name: "test_setVisibility_whenFalse_hidesCursor", testFunction: test_setVisibility_whenFalse_hidesCursor, interactive: true),
            Test(name: "test_setVisibility_whenTrue_showsCursor", testFunction: test_setVisibility_whenTrue_showsCursor, interactive: true),
            Test(name: "test_save_whenRestoreCalled_returnsCursorToSavedLocation", testFunction: test_save_whenRestoreCalled_returnsCursorToSavedLocation),
            Test(name: "test_restore_givenCursorStoredAt1025_returnsCursorTo1025", testFunction: test_restore_givenCursorStoredAt1025_returnsCursorTo1025)
        ]
    }
    
    //MARK: Helper functions
    func saveCursorPosition() {
        var saveCS = ESC + "7"
        write(STDOUT_FILENO, &saveCS, saveCS.lengthOfBytes(using: .utf8))
    }
    
    func restoreCursorPosition() {
        var restoreCS = ESC + "8"
        write(STDOUT_FILENO, &restoreCS, restoreCS.lengthOfBytes(using: .utf8))
    }
   
    func test_location_whenLocationSetTo2_3_returnsLocation2_3() throws {
        saveCursorPosition()
        var locationString = CSI + "3;2H"
        write(STDOUT_FILENO , &locationString, locationString.lengthOfBytes(using: .utf8))
        let expectedLocation = Location(x: 2, y: 3)
        let cursorLocation = sut.location
        TAssertEqual(cursorLocation, expectedLocation)
        restoreCursorPosition()
    }
    
    func test_moveToLocation_movesToSpecifiedLocation() throws {
        saveCursorPosition()
        let expectedLocation = Location(x: 25, y: 30)
        
        sut.move(toLocation: expectedLocation)
        let finalLocation = sut.location

        TAssertEqual(expectedLocation, finalLocation)
        restoreCursorPosition()
    }
    
    func test_moveNDirection_whenGivenNUnitsAndDirection_movesCursorAccordingly() throws {
        saveCursorPosition()
        
        var expectedLocation = Location(x: 0, y: 0)
        var finalLocation: Location! = Location(x: 0, y: 0)
        let startingLocation = Location(x: 25, y: 25)
        sut.move(toLocation: startingLocation)
        TAssertEqual(startingLocation, sut.location!)
        //down 5
        expectedLocation = Location(x: 25, y: 30)
        sut.move(5, direction: .down)
        finalLocation = sut.location
        TAssertEqual(expectedLocation, finalLocation)
        
        sut.move(toLocation: startingLocation)
        //up 3
        expectedLocation = Location(x: 25, y: 22)
        sut.move(3, direction: .up)
        finalLocation = sut.location
        TAssertEqual(expectedLocation, finalLocation)
        
        sut.move(toLocation: startingLocation)
        //right 7
        expectedLocation = Location(x:32, y: 25)
        sut.move(7, direction: .right)
        finalLocation = sut.location
        TAssertEqual(expectedLocation, finalLocation)
        
        sut.move(toLocation: startingLocation)
        //left 2
        expectedLocation = Location(x: 23, y: 25)
        sut.move(2, direction: .left)
        finalLocation = sut.location
        TAssertEqual(expectedLocation, finalLocation)
        
        restoreCursorPosition()
    }
    
    func test_moveToHome_movesCursorLocationTo1_1() throws {
        saveCursorPosition()
        let startingLocation = Location(x: 25, y: 25)
        sut.move(toLocation: startingLocation)
        TAssertEqual(startingLocation, sut.location)
        
        sut.moveToHome()
        
        let expectedLocation = Location(x: 1, y: 1)
        TAssertEqual(expectedLocation, sut.location )
        
        restoreCursorPosition()
    }
    

    
    func test_setStyle_whenBlinkingBlock_changesToBlinkingBlock() throws {
        sut.set(style: .steady_bar)
        sut.set(style: .blinking_block)
        try promptUserForVisualTest(prompt: "Is the cursor a blinking block?")
    }
    
    func test_setStyle_whenBlinkingBlockDefault_changesToBlinkingBlock() throws {
        sut.set(style: .steady_bar)
        sut.set(style: .blinking_block_default)
        try promptUserForVisualTest(prompt: "Is the cursor a blinking block?")
    }
    
    func test_setStyle_whenSteadyBlock_changesToSteadyBlock() throws {
        sut.set(style: .steady_block)
        try promptUserForVisualTest(prompt: "Is the cursor a steady block?")
    }
    
    func test_setStyle_whenBlinkingUnderline_changesToBlinkingUnderline() throws {
        sut.set(style: .blinking_underline)
        try promptUserForVisualTest(prompt: "Is the cursor blinking underline?")
    }
    
    func test_setStyle_whenSteadyUnderline_changesToSteadyUnderline() throws {
        sut.set(style: .steady_underline)
        try promptUserForVisualTest(prompt: "Is the cursor a steady underline?")
    }
    
    func test_setStyle_whenBlinkingBar_changesToBlinkingBar() throws {
        sut.set(style: .blinking_bar)
        try promptUserForVisualTest(prompt: "Is the cursor a blinking bar?")
    }
    
    func test_setStyle_whenSteadyBar_changesToSteadyBar() throws {
        sut.set(style: .steady_bar)
        try promptUserForVisualTest(prompt: "Is the cursor a steady bar?")
    }
    
    func test_setVisibility_whenFalse_hidesCursor() throws {
        sut.set(visibility: false)
        try promptUserForVisualTest(prompt: "Is the cursor invisible?")
    }
    
    func test_setVisibility_whenTrue_showsCursor() throws {
        sut.set(visibility: true)
        try promptUserForVisualTest(prompt: "Can you see the cursor?")
    }
    
    func test_save_whenRestoreCalled_returnsCursorToSavedLocation() throws {
        let startLocation = sut.location
        sut.save()
        
        let terminal = Terminal.shared
        terminal.write("Lets move the cursor a bit.", attributes: [])
        let alteredLocation = sut.location
        TAssertNotEqual(startLocation, alteredLocation)
        let restoreCS = ANSIEscapeCode.cursorRestore
        terminal.executeControlSequence(restoreCS)
        let finalLocation = sut.location
        TAssertEqual(startLocation, finalLocation)
    }
    
    func test_restore_givenCursorStoredAt1025_returnsCursorTo1025() throws {
        let testLocation = Location(x: 10, y: 25)
        sut.move(toLocation: testLocation)
        sut.save()
        
        sut.move(toLocation: Location(x: 1, y: 1))
        TAssertEqual(Location(x: 1, y: 1), sut.location)
        
        sut.restore()
        
        TAssertEqual(sut.location, testLocation)
    }
    
    
    
    
    
     
    
    
}
