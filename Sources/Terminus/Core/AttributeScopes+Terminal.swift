//  Created by Jonathan Badger on 7/7/22.
// Extends AttributedString to accomodate terminal attributes

import Foundation

/**
Allows AttributedStrings to utilize terminal text attributes.
 
 Use .terminalTextAttributes on an `AttributedString` to set attributes.
 ```swift
 var myString = AttributedString("Bold")
 myString.terminalTextAttributes = [.bold]
 ```
 */
public enum TerminalTextAttribute: AttributedStringKey {
    public typealias Value = [Attribute]
    public static let name: String = "TerminalAttributes"
}

public extension AttributeScopes {
    struct Terminal : AttributeScope {
        public let terminalTextAttributes : TerminalTextAttribute
        
    }
    var terminal : Terminal.Type {
        Terminal.self
    }

}

public extension AttributeDynamicLookup {
  subscript<T: AttributedStringKey>(
    dynamicMember keyPath: KeyPath<AttributeScopes.Terminal, T>
  ) -> T {
    self[T.self]
  }
}
