//
//  File.swift
//  
//
//  Created by Jonathan Badger on 12/28/21.
//

import Foundation

///Specifies a location on the terminal screen where x is the line number and y is the column number.  The origin for the terminal is (1, 1) and corresponds to the upper left corner of the screen.
public struct Location: Equatable {
    public let x: Int
    public let y: Int
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

extension Location: Comparable {
    public static func < (lhs: Location, rhs: Location) -> Bool {
        if lhs.y != rhs.y {
            return lhs.y < rhs.y
        } else {
            return lhs.x < rhs.x
        }
    }
}




