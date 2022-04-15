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

    func test_setInputMode_whenEchoTrue_setsTerminalECHOAndECHOEFlagsinCurrentTermiosAndTermianl() {
        startTermios.c_lflag &= ~FlagInt(ECHO | ECHOE)
        tcsetattr(fd, TCSANOW, &startTermios)
        sut = Termios()
        //Check bitwise to make sure ECHO and ECHOE are off
        XCTAssertTrue(lflagBitsOff(flags: [ECHO, ECHOE], termiosStruct: sut.currentTermios))

        sut.set(.cbreak, echo: true)
        XCTAssertTrue(lflagBitsOn(flags: [ECHO, ECHOE], termiosStruct: sut.currentTermios))

        var terminalTermios = termios()
        tcgetattr(fd, &terminalTermios)
        XCTAssertTrue(lflagBitsOn(flags: [ECHO, ECHO], termiosStruct: terminalTermios))
    }

    func test_setInputMode_whenModeRaw_turnsOffICANONAndISIGInTerminal() {
        startTermios.c_lflag &= ~FlagInt(ICANON | SIGINT)
        tcsetattr(fd, TCSANOW, &startTermios)
        sut = Termios()
        XCTAssertTrue(lflagBitsOff(flags: [ICANON, SIGINT], termiosStruct: sut.currentTermios))

        sut.set(.raw, echo: false)

        XCTAssertTrue(lflagBitsOff(flags: [ICANON, SIGINT], termiosStruct: sut.currentTermios))
        tcgetattr(fd, &startTermios)
        XCTAssertTrue(lflagBitsOff(flags: [ICANON, SIGINT], termiosStruct: startTermios))
    }

    func test_setInputMode_whenCBreak_turnsOFFICANONAndTurnsONISIGInTerminal() {
        startTermios.c_lflag |= FlagInt(ICANON)
        startTermios.c_lflag &= ~FlagInt(ISIG)
        tcsetattr(fd, TCSANOW, &startTermios)
        sut = Termios()
        XCTAssertTrue(lflagBitsOn(flags: [ICANON], termiosStruct: sut.currentTermios))
        XCTAssertTrue(lflagBitsOff(flags: [ISIG], termiosStruct: sut.currentTermios))

        sut.set(.cbreak, echo: false)

        tcgetattr(fd, &startTermios)
        XCTAssertTrue(lflagBitsOff(flags: [ICANON], termiosStruct: startTermios))
        XCTAssertTrue(lflagBitsOn(flags: [ISIG], termiosStruct: startTermios))
    }

    func test_setInputMode_whenLineEditing_turnsOnICANONAndISIGInTerminal() {
        startTermios.c_lflag &= ~FlagInt(ICANON | ISIG)
        tcsetattr(fd, TCSANOW, &startTermios)
        sut = Termios()
        XCTAssertTrue(lflagBitsOff(flags: [ICANON, ISIG], termiosStruct: sut.currentTermios))

        sut.set(.lineEditing, echo: false)

        tcgetattr(fd, &startTermios)
        XCTAssertTrue(lflagBitsOn(flags: [ICANON, ISIG], termiosStruct: startTermios))
    }

    func test_restoreOriginalSettings_givenAlteredLFlags_returnsTerminalToOriginalSettings() throws {
        XCTAssertEqual(sut.originalTermios.c_lflag, startTermios.c_lflag)

        var termiosCopy = startTermios!

        termiosCopy.c_lflag = 9
        tcsetattr(fd, TCSANOW, &termiosCopy)
        tcgetattr(STDIN_FILENO, &termiosCopy)

        XCTAssertNotEqual(sut.originalTermios.c_lflag, termiosCopy.c_lflag)

        sut.restoreOriginalSettings()

        tcgetattr(fd, &startTermios)
        XCTAssertEqual(sut.originalTermios.c_lflag, startTermios.c_lflag)
    }
}
