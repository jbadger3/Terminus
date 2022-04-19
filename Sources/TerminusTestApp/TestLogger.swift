//
//  File.swift
//  
//
//  Created by Jonathan Badger on 4/12/22.
//

import Foundation

class TestLogger {
    static var shared = TestLogger()
    var fileHandle: FileHandle?
   
    init() {}
    
    func log(_ message: String) {
        guard let fileHandle = fileHandle else { return }
        if let data = "\(message)\n".data(using: .utf8) {
            try? fileHandle.write(contentsOf: data)
        }
    }
}
