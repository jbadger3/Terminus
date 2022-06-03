//  Created by Jonathan Badger on 4/11/22.
//

import Foundation

typealias TestFunction = () throws -> Void
typealias TestName = String
struct Test {
    var name: String
    var testFunction: TestFunction
    var interactive: Bool = false
}


class TestCase {
    var name: String
    var tests: [Test] = []
    init(name: String) {
        self.name = name
    }
    
    func setUp() {}
    func tearDown() {}
    
    func runTests(skipInteractive: Bool = false) {
        let testLogger = TestLogger.shared
        testLogger.log(name)
        if skipInteractive {
            tests = tests.filter({!$0.interactive})
        }
        for test in tests {
            run(test: test)
        }
    }
    
    func run(test: Test) {
        let testLogger = TestLogger.shared
        setUp()
        do {
            testLogger.log(test.name)
            try test.testFunction()
            
        } catch {
            testLogger.log("failed with error.\n\(error.localizedDescription)")
        }
        tearDown()
    }

    
}



