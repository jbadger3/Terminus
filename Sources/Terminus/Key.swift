//
//  Created by Jonathan Badger on 1/5/22.
//
import Foundation

/**
 A key press as returned from the Terminal ``Terminal/getKey()`` function.
 
 The keyCode property can be useful for programs wishing to organize behavior based on specific forms of input (arrow keys, function keys, etc.)
 
 - Parameters:
    - rawValue: A String represeting a key press
 */
public struct Key {
    ///A raw string representation of a keypress as captured from the terminal input representation.
    public let rawValue: String
    ///An optional ``KeyCode`` for special keys (arrow keys, function keys, etc.)
    public private(set) var keyCode: KeyCode? = nil
    
    public init(rawValue: String) {
        self.rawValue = rawValue
        self.keyCode = KeyCode(rawValue: rawValue)
    }
    
    ///Indicates if the key is one of the arrow keys (up, down, right, or left)
    public var isArrowKey: Bool {
        guard let keyCode = keyCode else {
            return false
        }
        let arrowKeys: [KeyCode] = [.KEY_UP, .KEY_DOWN, .KEY_RIGHT, .KEY_LEFT]
        return arrowKeys.contains(keyCode)
    }
    
    ///Indicates if the key is one of the functions keys (F1-F12)
    public var isFunctionKey: Bool {
        guard let keyCode = keyCode else {
            return false
        }
        let functionKeys: [KeyCode] = [.KEY_F1, .KEY_F2, .KEY_F3, .KEY_F4, .KEY_F5,
                                       .KEY_F6, .KEY_F7, .KEY_F8, .KEY_F9, .KEY_F10, .KEY_F11, .KEY_F12]
        return functionKeys.contains(keyCode)
    }
    
    ///Indicates if the is backspace or delete
    public var isBackspaceKey: Bool {
        guard let keyCode = keyCode else {
            return false
        }
        let backSpaceKeys: [KeyCode] = [.KEY_DEL, .KEY_BS]
        return backSpaceKeys.contains(keyCode)
    }
    
    ///Indicates if the key is a printable control key (one of tab, linefeed, or carrage return)
    public var isPrintableControlKey: Bool {
        guard let keyCode = keyCode else { return false }
        let printableKeyCodes: [KeyCode] = [.KEY_TAB, .KEY_LF, .KEY_CR]
        return printableKeyCodes.contains(keyCode)
        
    }
}
