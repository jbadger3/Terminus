//
//  Created by Jonathan Badger on 6/7/22.
//

import Foundation


struct Table {
    typealias TableData = [[String]]
    var location: Location
    var data: TableData
    var numRows: Int {
        return data.count
    }
    var numColumns: Int {
        return data[0].count
    }
    
    init(data: TableData, colNames location: Location?) {
        if let location = location {
            self.location = location
        } else {
            let cursor = Cursor()
            self.location = cursor.location ?? Location(x: -1, y: -1)
        }
        self.data = data
    }
    
}
