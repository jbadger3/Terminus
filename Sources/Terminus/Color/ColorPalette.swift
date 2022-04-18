//
//  Created by Jonathan Badger on 1/3/22.
//

import Foundation

/**
 The ColorPalette protocol provides a simple set of requirements (two functions) for developing custom color palettes.
 
 
 
 interface that is used by the shared ``Colors`` object to manage  terminal program.  Conformance involves writing two functions, allColors() defaultPair().  The allCollors() returns an array of all colors available in the color palette and defaultPair() returns a default ColorPair to use for drawing text.
 */
public protocol ColorPalette {
    ///Returns an array of all colors avaible in the color palette.
    func allColors() -> [Color]
    ///Returns the default ``ColorPair`` for the palette.
    func defaultPair() -> ColorPair
}
