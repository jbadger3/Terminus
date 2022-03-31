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
        guard let locationString = terminal.executeControlSequenceWithResponse(ControlSequence.cursorPosition) else { return nil }
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
        Terminal.shared.executeControlSequence(ControlSequence.cursorMove(toLocation: location))
    }
    
    public func move(_ n: Int, direction: ControlSequence.Direction) {
        Terminal.shared.executeControlSequence(ControlSequence.cursorMove(n, direction: direction))
    }
    
    ///moves the cursor to (0, 0)
    public func moveToHome() {
        Terminal.shared.executeControlSequence(ControlSequence.cursorMoveToHome)
    }
    
    ///Sets the cursor style
    public func set(style: Style) {
        
        
    }
    

    
    
}
