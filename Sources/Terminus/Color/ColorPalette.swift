//
//  Created by Jonathan Badger on 1/3/22.
//

import Foundation

/**
 The ColorPalette protocol provides a simple set of requirements (two functions) for developing custom color palettes.
 */
public protocol ColorPalette {
    ///Returns an array of all color names and colors avaible in the color palette.
    func allColors() -> [(name: String, color: Color)]
    ///Returns the default ``ColorPair`` for the palette.
    func defaultPair() -> ColorPair
}
