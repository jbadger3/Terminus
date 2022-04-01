//  Created by Jonathan Badger on 12/28/21.
//

import Foundation





///The cursor in the terminal
public struct Cursor {
    public enum Style: Int {
        case blinking_block
        case blinking_block_default
        case steady_block
        case blinking_underline
        case steady_underline
        case blinking_bar // xterm.
        case steady_bar // xterm.
    }
    
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
    
    ///
    public func move(toLocation location: Location) {
        let controlSequence = ANSIEscapeCode.cursorMoveToLocation(location)
        Terminal.shared.executeControlSequence(controlSequence)
    }
    
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
    public func set(style: Style) {
        
        
    }
    

    
    
}
