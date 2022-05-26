//
//  File.swift
//  
//
//  Created by Jonathan Badger on 4/19/22.
//

import Foundation
@testable import Terminus

class TerminalTests: TestCase {
    var sut: Terminal!
    
    override func setUp() {
        sut = Terminal.shared
    }
    
    override func tearDown() {
        sut = nil
    }
    
    init() {
        super.init(name: "TerminalTests")
        tests = [
        ]
    }
    
    
}
