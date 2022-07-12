//
//  File.swift
//  
//
//  Created by Jonathan Badger on 6/17/22.
//

import Foundation

/**
 The LineEditor class
 
 - Description:
 */
public class LineEditor {
    public typealias ShouldWriteBuffer = Bool
    public typealias ShouldAddKeyToLineBuffer = Bool
    
    var startLocation: Location
    ///Stores the contents of user input as an attributed string.
    public var buffer: AttributedString
    ///When set to true ends user interaction and returns any caputred input from getLines
    public var shouldEndEditing: Bool = false
    
    public var cursorDangling: Bool = false
    
    public var navigationKeyHandler: ((Key) -> ShouldWriteBuffer)? = nil
    public var functionKwyHandler: ((Key) -> ShouldWriteBuffer)? = nil
    public var characterKeyHandler: ((Key) -> (ShouldWriteBuffer, ShouldAddKeyToLineBuffer))? = nil
    public var controlKeyHandler: ((Key) -> ShouldWriteBuffer)? = nil
    
    let terminal = Terminal.shared
    
    public init() throws {
        guard let startLocation = terminal.cursor.location else {
            throw TerminalError.failedToReadTerminalResponse(message: "Failed to get response for cursor position")
        }
        self.startLocation = startLocation
        self.buffer = AttributedString()
        self.navigationKeyHandler = defaultNavigationKeyHandler
        self.characterKeyHandler = defaultCharacterHandler
    }
    
    /**
     Used to gather a string of user input.
     
     
     */
    public func getLine() -> String {
        shouldEndEditing = false
        guard let startLocation = terminal.cursor.location else {
            return ""
            //throw TerminalError.failedToReadTerminalResponse(message: "Failed to get response for cursor position")
        }
        self.startLocation = startLocation
        while !shouldEndEditing {
            if let key = try? terminal.getKey() {
                var shouldWriteBuffer: Bool = false
                if key.isCharacter,
                   !key.rawValue.contains("\u{1b}["),
                   let characterKeyHandler  = characterKeyHandler {
                    let (writeBuffer, shouldAddKeyToLineBuffer) = characterKeyHandler(key)
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
        var y = startLocation.y //+ pieces.count - 1
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

    
    /**
     
     */
    public func defaultNavigationKeyHandler(key: Key) -> ShouldWriteBuffer {
        guard let currentLocation = terminal.cursor.location else { return false }
        guard let navigationKey = NavigationKey(rawValue: key.rawValue) else { return false }
        switch navigationKey {
        case .down:
            if let bufferIndex = bufferIndexFor(location: Location(x: currentLocation.x, y: currentLocation.y + 1)),
               buffer.characters.indices.contains(bufferIndex) {
                terminal.cursor.move(1, direction: .down)
            } else if buffer.characters.count > 0,
                      let lastCellLocation = locationForBufferIndex(buffer.characters.index(before: buffer.characters.endIndex)),
                      currentLocation.y < lastCellLocation.y {
                terminal.cursor.move(toLocation: Location(x: lastCellLocation.x + 1, y: lastCellLocation.y))
            }
        case .up:
            if let bufferIndex = bufferIndexFor(location: Location(x: currentLocation.x, y: currentLocation.y - 1)),
               buffer.characters.indices.contains(bufferIndex) {
                terminal.cursor.move(1, direction: .up)
            } else if let firstCellLocation = locationForBufferIndex(buffer.characters.startIndex),
                      currentLocation.y > firstCellLocation.y {
                terminal.cursor.move(toLocation: firstCellLocation)
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
        default: ()
        }
        return false
    }
    
    /**
     
     */
    func defaultCharacterHandler(key: Key) -> (ShouldWriteBuffer, ShouldAddKeyToLineBuffer) {
        
        if key.rawValue == Backspace {
            let shouldWriteBuffer = defaultBackspaceKeyHandler()
            return (shouldWriteBuffer, false)
        }
        if key.rawValue == Linefeed {
            shouldEndEditing = true
            return (false, false)
        }
        
        return (true, true)
    }
    
    func defaultBackspaceKeyHandler() -> ShouldWriteBuffer {
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
    

    
    /**
     
     */
    public func addKeyToLineBuffer(_ key: Key, attributes: [Attribute] = []) {
        if let startWriteLocation = terminal.cursor.location,
            let textAreaSize = try? terminal.textAreaSize() {
            /* the cursor stays in the last position of a line until the next added character requires a wrap.  Using the terminal to write a space from its current location will properly update the new location when wraps occur. */
            for char in key.rawValue {
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
    
    

    
    
    
}
