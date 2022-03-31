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
    
    //ANSI Codes
    public static let ESC = "\u{1B}"  // Escape character (27 or 1B)
    public static let CSI = ESC + "["
    
    //cursor related
    ///Gets the current position of the cursor 'ESC[6n'
    public static let cursorPosition = CSI + "6n"
    
    ///Moves the cursor n spaces in a given direction (up, down, left, or right)
    public static func cursorMove(_ n: Int, direction: Direction) -> String {
        return CSI + "\(n)" + direction.rawValue
    }
    
    ///Moves the cursor to the specified (x, y) location
    public static func cursorMove(toLocation location: Location) -> String {
        return CSI + "\(location.y);\(location.x)H"
    }
    
    ///Moves the cursor to the home position (0, 0)
    public static let cursorMoveToHome = CSI + "H"
    

}
