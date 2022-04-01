//
//  Created by Jonathan Badger on 1/5/22.
//
import Foundation


public struct Key {
    public enum KeyType {
        case controlKey
        case characterKey
        case mouseEvent
        case resizeEvent
        case negKey
    }
    
    public let rawValue: String
    public private(set) var keyCode: KeyCode? = nil
    public private(set) var type: KeyType = .characterKey
    
    public init(rawValue: String) {
        self.rawValue = rawValue
        /*
        if rawValue.lengthOfBytes(using: .utf8) == 1 {
            let intVal = Int(rawValue.utf8[rawValue.startIndex])
            if let keyCode = KeyCode(rawValue: intVal) {
                self.keyCode = keyCode
                switch keyCode {
                case .KEY_MOUSE:
                    self.type = .mouseEvent
                case .KEY_RESIZE:
                    self.type = .resizeEvent
                default:
                    self.type = .controlKey
                }
            }
        }
         */
    }
    /*
    public var isArrowKey: Bool {
        guard let keyCode = keyCode else {
            return false
        }
        let arrowKeys: [KeyCode] = [.KEY_UP, .KEY_DOWN, .KEY_RIGHT, .KEY_LEFT]
        return arrowKeys.contains(keyCode)
    }
    
    public var isFunctionKey: Bool {
        guard let keyCode = keyCode else {
            return false
        }
        let functionKeys: [KeyCode] = [.KEY_F0, .KEY_F1, .KEY_F2, .KEY_F3, .KEY_F4, .KEY_F5,
                                       .KEY_F6, .KEY_F7, .KEY_F8, .KEY_F9, .KEY_F10, .KEY_F11, .KEY_F12]
        return functionKeys.contains(keyCode)
    }
    
    public var isBackspaceKey: Bool {
        guard let keyCode = keyCode else {
            return false
        }
        let backSpaceKeys: [KeyCode] = [.KEY_DEL, .KEY_BS, .KEY_BACKSPACE]
        return backSpaceKeys.contains(keyCode)
    }
    
    public var isPrintableControlKey: Bool {
        guard let keyCode = keyCode else { return false }
        let printableKeyCodes: [KeyCode] = [.KEY_TAB, .KEY_LF, .KEY_CR, .KEY_ENTER]
        return printableKeyCodes.contains(keyCode)
        
    }
     */
    

}
