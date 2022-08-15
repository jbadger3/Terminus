//  Created by Jonathan Badger on 6/17/22.
//

import Foundation

/**
 A flexible control for collecting and editing user input.
 
The LineEditor editor class provides a familiar text editing experience out of the box.  To initiate user input call .getInput().  While input is being captured you can use the arrowkeys to move the cursor, insert, and delete characters.  When you are finisehd editing press return/enter to receive the input string back.

> Note: The linefeed character "\n" used to end user interaction is *not* included in the returned string.
 
```swift
 import Terminus
 let terminal = Terminal.shared
 terminal.write("Type something: ")
 
 let lineEditor = LineEditor()
 let input = lineEditor.getInput()
 
 terminal.write("\nYou typed: \(input)")
 sleep(2)
 ```
 
 As user input is being captured it is stored in the ``buffer`` property.  Although the buffer is a public property, custom editing and styling should be applied using ``LineEditor/bufferHandler``.  See the 'Adding color and style to text' below for an exmaple.
 
 ## Customizing Behavior
 
 LineEditor can be subclassed to customize how characters are processed and displayed to suit your own needs.  If, for example, you want to add autocomplete, you can do that.  If you want to allow for inputs that include Linefeed ("\n") characters you can do that too.
 
 All Inputs captured by the LineEditor are processed by key type (character, navigation, function, or control) using one of four handlers:

 - characterKeyHandler: ((Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer))?
 - navigationKeyHandler: ((Key) -> ShouldWriteBuffer)?
 - functionKeyHandler: ((Key) -> ShouldWriteBuffer)?
 - controlKeyHandler: ((Key) -> ShouldWriteBuffer)?
 
 To modify the behavior of LineEditor create a subclass of LineEditor, write your own handler function, and set it to the appropriate KeyHandler property.
 
 Before going into a few examples of customiztion take a look at the code for the default charcterKeyHandler:
 ```swift
 func defaultCharacterHandler(key: Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer) {
     if key.rawValue == Backspace {
         let shouldWriteBuffer = defaultBackspaceKeyHandler()
         return (false, shouldWriteBuffer)
     }
     if key.rawValue == Linefeed {
         shouldEndEditing = true
         return (false, false)
     }
     if key.rawValue == Esc {
         return (false, false)
     }
     return (true, true)
 }
 ```
This function does four things:
 1.  Handles Backspace key presses.  (make sure to copy/paste the code from the if statement in your custom function)
 2.  Checks if the return key ("\n") was pressed.  If so, shouldEndEditing is set to true signaling .getInput() to return the captured string.
 3.  If the escape key is pressed, skips adding it to the buffer.
 4.  For all other characters returns a tuple (true, true) indicating the key should be added to the buffer and the buffer should be written to the terminal.
 
 ### Example: Using the escape key to cancel editing
 
 ```swift
 import Terminus
 import Foundation

 let terminal = Terminal.shared
 let lineEditor = LineEditor()

 class EscapingLineEditor: LineEditor {
     override init() {
         super.init()
         self.characterKeyHandler = handleCharacter
     }
     
     func handleCharacter(key: Terminus.Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer) {
         if key.rawValue == Backspace {
             let shouldWriteBuffer = defaultBackspaceKeyHandler()
             return (false, shouldWriteBuffer)
         }
         if key.rawValue == Linefeed {
             shouldEndEditing = true
             return (false, false)
         }
         if key.rawValue == Esc {
             shouldEndEditing = true
             let range = buffer.startIndex..<buffer.endIndex
             buffer.removeSubrange(range)
             return (false, false)
         }
        return (true, true)
     }
 }

 let escapingEditor = EscapingLineEditor()
 let results = escapingEditor.getInput()
 terminal.write("\n")
 if results == "" {
     terminal.write("You escaped or didn't write anything.")
 } else {
     terminal.write("You typed: \(results)")
 }
 sleep(3)
 ```
 
 ## Example: Adding support for multiple lines of text
 
```swift
 import Terminus
 import Foundation

 let terminal = Terminal.shared

 class MultiLineEditor: LineEditor {
     override init() {
         super.init()
         self.characterKeyHandler = handleCharacter
     }
     
     func handleCharacter(key: Terminus.Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer) {
         if key.rawValue == Backspace {
             let shouldWriteBuffer = defaultBackspaceKeyHandler()
             return (false, shouldWriteBuffer)
         }
         if let currentLocation = terminal.cursor.location,
            let bufferIndex = bufferIndexForLocation(currentLocation),
            bufferIndex == buffer.characters.endIndex,
            buffer.characters.last == "\n",
            key.rawValue == "\n" {
             shouldEndEditing = true
             return (false, false)
         }
         if key.rawValue == Esc {
             return (false, false)
         }
         return (true, true)
     }
 }

 let multiLineEditor = MultiLineEditor()

 while true {
     let lines = multiLineEditor.getInput()
     terminal.write(lines, attributes: [.color(Color(r: 20, g: 255, b: 20))])
 }
 ```
 
 ## Example: Adding color and style to text
 
 There is one additional handler, `bufferHandler` that is called after a key press is received and added to the buffer, but before the buffer is rewritten to the terminal.  This is the place to
 
 
 
 
 */
open class LineEditor {
    public typealias ShouldWriteBuffer = Bool
    public typealias ShouldAddKeyToLineBuffer = Bool
    
    var startLocation: Location
    ///Stores the contents of user input as an attributed string.
    public var buffer: AttributedString
    ///When set to true ends user interaction and returns any caputred input from getLines
    public var shouldEndEditing: Bool = false
    ///A closure for handling character keypresses
    public var characterKeyHandler: ((Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer))? = nil
    ///A closure for handling navigation keypresses
    public var navigationKeyHandler: ((Key) -> ShouldWriteBuffer)? = nil
    ///A closure for handling function keypresses
    public var functionKwyHandler: ((Key) -> ShouldWriteBuffer)? = nil
    ///A closrue for handling control keypresses
    public var controlKeyHandler: ((Key) -> ShouldWriteBuffer)? = nil
    ///A closure for editing the contents of the input buffer
    public var bufferHandler: (() -> ShouldWriteBuffer)? = nil

    let terminal = Terminal.shared
    
    public init() {
        if let startLocation = terminal.cursor.location {
            self.startLocation = startLocation
        } else {
            self.startLocation = Location(x: 1, y: 1)
        }
        
        self.buffer = AttributedString()
        self.navigationKeyHandler = defaultNavigationKeyHandler
        self.characterKeyHandler = defaultCharacterHandler
    }
    
    /**
     Used to gather a string of user input.
     */
    public func getInput() -> String {
        shouldEndEditing = false
        buffer.removeSubrange(buffer.characters.startIndex..<buffer.characters.endIndex)
        guard let startLocation = terminal.cursor.location else {
            return ""
        }
        self.startLocation = startLocation
        while !shouldEndEditing {
            if let key = try? terminal.getKey() {
                var shouldWriteBuffer: Bool = false
                if key.isCharacter,
                   !key.rawValue.contains("\u{1b}["),
                   let characterKeyHandler  = characterKeyHandler {
                    let (shouldAddKeyToLineBuffer, writeBuffer) = characterKeyHandler(key)
                    shouldWriteBuffer = writeBuffer
                    if shouldAddKeyToLineBuffer {
                        addKeyToLineBuffer(key)
                    }
                } else if key.isFunction,
                          let functionKwyHandler = functionKwyHandler {
                    shouldWriteBuffer = functionKwyHandler(key)
                } else if key.isNavigation,
                          let navigationKeyHandler = navigationKeyHandler {
                    shouldWriteBuffer = navigationKeyHandler(key)
                } else if key.isControl,
                          let controlKeyHandler = controlKeyHandler {
                    shouldWriteBuffer = controlKeyHandler(key)
                }
                if let bufferHandler = bufferHandler {
                    shouldWriteBuffer = bufferHandler()
                }
                if shouldWriteBuffer {
                    self.writeBuffer()
                }
            }
        }
        return String(buffer.characters)
    }
    
    /**
    Moves the cursor in a given direction (up, down, left, or right)
     */
    public func moveCursor(_ direction: ANSIEscapeCode.Direction) {
        guard let currentLocation = terminal.cursor.location else { return }
        switch direction {
        case .up:
            //first check if we can move up
            if currentLocation.y > startLocation.y {
                if let bufferIndex = bufferIndexForLocation(Location(x: currentLocation.x, y: currentLocation.y - 1)),
                   buffer.characters.indices.contains(bufferIndex) {
                    terminal.cursor.move(1, direction: .up)
                } else if let lastCellLocation = lastCellLocationForLine(currentLocation.y - 1) {
                    terminal.cursor.move(toLocation: lastCellLocation)
                }
            } else if currentLocation.y == startLocation.y,
                      let firstCellLocation = locationForBufferIndex(buffer.characters.startIndex),
                      firstCellLocation != currentLocation {
                terminal.cursor.move(toLocation: firstCellLocation)
            }
        case .down:
            //first check if we can move down
            if currentLocation.y - startLocation.y < bufferHeight() - 1 {
                if let bufferIndex = bufferIndexForLocation(Location(x: currentLocation.x, y: currentLocation.y + 1)),
                   buffer.characters.indices.contains(bufferIndex) {
                    //if there is a character directly below, move there
                    terminal.cursor.move(1, direction: .down)
                } else if let lastCellLocation = lastCellLocationForLine(currentLocation.y + 1) {
                    if let textAreaSize = try? terminal.textAreaSize(),
                          let lastCellCharIndex = bufferIndexForLocation(lastCellLocation),
                          buffer.characters[lastCellCharIndex] == "\n" || lastCellLocation.x >= textAreaSize.width {
                        //if the last cell in the row below is a \n or the last column in the terminal move there
                        terminal.cursor.move(toLocation: lastCellLocation)
                        
                    } else {
                        //if all else falls through, moving to one past the last cell location should put the cursor at the end of editing
                        terminal.cursor.move(toLocation: Location(x: lastCellLocation.x + 1, y: lastCellLocation.y))
                    }
                }
            } else if let endBufferLocation = locationForBufferIndex(buffer.characters.endIndex),
                      currentLocation != endBufferLocation {
                terminal.cursor.move(toLocation: endBufferLocation)
            }
        case .right:
            if let currentCellIndex = bufferIndexForLocation(currentLocation),
               currentCellIndex < buffer.endIndex,
               let nextCellIndex = locationForBufferIndex(buffer.characters.index(after: currentCellIndex)){
                terminal.cursor.move(toLocation: nextCellIndex)
            }
        case .left:
            if let currentCellIndex = bufferIndexForLocation(currentLocation),
               currentCellIndex > buffer.startIndex,
               let previousCellIndex = locationForBufferIndex(buffer.characters.index(before: currentCellIndex)) {
                terminal.cursor.move(toLocation: previousCellIndex)
            }
        }
    }
    
    
    /**
    The default navigationKeyHandler, which adds support for arrow keys.
     */
    public func defaultNavigationKeyHandler(key: Key) -> ShouldWriteBuffer {
        guard let navigationKey = NavigationKey(rawValue: key.rawValue) else { return false }
        switch navigationKey {
        case .down:
            moveCursor(.down)
        case .up:
            moveCursor(.up)
        case .left:
            moveCursor(.left)
        case .right:
            moveCursor(.right)
        default: ()
        }
        return false
    }
    
    /**
    The default characterKeyHandler
     */
    func defaultCharacterHandler(key: Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer) {
        if key.rawValue == Backspace {
            let shouldWriteBuffer = defaultBackspaceKeyHandler()
            return (false, shouldWriteBuffer)
        }
        if key.rawValue == Linefeed {
            shouldEndEditing = true
            return (false, false)
        }
        if key.rawValue == Esc {
            return (false, false)
        }
        return (true, true)
    }
    
    /**
     The default backspaceKeyHandler.
     */
    public func defaultBackspaceKeyHandler() -> ShouldWriteBuffer {
        if buffer.characters.count > 0,
           let currentLocation = terminal.cursor.location,
           let currentIndex = bufferIndexForLocation(currentLocation),
           currentIndex > buffer.characters.startIndex {
            let deleteIndex = buffer.characters.index(before: currentIndex)

            if let deleteLocation = locationForBufferIndex(deleteIndex) {
                terminal.cursor.move(toLocation: deleteLocation)
                terminal.write("\u{7f}")
                terminal.cursor.move(toLocation: deleteLocation)
            }
            //look to see if the heght of the buffer has changed...if its less than before deleting a character all text will shift up and the last line will need to be manually cleared (not handled by writeBuffer)
            if  let startLastIndex = buffer.characters.indices.last,
                let startLastCellLocation = locationForBufferIndex(startLastIndex) {
                buffer.characters.remove(at: deleteIndex)
                if let endLastIndex = buffer.characters.indices.last,
                    let endLastCellLocation = locationForBufferIndex(endLastIndex),
                   startLastCellLocation.y > endLastCellLocation.y {
                    clearLine(startLastCellLocation.y)
                }
            }
            return true
        }
        return false
    }
    
    //MARK: internal buffer functions
    /*
     Adds one or more characters to the buffer at the current cursor location
     */
    func addKeyToLineBuffer(_ key: Key, attributes: [Attribute] = []) {
        if let startWriteLocation = terminal.cursor.location,
           let textAreaSize = try? terminal.textAreaSize() {
            let keyString = key.rawValue.replacingOccurrences(of: "\t", with: "    ")
            for char in keyString {
                terminal.write(String(char))
                if let endWriteLocation = terminal.cursor.location {
                    let startBufferHeight = bufferHeight()
                    if let index = bufferIndexForLocation(startWriteLocation) {
                        if startWriteLocation == endWriteLocation && char != "\n" {
                            if let nextIndex = bufferIndexForLocation(endWriteLocation) {
                                buffer.insert(AttributedString(String(char)), at: nextIndex)
                            }
                            /* the cursor stays in the last position of a line until the next added character requires a wrap.  Using the terminal to write a space in the current location helps force a line wrap when needed.  It's a bit wonky, but works for now. */
                            terminal.write(" ")
                            terminal.cursor.move(toLocation: Location(x: 1, y: endWriteLocation.y + 1))
                        } else {
                            buffer.insert(AttributedString(String(char)), at: index)
                        }
                        if bufferHeight() > startBufferHeight && startLocation.y + bufferHeight() - 1 > textAreaSize.height {
                               startLocation = Location(x: startLocation.x, y: startLocation.y - 1)
                        }
                    } else {
                        terminal.cursor.move(toLocation: startWriteLocation)
                        break
                    }
                } else {
                    terminal.cursor.move(toLocation: startWriteLocation)
                    break
                }
            }
        }
    }
    
    func bufferHeight() -> Int {
        guard let lastCellLocation = locationForBufferIndex(buffer.characters.endIndex) else { return 1 }
        return lastCellLocation.y - startLocation.y + 1
    }
    
    func writeBuffer() {
        guard let textAreaSize = try? terminal.textAreaSize() else { return }
        terminal.cursor.save()
        terminal.cursor.set(visibility: false)
        terminal.cursor.move(toLocation: startLocation)
        
        if buffer.characters.count > 0,
           let lastCellLocation = locationForBufferIndex(buffer.characters.index(before: buffer.characters.endIndex)) {
            var currentY = startLocation.y
            while currentY <= lastCellLocation.y {
                terminal.executeControlSequence(ANSIEscapeCode.eraseToEndOfLine)
                if currentY == textAreaSize.height {
                    break
                }
                currentY += 1
                terminal.cursor.move(toLocation: Location(x: 1, y: currentY))
            }
            terminal.cursor.move(toLocation: startLocation)
        }
        
        terminal.write(attributedString: buffer)
        terminal.cursor.restore()
        terminal.cursor.set(visibility: true)
    }
    
    func clearLine(_ line: Int) {
        let cursor = terminal.cursor
        cursor.set(visibility: false)
        cursor.save()
        let clearLocation = Location(x: 1, y: line)
        cursor.move(toLocation: clearLocation)
        terminal.executeControlSequence(ANSIEscapeCode.eraseLine)
        cursor.restore()
        cursor.set(visibility: true)
    }
    
    func lastCellLocationForLine(_ line: Int) -> Location? {
        guard let textAreaSize = try? terminal.textAreaSize() else { return nil }
        let maxWidth = textAreaSize.width
        var currentY = startLocation.y
        var currentX = startLocation.x
        var inTargetLine = currentY == line
        for charIndex in buffer.characters.indices {
            if inTargetLine && charIndex == buffer.characters.indices.last {
                return Location(x: currentX, y: currentY)
            }
            let char = buffer.characters[charIndex]
            if char == "\n" || currentX >= maxWidth {
                if inTargetLine {
                    return Location(x: currentX, y: currentY)
                }
                currentX = 1
                currentY += 1
            } else {
                currentX += 1
            }
            inTargetLine = currentY == line
        }
        return nil
    }
    

    
    /*
     When index == endIndex returns the location just after the last stored character
     */
    public func locationForBufferIndex(_ index: AttributedString.CharacterView.Index) -> Location? {
        guard let textAreaSize = try? terminal.textAreaSize() else { return nil }
        let maxWidth = textAreaSize.width
        var currentY = startLocation.y
        var currentX = startLocation.x
        for charIndex in buffer.characters.indices {
            if charIndex == index {
                return Location(x: currentX, y: currentY)
            }
            let char = buffer.characters[charIndex]
            if char == "\n" || currentX >= maxWidth {
                currentX = 1
                currentY += 1
            } else {
                currentX += 1
            }
        }
        if index == buffer.characters.endIndex {
            return Location(x: currentX, y: currentY)
        }
        return nil
    }
    
    public func bufferIndexForLocation(_ location: Location) -> AttributedString.CharacterView.Index? {
        guard let textAreaSize = try? terminal.textAreaSize() else { return nil }
        let maxWidth = textAreaSize.width
        var currentLocation = startLocation
        for charIndex in buffer.characters.indices {
            if currentLocation == location {
                return charIndex
            }
            let char = buffer.characters[charIndex]
            if char == "\n" || currentLocation.x >= maxWidth {
                currentLocation = Location(x: 1, y: currentLocation.y + 1)
            } else {
                currentLocation = Location(x: currentLocation.x + 1, y: currentLocation.y)
            }
        }
        if currentLocation == location {
            return buffer.characters.endIndex
        }
        return nil
    }
}
