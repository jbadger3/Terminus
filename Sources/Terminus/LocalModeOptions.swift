//
//  Created by Jonathan Badger on 3/24/22.
//

import Foundation


/*
 Used to set the the input mode of the ``Terminal``
 
 Local mode options correspond to a small subset of options available in the c_lflag property of the termios structure. (See man termios for more info)
 */
public struct LocalModeOptions: OptionSet {
    public var rawValue: UInt32
    public static let lineEditing = LocalModeOptions(rawValue: UInt32(ICANON))
    public static let echo = LocalModeOptions(rawValue: UInt32(ECHO))
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
}
