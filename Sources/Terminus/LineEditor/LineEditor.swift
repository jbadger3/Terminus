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
    ///Stores the contents of user input
    public var cellBuffer: CellBuffer
    ///When set to true ends user interaction and returns any caputred input from getLines
    public var shouldEndEditing: Bool = false
    
    
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
        self.cellBuffer = CellBuffer()
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
                   !key.rawValue.starts(with: "\u{1b}["),
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
        return cellBuffer.stringValue
    }
    
    func writeBuffer() {
        let startPosition = terminal.cursor.location
        terminal.cursor.save()
        terminal.cursor.set(visibility: false)
        terminal.cursor.move(toLocation: startLocation)
        
        if let startPosition = startPosition,
            let lastCellLocation = locationForBufferIndex(cellBuffer.cells.endIndex - 1) {
            var currentY = startPosition.y
            while currentY <= lastCellLocation.y {
                terminal.executeControlSequence(ANSIEscapeCode.eraseToEndOfLine)
                currentY += 1
                terminal.cursor.move(toLocation: Location(x: 1, y: currentY))
            }
            terminal.cursor.move(toLocation: startLocation)
        }

        
        cellBuffer.writeBuffer()
        let endPosition = terminal.cursor.location
        if startPosition != endPosition {
            terminal.cursor.restore()
        }

        terminal.cursor.set(visibility: true)
    }
    
    func locationForBufferIndex(_ index: Int) -> Location? {
        guard let textAreaSize = try? terminal.textAreaSize() else { return nil }
        let startingLocationIndex = (startLocation.y - 1) * textAreaSize.width + startLocation.x - 1
        let locationIndex = index + startingLocationIndex
        let y = locationIndex / textAreaSize.width + 1
        let x = locationIndex % textAreaSize.width + 1
        return Location(x: x, y: y)
    }
    
    func bufferIndexFor(location: Location) -> Int? {
        guard let textAreaSize = try? terminal.textAreaSize() else { return nil }
        let startingLocationIndex = (startLocation.y - 1) * textAreaSize.width + startLocation.x - 1
        let locationIndex = (location.y - 1) * textAreaSize.width + location.x - 1
        
        return locationIndex - startingLocationIndex
    }
    
    /**
     
     */
    public func defaultNavigationKeyHandler(key: Key) -> ShouldWriteBuffer {
        guard let currentLocation = terminal.cursor.location else { return false }
        guard let navigationKey = NavigationKey(rawValue: key.rawValue) else { return false }
        
        switch navigationKey {
        case .down:
            if let bufferIndex = bufferIndexFor(location: Location(x: currentLocation.x, y: currentLocation.y + 1)),
               cellBuffer.cells.indices.contains(bufferIndex) {
                terminal.cursor.move(1, direction: .down)
            } else if let lastCellLocation = locationForBufferIndex(cellBuffer.cells.count - 1),
                      currentLocation.y < lastCellLocation.y {
                terminal.cursor.move(toLocation: Location(x: lastCellLocation.x + 1, y: lastCellLocation.y))
            }
        case .up:
            if let bufferIndex = bufferIndexFor(location: Location(x: currentLocation.x, y: currentLocation.y - 1)),
               cellBuffer.cells.indices.contains(bufferIndex) {
                terminal.cursor.move(1, direction: .up)
            } else if let firstCellLocation = locationForBufferIndex(0),
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
            if let lastCellLocation = locationForBufferIndex(cellBuffer.cells.count - 1),
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
        if key.rawValue == CarriageReturn {
            shouldEndEditing = true
            return (false, false)
        }
        
        return (false, false)
    }
    
    func defaultBackspaceKeyHandler() -> ShouldWriteBuffer {
        if cellBuffer.cells.count > 0,
           let currentLocation = terminal.cursor.location,
           let currentIndex = bufferIndexFor(location: currentLocation) {
            let deleteIndex = currentIndex - 1
            if deleteIndex >= 0 {
                cellBuffer.deleteCell(index: deleteIndex)
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
                    let cell = Cell(contents: Character(extendedGraphemeClusterLiteral: char), attributes: attributes)
                    /*if the cursor is at the last position it will scroll, so the start location needs to be updated*/
                    if startWriteLocation == Location(x: textAreaSize.width, y: textAreaSize.height) && endWriteLocation != startWriteLocation {
                        startLocation = Location(x: startLocation.x, y: startLocation.y - 1)
                    }
                    if let index = bufferIndexFor(location: endWriteLocation) {
                        if startWriteLocation == endWriteLocation {
                            cellBuffer.add(cell: cell, index: index)
                        } else {
                            cellBuffer.add(cell: cell, index: index - 1)
                        }
                    }
                } else {
                    terminal.cursor.move(toLocation: startWriteLocation)
                    break
                }
            }

        }
    }
    
    

    
    
    
}
