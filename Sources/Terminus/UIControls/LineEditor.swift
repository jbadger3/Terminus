//
//  File.swift
//  
//
//  Created by Jonathan Badger on 6/17/22.
//

import Foundation

/**
 A flexible control for collecting and editing user input.
 
LineEditor provides a familiar text editing experience.  To begin capturing input call .getInput().  While input is being captured you can use the arrowkeys to move the cursor, insert, and delete characters.  When you are finisehd editing press return/enter to receive the input string back.

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
 
 ## Customizing Behavior
 
 The line editor provides basic functionality out of the box, but you can customize how characters are processed and displayed to suit your own needs.  If, for example, you want to add autocomplete, you can do that.  If you want to allow for inputs that include Linefeed ("\n") characters you can do that too.
 
 All Inputs captured by the LineEditor are processed by key type (character, navigation, function, or control) using one of four handlers:

 - characterKeyHandler: ((Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer))?
 - navigationKeyHandler: ((Key) -> ShouldWriteBuffer)?
 - functionKeyHandler: ((Key) -> ShouldWriteBuffer)?
 - controlKeyHandler: ((Key) -> ShouldWriteBuffer)?
 
 To modify the behavior of LineEditor you create a subclass of LineEditor, create your own handler function, and set it to the appropriate KeyHandler property.
 
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
This function does four things.
 1.  Handles Backspace key presses.  (make sure to copy/paste the code from the if statement in your custom function)
 2.  Checks if the return key ("\n") was pressed.  If so, shouldEndEditing is set to true signaling .getInput() to return the captured string.
 3.  If the escape key is pressed, skips adding it to the buffer.
 4.  For all other characters returns a tuple (true, true) indicating the key should be added to the buffer and the buffer should be written to the terminal.
 
 Now take a look at a few examples.
 
 ### Using the escape key to cancel editing
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


 
 */
open class LineEditor {
    public typealias ShouldWriteBuffer = Bool
    public typealias ShouldAddKeyToLineBuffer = Bool
    
    var startLocation: Location
    ///Stores the contents of user input as an attributed string.
    public var buffer: AttributedString
    ///When set to true ends user interaction and returns any caputred input from getLines
    public var shouldEndEditing: Bool = false
    
    public var characterKeyHandler: ((Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer))? = nil
    public var navigationKeyHandler: ((Key) -> ShouldWriteBuffer)? = nil
    public var functionKwyHandler: ((Key) -> ShouldWriteBuffer)? = nil
    public var controlKeyHandler: ((Key) -> ShouldWriteBuffer)? = nil
    
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
            if let bufferIndex = bufferIndexFor(location: Location(x: currentLocation.x, y: currentLocation.y - 1)),
               buffer.characters.indices.contains(bufferIndex) {
                terminal.cursor.move(1, direction: .up)
            } else if let firstCellLocation = locationForBufferIndex(buffer.characters.startIndex) {
                if currentLocation.y > firstCellLocation.y || firstCellLocation != currentLocation {
                    terminal.cursor.move(toLocation: firstCellLocation)
                }
            }
        case .down:
            if let bufferIndex = bufferIndexFor(location: Location(x: currentLocation.x, y: currentLocation.y + 1)),
               buffer.characters.indices.contains(bufferIndex) {
                terminal.cursor.move(1, direction: .down)
            } else if buffer.characters.count > 0,
                      let lastCellLocation = locationForBufferIndex(buffer.characters.index(before: buffer.characters.endIndex)) {
                if currentLocation.y < lastCellLocation.y || currentLocation != lastCellLocation {
                    terminal.cursor.move(toLocation: Location(x: lastCellLocation.x + 1, y: lastCellLocation.y))
                }
            }
        case .right:
            if buffer.characters.count > 0,
               let lastCellLocation = locationForBufferIndex(buffer.characters.index(before: buffer.characters.endIndex)),
               currentLocation != Location(x: lastCellLocation.x + 1, y: lastCellLocation.y),
               let textArea = try? terminal.textAreaSize() {
                if currentLocation.y < lastCellLocation.y && currentLocation.x == textArea.width {
                    terminal.cursor.move(toLocation: Location(x: 1, y: currentLocation.y + 1))
                } else {
                    terminal.cursor.move(toLocation: Location(x: currentLocation.x + 1, y: currentLocation.y))
                }
            }
        case .left:
            if currentLocation != startLocation,
               let textArea = try? terminal.textAreaSize() {
                if currentLocation.x == 1 {
                    terminal.cursor.move(toLocation: Location(x: textArea.width, y: currentLocation.y - 1))
                } else {
                    terminal.cursor.move(toLocation: Location(x: currentLocation.x - 1, y: currentLocation.y))
                }
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
           let currentIndex = bufferIndexFor(location: currentLocation),
           currentIndex > buffer.characters.startIndex {
            let deleteIndex = buffer.characters.index(before: currentIndex)
            
            buffer.characters.remove(at: deleteIndex)
            if currentLocation.x > 1 {
                terminal.cursor.move(toLocation: Location(x: currentLocation.x - 1, y: currentLocation.y))
                terminal.write("\u{7f}")
                terminal.cursor.move(toLocation: Location(x: currentLocation.x - 1, y: currentLocation.y))
                
            } else if currentLocation.y > 1,
                      let textArea = try? terminal.textAreaSize() {
                terminal.cursor.move(toLocation: Location(x: textArea.width, y: currentLocation.y - 1))
                terminal.write("\u{7f}")
                terminal.cursor.move(toLocation: Location(x: textArea.width, y: currentLocation.y - 1))
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
            /* the cursor stays in the last position of a line until the next added character requires a wrap.  Using the terminal to write a space in the current location helps detect where and when wrapping occurs.  It's a bit wonky, but works for now. */
            let keyString = key.rawValue.replacingOccurrences(of: "\t", with: "    ")
            for char in keyString {
                terminal.write(" ")
                if let endWriteLocation = terminal.cursor.location {
                    /*if the cursor is at the last position it will scroll, so the start location needs to be updated*/
                    if startWriteLocation == Location(x: textAreaSize.width, y: textAreaSize.height) && endWriteLocation != startWriteLocation {
                        startLocation = Location(x: startLocation.x, y: startLocation.y - 1)
                    }
                    if let index = bufferIndexFor(location: startWriteLocation) {
                        if startWriteLocation == endWriteLocation {
                            if let nextIndex = bufferIndexFor(location: endWriteLocation) {
                                buffer.insert(AttributedString(String(char)), at: nextIndex)
                            }
                        } else {
                            buffer.insert(AttributedString(String(char)), at: index)
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
    
    func writeBuffer() {
        guard let textAreaSize = try? terminal.textAreaSize() else { return }
        let startPosition = terminal.cursor.location
        terminal.cursor.save()
        terminal.cursor.set(visibility: false)
        terminal.cursor.move(toLocation: startLocation)
        
        if let startPosition = startPosition,
           buffer.characters.count > 0,
           let lastCellLocation = locationForBufferIndex(buffer.characters.index(before: buffer.characters.endIndex)) {
            var currentY = startPosition.y
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
        let endPosition = terminal.cursor.location
        if startPosition != endPosition {
            terminal.cursor.restore()
        }
        terminal.cursor.set(visibility: true)
    }
    
    func locationForBufferIndex(_ index: AttributedString.CharacterView.Index) -> Location? {
        guard let textAreaSize = try? terminal.textAreaSize() else { return nil }
        if buffer.characters.startIndex == index {
            return startLocation
        }
        
        guard buffer.characters.indices.contains(index) else { return nil }
        
        let subString = String(buffer.characters.prefix(through: index))
        
        let pieces = subString.split(separator: Character("\n"))
        var y = startLocation.y
        var x: Int = 0
        
        //count number of wrapping lines
        for (pieceIdx, piece) in pieces.enumerated() {
            let xOffset = pieceIdx == 0 ? startLocation.x - 1 : 0
            
            
            y += (piece.count + xOffset) / textAreaSize.width
            
            
            if pieceIdx == pieces.count - 1 {
                x = (piece.count + xOffset) % textAreaSize.width
            }
        }
        return Location(x: x, y: y)
    }
    
    func bufferIndexFor(location: Location) -> AttributedString.CharacterView.Index? {
        guard let textAreaSize = try? terminal.textAreaSize() else { return nil }
        guard location >= startLocation else { return nil }
        let textWidth = textAreaSize.width
        
        var currentY = startLocation.y
        let pieces = buffer.characters.split(separator: "\n")
        if pieces.count == 0,
           currentY == location.y,
           buffer.characters.distance(from: buffer.characters.startIndex, to: buffer.characters.endIndex) == location.x - startLocation.x {
            return buffer.characters.endIndex
        }
        for (pieceIdx, piece) in pieces.enumerated() {
            var xOffset = pieceIdx == 0 ? startLocation.x - 1: 0
            
            var numCharacters = piece.count + xOffset
            var currentPieceIndex = piece.startIndex
            while numCharacters >= textWidth {
                if currentY == location.y {
                    if piece.distance(from: currentPieceIndex, to: piece.endIndex) <= 1 {
                        return piece.endIndex
                    } else {
                        return piece.index(currentPieceIndex, offsetBy: location.x - xOffset - 1, limitedBy: piece.endIndex)
                    }
                } else {
                    if let endIndex = piece.index(currentPieceIndex, offsetBy: textWidth - xOffset, limitedBy: piece.endIndex) {
                        currentPieceIndex = endIndex
                        numCharacters = piece.distance(from: currentPieceIndex, to: piece.endIndex)
                        currentY += 1
                        xOffset = 0
                    }
                }
            }
            if currentY == location.y {
                if piece.distance(from: currentPieceIndex, to: piece.endIndex) <= 1 {
                    return piece.endIndex
                } else {
                    return piece.index(currentPieceIndex, offsetBy: location.x - xOffset - 1, limitedBy: piece.endIndex)
                }
            }
            currentY += 1
        }
        return nil
    }
}
