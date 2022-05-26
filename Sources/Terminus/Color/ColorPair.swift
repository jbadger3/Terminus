//
//  Created by Jonathan Badger on 12/30/21.
//

import Foundation

/**
 ColorPairs are used in conjuction with other `Attributes` such as bold or underline to change the appearce of text in the terminal.
 
 The default ColorPair for most terminals is white (foreground) on black (background).  Colors for each ``ColorPair`` can be selected from a ``ColorPalette`` or formed manually using custom `Colors`.
 
 Example
 ````
 import Terminus
 let palette = BasicColorPalette()
 let colorPair = ColorPair(foreground: palette.Green, background: palette.Black)
 let terminal = Terminal.shared
 terminal.write("Hello greeen world", attributes: [.colorPair(colorPair)])
 let key = terminal.getKey()
 ````
 */
public struct ColorPair: Equatable {
    public let foreground: Color
    public let background: Color
    
    public init(foreground: Color, background: Color) {
        self.foreground = foreground
        self.background = background
    }
    
    public static func == (lhs: ColorPair, rhs: ColorPair) -> Bool {
        lhs.foreground == rhs.foreground &&
        lhs.background == rhs.background
    }
}
