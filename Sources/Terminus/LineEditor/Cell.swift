//
//  File.swift
//  
//
//  Created by Jonathan Badger on 6/17/22.
//

import Foundation

/**
 A generic structure used to store character and attribute information for a cell displayed in the terminal.
 */
public struct Cell {
    ///The character stored in the buffer cell
    public var character: Character
    ///Text attributes for the buffer cell
    public var attributes: [Attribute]
    
    public init(contents: Character =  Character(""), attributes: [Attribute] = []) {
        self.character = contents
        self.attributes = attributes
    }
}

extension Cell: Equatable {
    public static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.character == rhs.character && lhs.attributes == rhs.attributes
    }
    
    
}
