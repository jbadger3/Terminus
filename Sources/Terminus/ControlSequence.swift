//  Created by Jonathan Badger on 3/23/22.
// gist of ANSI escape sequences https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
// Windows Consol Vertual Terminal Sequences https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
// XTerm Control Sequences https://invisible-island.net/xterm/ctlseqs/ctlseqs.html


import Foundation



///Terminal Control Sequences (ANSI Escape Codes)
public struct ControlSequence {
    public typealias Response = String
    public enum Direction: String {
        case up = "A"
        case down = "B"
        case right = "C"
        case left = "D"
    }
    var rawString: String
    var hasResponse: Bool = false
    //ANSI Codes
    public static let ESC = "\u{1B}"  // Escape character (27 or 1B)
    public static let CSI = ESC + "["
    
    **** Need to think about just having Cursor call a single func rather than have ControlSequence have a generic execute function.  A bit wonky right now.
    //cursor related
    ///Gets the current position of the cursor 'ESC[6n'
    public static let cursorPosition = ControlSequence(rawString: CSI + "6n", hasResponse: true)
    ///Moves the cursor n spaces in a given direction (up, down, left, or right)
    public static func cursorMove(_ n: Int, direction: Direction) -> ControlSequence {
        let csString = ControlSequence.CSI + "\(n)" + direction.rawValue
        return ControlSequence(rawString: csString)
    }
    
    public static func cursorMove(toLocation location: Location) -> ControlSequence {
        let csString = ControlSequence.CSI + "\(location.y);\(location.x)H"
        return ControlSequence(rawString: csString)
    }
    public static func cursorMoveToHome() -> ControlSequence {
        return ControlSequence(rawString: ControlSequence.CSI + "H")
    }
    
  
    public func execute() -> Response? {
        let terminal = Terminal.shared
        var command = self.rawString
        terminal.write(&command, to: terminal.standardOutput)
        return hasResponse ? terminal.read(nBytes: 64) : nil
    }
}
