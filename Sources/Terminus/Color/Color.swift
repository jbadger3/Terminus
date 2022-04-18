//
//  Created by Jonathan Badger on 1/4/22.
//

import Foundation

/**
 
 */
public struct Color: Equatable, Hashable {
    ///Red intensity  0...255
    public let r: Int
    ///Green intensity 0...255
    public let g: Int
    ///Blue Intensity 0...255
    public let b: Int

    public init(r: Int, g: Int, b: Int) {
        self.r = r
        self.g = g
        self.b = b
    }
}
