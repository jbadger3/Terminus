//
//  Created by Jonathan Badger on 3/24/22.
//

import Foundation


/**
 Handles setting and restoring terminal behavior on unix based systems.
 */
public struct Termios {
    let fd = FileHandle.standardInput.fileDescriptor
    var originalTermios = termios()
    var currentTermios: termios
    
    init() {
        tcgetattr(fd, &originalTermios)
        currentTermios = originalTermios
    }
    
    mutating func setInputMode(_ inputMode: InputMode, echo: Bool) {
        switch inputMode {
        case .raw:
            currentTermios.c_lflag &= ~UInt(ICANON | ISIG)
        case .cbreak:
            currentTermios.c_lflag &= ~UInt(ICANON)
            currentTermios.c_lflag |= UInt(ISIG)
        case .lineEditing:
            currentTermios.c_lflag |= UInt(ICANON | ISIG)
        }
        if echo {
            currentTermios.c_lflag |= UInt(ECHO | ECHOE)
        } else {
            currentTermios.c_lflag &= ~UInt(ECHO)

        }
        tcsetattr(fd, TCSADRAIN, &currentTermios)
    }

    
    mutating func restoreOriginalSettings() {
        tcsetattr(fd, TCSAFLUSH, &originalTermios)
    }
}



