//  Created by Jonathan Badger on 3/24/22.
//
import Foundation
import XCTest

@testable import Terminus

#if os(Linux)
typealias FlagInt = UInt32
#else
typealias FlagInt = UInt
#endif

public final class TermiosTests: XCTestCase {
    let fd = FileHandle.standardInput.fileDescriptor
    var sut: Termios!
    var startTermios: termios!

    public override func setUpWithError() throws {
        sut = Termios()
        startTermios = termios()
        tcgetattr(fd, &startTermios)
    }

    public override func tearDownWithError() throws {
        sut = nil
        startTermios = nil
    }

    //MARK: Helpers
    func lflagBitsOn(flags: [Int32], termiosStruct termios: termios) -> Bool {
        let uIntFlags = flags.map{FlagInt($0)}
        return termios.c_lflag & (uIntFlags.reduce(0){a,b in a | b}) == uIntFlags.reduce(0){a,b in a | b}
    }
    func lflagBitsOff(flags: [Int32], termiosStruct termios: termios) -> Bool {
        let uIntFlags = flags.map{FlagInt($0)}
        return termios.c_lflag & (uIntFlags.reduce(0){a,b in a | b}) == 0
    }

    //MARK: Tests
    func test_init_populatesOriginalTermiosWthCurrentSettings() {
        XCTAssertEqual(sut.originalTermios.c_lflag, startTermios.c_lflag)
        XCTAssertEqual(sut.originalTermios.c_oflag, startTermios.c_oflag)
        XCTAssertEqual(sut.originalTermios.c_cflag, startTermios.c_cflag)
        XCTAssertEqual(sut.originalTermios.c_lflag, startTermios.c_lflag)
    }
    
    func test_set_turnsCanonicalAndEchoOffAndTurnsISIGOne() {
        startTermios.c_lflag = ~UInt(ISIG)
        startTermios.c_lflag |= UInt(ICANON | ECHO)

        tcsetattr(fd, TCSANOW, &startTermios)
        sut = Termios()
        XCTAssertTrue(lflagBitsOn(flags: [ICANON, ECHO], termiosStruct: startTermios))
        XCTAssertTrue(lflagBitsOff(flags: [ISIG], termiosStruct: startTermios))
        
        sut.set()
        var terminalTermios = termios()
        tcgetattr(fd, &terminalTermios)
        XCTAssertTrue(lflagBitsOn(flags: [ISIG], termiosStruct: terminalTermios))
        XCTAssertTrue(lflagBitsOff(flags: [ICANON, ECHO], termiosStruct: terminalTermios))
        
    }

}
