//
//  File.swift
//  
//
//  Created by Jonathan Badger on 12/28/21.
//

import Foundation

///Specifies a location on the terminal screen where x is the line number and y is the column number
public struct Location: Equatable {
    public let x: Int
    public let y: Int
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
