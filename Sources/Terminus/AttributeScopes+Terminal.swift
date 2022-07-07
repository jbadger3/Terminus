//  Created by Jonathan Badger on 7/7/22.
//

import Foundation

public enum TerminalTextAttribute: AttributedStringKey {
    public typealias Value = [Attribute]
    public static let name: String = "TerminalAttributes"
}

public extension AttributeScopes {
    struct Terminal : AttributeScope {
        let terminalTextAttributes : TerminalTextAttribute
        
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
