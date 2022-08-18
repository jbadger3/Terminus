import Foundation

//https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#cursor-positioning
//VT-100 function keys (PF keys) http://www.braun-home.net/michael/info/misc/VT100_commands.htm

/**
 The type of a pressed key.
 */
public enum KeyType {
    ///A keycode/escape sequence corresponding to one of the navigation keys (arrow, page up/page down, home/end, or insert/delete) on a standard keyboard.
    case navigation(navigationKey: NavigationKey)
    ///Keycodes/escape sequences corresponding to key sequences beginning with the control key.
    case control(controlKey: ControlKey)
    ///Keycodes/escape sequences corresponding to the function keys (F1-F12) on a standard keyboard.
    case function(functionKey: FunctionKey)
    ///One or more characters that are not considered navigation, control, or function keys.
    case character
    
    init(rawValue: String) {
        if let navigationKey = NavigationKey(rawValue: rawValue) {
            self = .navigation(navigationKey: navigationKey)
        } else if let controlKey = ControlKey(rawValue: rawValue) {
            self = .control(controlKey: controlKey)
        } else if let functionKey = FunctionKey(rawValue: rawValue) {
            self = .function(functionKey: functionKey)
        } else {
            self = .character
        }
        
    }
}


/**
 Keycodes/escape sequences corresponding to the navigation keys (arrow, page up/page down, home/end, or insert/delete) on a standard keyboard.
 */
public enum NavigationKey: String, CaseIterable {
    /// down-arrow key
    case down = "\u{1b}[B"
    /// up-arrow key
    case up = "\u{1b}[A"
    /// left-arrow key
    case left = "\u{1b}[D"
    /// right-arrow key
    case right = "\u{1b}[C"
    /// home key
    case home = "\u{1b}[H"
    /// end key
    case end = "\u{1b}[F"
    /// page up key
    case pageUp = "\u{1b}[5~"
    /// page down key
    case pageDown = "\u{1b}[6~"
    ///Unix-like mapped delete (DEL)
    case delete = "\u{1b}[~3"
    ///Insert key
    case insert = "\u{1b}[~2"
}

/**
 Keycodes/escape sequences corresponding to the function keys (F1-F12) on a standard keyboard.
 */
public enum FunctionKey: String, CaseIterable {
    ///VT100 PF1 key
    case PF1 = "\u{1b}OP"
    ///VT100 PF2 key
    case PF2 = "\u{1b}OQ"
    ///VT100 PF3 key
    case PF3 = "\u{1b}OR"
    ///VT100 PF4 key
    case PF4 = "\u{1b}OS"
    /// F1 key
    case F1 = "\u{1b}[P"
    /// F2 key
    case F2 = "\u{1b}[Q"
    /// F3 key
    case F3 = "\u{1b}[R"
    /// F4 key
    case F4 = "\u{1b}[S"
    /// F5 key
    case F5 = "\u{1b}[15~"
    /// F6 key
    case F6 = "\u{1b}[17~"
    /// F7 key
    case F7 = "\u{1b}[18~"
    /// F8 key
    case F8 = "\u{1b}[19~"
    /// F9 key
    case F9 = "\u{1b}[20~"
    /// F10 key
    case F10 = "\u{1b}[21~"
    /// F11 key
    case F11 = "\u{1b}[23~"
    /// F12 key
    case F12 = "\u{1b}[24~"
}

/**
 Keycodes/escape sequences corresponding to key sequences beginning with the control key.
 */
public enum ControlKey: String {
    /// ASCII control c (^c)
    case controlC
    /// ASCII control d (^d) or end of transmission EOT
    case controlD
    /// ASCII control z (^z)
    case controlZ
    case other
    
    public init?(rawValue: String) {
        if rawValue.range(of: #"^\^[A-Za-z]$"#, options: .regularExpression) != nil {
            switch rawValue {
            case "\u{3}":
                self = .controlC
            case "\u{4}":
                self = .controlD
            case "\u{1a}":
                self = .controlZ
            default:
                self = .other
            }
        } else { return nil }
    }
}






