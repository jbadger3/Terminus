//  Created by Jonathan Badger on 3/30/22.
//

import Foundation

public extension String {
    ///Removes ESC + "[" from a string
    func strippingCSI() -> String {
        return self.replacingOccurrences(of: CSI, with: "")
    }
}
