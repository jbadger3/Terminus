//
//  Created by Jonathan Badger on 4/13/22.
//

import Foundation
import Terminus

enum VisualTestError: Error {
    case inputError(message: String)
    case userDeclaredFailure(message: String)
}
///A simple y/n response function
///
func promptUserForVisualTest(prompt: String) throws {
    let terminal = Terminal.shared
    let cursor = Cursor()
    //move cursor to lower left of screen
    cursor.move(toLocation: Location(x: 0, y: 500))
    terminal.executeControlSequence(ANSIEscapeCode.eraseLine)
    terminal.write("\(prompt) (y/n): ")
    if let key = terminal.getKey() {
        if key.rawValue == "y" || key.rawValue == "Y" {
            terminal.write(key.rawValue)
            return
        }
        if key.rawValue == "n" || key.rawValue == "N" {
            terminal.write(key.rawValue)
            throw VisualTestError.userDeclaredFailure(message: "User indicated failur.")
        }
        throw VisualTestError.inputError(message: "Input was something other than 'y' or 'n'")
    }
    throw VisualTestError.inputError(message: "Failed to capture user input.")
}
