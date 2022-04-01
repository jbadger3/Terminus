//  Created by Jonathan Badger on 3/23/22.
// gist of ANSI escape sequences https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
// Windows Consol Vertual Terminal Sequences https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
// XTerm Control Sequences https://invisible-island.net/xterm/ctlseqs/ctlseqs.html


import Foundation

public let ESC = "\u{1B}" // Escape character (27 or 1B)
public let CSI = ESC + "["

///Terminal Control Sequences (ANSI Escape Codes)
public enum ControlSequence {
    public enum Direction: String {
        case up = "A"
        case down = "B"
        case right = "C"
        case left = "D"
    }
    
    //cursor related
    ///Gets the current position of the cursor 'ESC[6n'
    case cursorPosition //CSI + "6n"
    ///Moves the cursor to the specified (x, y) location
    case cursorMoveToLocation(Location) //CSI {line};{column}H
    //////Moves the cursor n spaces in a given direction (up, down, left, or right)
    case cursorMove(n: Int, direction: Direction) //CSI # {[A,B,C,D
    ///Moves the cursor to the home position (0, 0)
    case cursorMoveToHome
    
    func rawString() -> String {
        switch self {
        case .cursorPosition:
            return CSI + "6n"
        case .cursorMoveToLocation(let location):
            return CSI + "\(location.y);\(location.x)H"
        case .cursorMove(let n, let direction):
            return CSI + "\(n)" + direction.rawValue
        case .cursorMoveToHome:
            return CSI + "H"
        }
    }

}
