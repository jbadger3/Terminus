import Foundation

//https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#cursor-positioning

///Virtual terminal input keys
public enum KeyCode: String {
    /// ASCII control c (^c)
    case KEY_CONTROL_C = "\u{3}"
    /// ASCII control d (^d) or end of transmission EOT
    case KEY_CONTROL_D = "\u{4}"
    /// ASCII control z (^z)
    case KEY_CONTROL_Z = "\u{1a}"
    /// ASCII BS
    case KEY_BS = "\u{7f}"
    /// ASCII tab (HT)
    case KEY_TAB = "\t"
    /// ASCII Line feed (LF)
    case KEY_LF = "\n"
    /// ASCII carriage return (CR)
    case KEY_CR = "\r"
    /// ASCII escape (ESC)
    case KEY_ESC = "\u{1b}"
    /// ASCII delete (DEL)
    case KEY_DEL = "\u{1b}[~3"
    /// down-arrow key
    case KEY_DOWN = "\u{1b}[B"
    /// up-arrow key
    case KEY_UP = "\u{1b}[A"
    /// left-arrow key
    case KEY_LEFT = "\u{1b}[D"
    /// right-arrow key
    case KEY_RIGHT = "\u{1b}[C"
    /// home key
    case KEY_HOME = "\u{1b}[H"
    /// end key
    case KEY_END = "\u{1b}[F"
    /// F1 key
    case KEY_F1 = "\u{1b}[P"
    /// F2 key
    case KEY_F2 = "\u{1b}[Q"
    /// F3 key
    case KEY_F3 = "\u{1b}[R"
    /// F4 key
    case KEY_F4 = "\u{1b}[S"
    /// F5 key
    case KEY_F5 = "\u{1b}[15~"
    /// F6 key
    case KEY_F6 = "\u{1b}[17~"
    /// F7 key
    case KEY_F7 = "\u{1b}[18~"
    /// F8 key
    case KEY_F8 = "\u{1b}[19~"
    /// F9 key
    case KEY_F9 = "\u{1b}[20~"
    /// F10 key
    case KEY_F10 = "\u{1b}[21~"
    /// F11 key
    case KEY_F11 = "\u{1b}[23~"
    /// F12 key
    case KEY_F12 = "\u{1b}[24~"
    /// page up key
    case KEY_PAGEUP = "\u{1b}[5~"
    /// page down key
    case KEY_PAGEDOWN = "\u{1b}[6~"
}
