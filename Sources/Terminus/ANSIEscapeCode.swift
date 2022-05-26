//  Created by Jonathan Badger on 3/23/22.
// gist of ANSI escape sequences https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
// Windows Consol Vertual Terminal Sequences https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
// XTerm Control Sequences https://invisible-island.net/xterm/ctlseqs/ctlseqs.html

import Foundation

public let BEL = "\u{7}"
public let ESC = "\u{1B}" // Escape character (27 or 1B)
public let CSI = ESC + "[" // Control Sequence Introducer (CSI  is 0x9b).
public let DCS = ESC + "P" // Device Control String (DCS  is 0x90).
public let OSC = ESC + "]" // Operating System Command (OSC  is 0x9d).
//public let ST = ESC + "\\" // String Terminator (ST  is 0x9c).
//public let DLE = "\u{10}" // Data link escape DLE

///A string corresponding to an ANSI Escape Code
public protocol ControlSequence {
    func stringValue() -> String
}

///Terminal Control Sequences (ANSI Escape Codes)
public enum ANSIEscapeCode: Equatable, ControlSequence {
    /**
    Arrow key designations
     */
    public enum Direction: String {
        case up = "A"
        case down = "B"
        case right = "C"
        case left = "D"
    }
    
    /**
    Cursor styles (check your terminal emulator for supported styles)
     */
    public enum Style: Int {
        case blinking_block
        case blinking_block_default
        case steady_block
        case blinking_underline
        case steady_underline
        case blinking_bar // xterm.
        case steady_bar // xterm.
    }
    
    //terminal related
    ///Device attributes
    case deviceAtributes //CSI + "0c"
    ///Performs a 'soft' terminal reset
    case softReset //CSI + "!p"
    ///Reports the size of the text area in characters
    case textAreaSize //CSI + "18t"
    ///Reports the size of the screen in characters
    case screenSize //CSI + "19t"
    ///Sets the terminal character set
    case designateCharacterSet(String)
    ///Uses the alternate screen buffer
    case useAlternateScreenBuffer
    ///Uses the main screen buffer
    case useMainScreenBuffer
    
    //cursor related
    ///Gets the current position of the cursor
    case cursorPosition //CSI + "6n"
    ///Moves the cursor to the specified (x, y) location
    case cursorMoveToLocation(Location) //CSI + "{line};{column}H"
    ///Moves the cursor `n` spaces in a given direction (up, down, left, or right)
    case cursorMove(n: Int, direction: Direction) //CSI + "{n} {[A,B,C,D]}"
    ///Moves the cursor to the home position (1, 1)
    case cursorMoveToHome //CSI + "H"
    ///chages cursor visibility
    case cursorVisible(Bool) //CSI + "?25h" or "?25l"
    ///sets the cursor style
    case cursorStyle(style: Style) //CSI + "{style} q"
    ///Saves the current cursor position
    case cursorSave //CSI + "7"
    ///Moves the cursor to the last saved cursor potion
    case cursorRestore //CSI + "8"
    
    //erase functions
    ///Erase from the cursor until end of screen
    case eraseToEndOfScreen //CSI + "0J"
    ///Erase from the cursor to beginning of screen
    case eraseToBeginningOfScreen //CSI + "1J"
    ///Erase the entire screen
    case eraseScreen //CSI + "2J"
    //ESC[3J    erase saved lines
    ///Erase from the cursor to end of the line
    case eraseToEndOfLine //CSI + "0K"
    ///Erase start of line to the cursor
    case eraseStartOfLine //CSI + "1K"
    ///Erase the entire line
    case eraseLine //CSI + "2K"
    
    //Color functions
    ///Sets the text color using the color table of the terminal
    case colorSetForeground(index: Int) //CSI + "38;5;{index}m"
    ///Sets the background color using the color table of the terminal
    case colorSetBackground(index: Int) //CSI + "48;5;{index}m"
    ///Sets the foreground color using r, g, b values
    case colorSetForegroundRGB(r: Int, g: Int, b: Int) //CSI + "38;2;{r};{g};{b}m"
    ///Sets the background color using r, g, b values
    case colorSetBackgroundRGB(r: Int, g: Int, b: Int) //CSI + "48;2;{r};{g};{b}m"
    
    public static func +(lhs: ANSIEscapeCode, rhs: ANSIEscapeCode) -> String {
        lhs.stringValue() + rhs.stringValue()
    }
    public static func ==(lhs: ANSIEscapeCode, rhs: ANSIEscapeCode) -> Bool {
        return lhs.stringValue() == rhs.stringValue()
    }
    
    ///The string representation of an ANSI escape code
    public func stringValue() -> String {
        switch self {
        //terminal related
        case .deviceAtributes:
            return CSI + "0c"
        case .softReset:
            return CSI + "!p"
        case .textAreaSize:
            return CSI + "18t"
        case .screenSize:
            return CSI + "19t"
        case .designateCharacterSet(let characterSet):
            return ESC + "(\(characterSet)"
        case .useAlternateScreenBuffer:
            return CSI + "?1049h"
        case .useMainScreenBuffer:
            return CSI + "?1049l"
        //cursor related
        case .cursorPosition:
            return CSI + "6n"
        case .cursorMoveToLocation(let location):
            return CSI + "\(location.y);\(location.x)H"
        case .cursorMove(let n, let direction):
            return CSI + "\(n)" + direction.rawValue
        case .cursorMoveToHome:
            return CSI + "H"
        case .cursorVisible(let isVisible):
            if isVisible {
                return CSI + "?25h"
            } else {
                return CSI + "?25l"
            }
        case .cursorStyle(let style):
            return CSI + "\(style.rawValue) q"
        case .cursorSave:
            return ESC + "7"
        case .cursorRestore:
            return ESC + "8"
        case .eraseToEndOfScreen:
            return CSI + "0J"
        case .eraseToBeginningOfScreen:
            return CSI + "1J"
        case .eraseScreen:
            return CSI + "2J"
        case .eraseToEndOfLine:
            return CSI + "0K"
        case .eraseStartOfLine:
            return CSI + "1K"
        case .eraseLine:
            return CSI + "2K"
        case .colorSetForeground(let index):
            return CSI + "38;5;\(index)m"
        case .colorSetBackground(let index):
            return CSI + "48;5;\(index)m"
        case .colorSetForegroundRGB(let r, let g, let b):
            return CSI + "38;2;\(r);\(g);\(b)m"
        case .colorSetBackgroundRGB(let r, let g, let b):
            return CSI + "48;2;\(r);\(g);\(b)m"
            
        }
    }
}
