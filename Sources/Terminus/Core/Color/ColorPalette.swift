//
//  Created by Jonathan Badger on 1/3/22.
//

import Foundation

/**
 The ColorPalette protocol specifies functions for providing a default color pair and for traversing the colors available in a palette.
 
> Note: `ColorPalette` is used by internally for testing the built-in color palettes, but not required for users interested in making custom color sets or doing somthing more sophisticated with color management.
 */
public protocol ColorPalette {
    ///Returns an array of all color names and colors avaible in the color palette.
    func allColors() -> [(name: String, color: Color)]
    ///Returns the default ``ColorPair`` for the palette.
    func defaultPair() -> ColorPair
}
