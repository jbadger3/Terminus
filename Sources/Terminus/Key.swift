//
//  Created by Jonathan Badger on 1/5/22.
//
import Foundation

/**
 A key press as returned from the Terminal ``Terminal/getKey()`` function.
 
 Keys are typically captured from the shared terminal and used for downstream procerssing of user input.  For example:
 
 ```swift
 import Terminus
 let terminal = Terminal.shared
 terminal.write("Press enter to break.")
 while true {
    if let key = try? terminal.getKey(),
        key.rawValue == CarriageReturn {
            break
    }
 }
 ```
 
 > Important:  The `rawValue` for a ``Key``  is a ``String`` and may or may not be represented by a single character.  Escaped characters (navigation keys, control keys, etc.) and copy and paste operations have rawValues of varying length.
 

 */
public struct Key {
     /**
      A raw string representation of a keypress as captured from the standard input.
     */
    public let rawValue: String
    /////An optional ``KeyCode`` for special keys (arrow keys, function keys, etc.)
    //public private(set) var keyCode: KeyCode? = nil
   
    
    public init(rawValue: String) {
        self.rawValue = rawValue
        
    }
    
    ///Indicates if the key is one of the arrow keys (up, down, right, or left)
    var isNavigation: Bool {
        return NavigationKey(rawValue: rawValue) != nil
    }
    ///Indicates if the key is one of the functions keys (F1-F12)
    var isFunction: Bool {
        return FunctionKey(rawValue: rawValue) != nil
    }
    
    ///Indicates the key is a control key (control, option, or command)
    var isControl: Bool {
        return ControlKey(rawValue: rawValue) != nil
    }
    
    ///Indicates if the key is a printable character or string of characters
    var isCharacter: Bool {
        if isNavigation || isControl || isFunction {
            return false
        } else {
            return true
        }
    }
}




