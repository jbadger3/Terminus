//
//  Created by Jonathan Badger on 4/13/22.
//

import Foundation
import Terminus

enum VisualTestError: Error, LocalizedError {
    case inputError(message: String)
    case userDeclaredFailure(message: String)

    var errorDescription: String? {
        switch self {
        case .inputError(let message):
            return "inputError. \(message)"
        case .userDeclaredFailure(let message):
            return "userDeclaredFailure. \(message)"
        }
    }
}
///A simple y/n response function
///
func promptUserForVisualTest(prompt: String, location: Location = Location(x: 0, y: 500)) throws {
    let terminal = Terminal.shared
    let cursor = Cursor()
    //move cursor to display location (defaults to lower left of screen)
    cursor.move(toLocation: location)
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
