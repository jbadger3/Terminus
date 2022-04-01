//  Created by Jonathan Badger on 3/30/22.
//

import Foundation

extension String {
    func strippingCSI() -> String {
        return self.replacingOccurrences(of: CSI, with: "")
    }
}
