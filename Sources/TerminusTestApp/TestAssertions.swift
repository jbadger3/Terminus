//  Created by Jonathan Badger on 4/13/22.
//

import Foundation

//Functions that mimick the XCTest API


func TAssertTrue(_ expression: Bool, line: UInt = #line) {
    if expression != true {
        let testLogger = TestLogger.shared
        testLogger.log("Line: \(line).  Assert true failed.")
    }
}

func TAssertFalse(_ expression: Bool, line: UInt = #line) {
    if expression != false {
        let testLogger = TestLogger.shared
        testLogger.log("Line: \(line).  Assert false failed.")
    }
}


func TAssertEqual<T>(_ expression1: T,_ expression2: T, line: UInt = #line) where T: Equatable  {
    if expression1 != expression2 {
        let testLogger = TestLogger.shared
        testLogger.log("Line: \(line).  Assert equal failed. \(expression1) not equal to \(expression2).")
    }
}

func TAssertNotEqual<T>(_ expression1: T, _ expression2: T, line: UInt = #line) where T: Equatable {
    if expression1 == expression2 {
        let testLogger = TestLogger.shared
        testLogger.log("Line: \(line).  Assert not equal failed. \(expression1) equals \(expression2).")
    }
}

func TAssertNil<T>(_ argument: T?, line: UInt = #line) {
    if argument != nil {
        let testLogger = TestLogger.shared
        testLogger.log("Line: \(line).  Assert Nil failed. \(String(describing: argument))")
    }
}

func TAssertNotNil<T>(_ argument: T?, line: UInt = #line) {
    if argument == nil {
        let testLogger = TestLogger.shared
        testLogger.log("Line: \(line).  Assert Not Nil failed. \(String(describing: argument))")
    }
}
 
