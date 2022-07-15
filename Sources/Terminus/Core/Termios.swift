//
//  Created by Jonathan Badger on 3/24/22.
//

import Foundation

/*
 Handles setting and restoring terminal behavior on unix based systems using termios.
 */
struct Termios {
    let fd = FileHandle.standardInput.fileDescriptor
    var originalTermios = termios()
    var currentTermios: termios
    
    init() {
        tcgetattr(fd, &originalTermios)
        currentTermios = originalTermios
    }
    
    ///Sets the ``InputMode`` and echoing for the terminal
    mutating func set() {
        #if os(macOS)
        currentTermios.c_lflag &= ~UInt(ICANON | ECHO)
        currentTermios.c_lflag |= UInt(ISIG)

        #elseif os(Linux)
        currentTermios.c_lflag &= ~UInt32(ICANON | ECHO)
        currentTermios.c_lflag |= UInt32(ISIG)

        #endif
        tcsetattr(fd, TCSADRAIN, &currentTermios)
    }

    ///Restores termios to its original settings
    mutating func restoreOriginalSettings() {
        tcsetattr(fd, TCSAFLUSH, &originalTermios)
    }
}



