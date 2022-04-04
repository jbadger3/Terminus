//  Created by Jonathan Badger on 12/28/21.
//

import Foundation





///The cursor in the terminal
public struct Cursor {

    
    public var location: Location? {
        let terminal = Terminal.shared
        let controlSequence = ANSIEscapeCode.cursorPosition
        guard let locationString = terminal.executeControlSequenceWithResponse(controlSequence) else { return nil }
        let items = locationString.strippingCSI().split(separator: ";").map{$0.trimmingCharacters(in: .letters)}.map{Int($0)}.filter({$0 != nil})
        if items.count == 2,
            let x = items[0],
            let y = items[1] {
            return Location(x: x, y: y)
        }
        return nil
    }

    public init() {
        
    }
    
    ///Moves the cursor to the specified location (x, y).
    public func move(toLocation location: Location) {
        let controlSequence = ANSIEscapeCode.cursorMoveToLocation(location)
        Terminal.shared.executeControlSequence(controlSequence)
    }
    
    ///Moves the cursor n units in the direction (up, down, left, right) specified
    public func move(_ n: Int, direction: ANSIEscapeCode.Direction) {
        let controlSequence = ANSIEscapeCode.cursorMove(n: n, direction: direction)
        Terminal.shared.executeControlSequence(controlSequence)
    }
    
    ///moves the cursor to (0, 0)
    public func moveToHome() {
        let controlSequence = ANSIEscapeCode.cursorMoveToHome
        Terminal.shared.executeControlSequence(controlSequence)
    }
    
    ///Sets the cursor style
    public func set(style: ANSIEscapeCode.Style) {
        let controlSequence = ANSIEscapeCode.cursorStyle(style: style)
        Terminal.shared.executeControlSequence(controlSequence)
    }
    
    ///Sets cursor visibility
    public func set(visibility: Bool) {
        let controlSequence = ANSIEscapeCode.cursorVisible(visibility)
        Terminal.shared.executeControlSequence(controlSequence)
    }
    
    ///Saves the current location of the cursor
    public func save() {
        let controlSequence = ANSIEscapeCode.cursorSave
        Terminal.shared.executeControlSequence(controlSequence)
    }
    
    ///Restores the cursor to the last saved position
    public func restore() {
        let controlSequence = ANSIEscapeCode.cursorRestore
        Terminal.shared.executeControlSequence(controlSequence)
    }
    
    
    

    
    
}