//
//  File.swift
//  
//
//  Created by Jonathan Badger on 12/29/21.
//

import Foundation

/**
 Terminal input modes
 */
public enum InputMode {
    /// Makes all keypresses immediately available.
    case raw
    /// Makes keypresses immediately available for processing except ctrl-c and ctrl-z are passed to the terminal driver for program control
    case cbreak
    /** The results of input are buffered until a newline or carrage return.  This is normally the default terminal mode, sometimes refereed to as 'cooked' mode.
    */
    case lineEditing
}
