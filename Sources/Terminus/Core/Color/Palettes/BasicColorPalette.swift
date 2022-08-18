//  Created by Jonathan Badger on 1/3/22.
//

import Foundation

/**
 The BasicColorPalette contains the 8 colors originally specified in ncurses.  Users interested more variety should use the ``X11WebPalette`` or ``XTermPalette``.
 */
public struct BasicColorPalette: ColorPalette {
    public let Black = Color(r: 0, g: 0, b: 0)
    public let Red = Color(r: 173, g: 0, b: 0)
    public let Green = Color(r: 0, g: 173, b: 0)
    public let Yellow = Color(r: 173, g: 173, b: 0)
    public let Blue = Color(r: 0, g: 0, b: 173)
    public let Magenta = Color(r: 173, g: 0, b: 173)
    public let Cyan = Color(r: 0, g: 173, b: 173)
    public let White = Color(r: 173, g: 173, b: 173)
    
    public init() {}
    
    public func allColors() -> [(name: String, color: Color)]  {
        var colors: [(String, Color)] = []
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let color = child.value as? Color,
               let name = child.label  {
                colors.append((name, color))
            }
        }
        return colors
    }
    ///White text on a black background
    public func defaultPair() -> ColorPair {
        return ColorPair(foreground: BasicColorPalette().White, background: BasicColorPalette().Black)
    }
}
