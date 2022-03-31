//  Created by Jonathan Badger on 3/24/22.
//
import Foundation
import XCTest

@testable import Terminus

final class TermiosTests: XCTestCase {
    let fd = FileHandle.standardInput.fileDescriptor
    var sut: Termios!
    var startTermios: termios!
    
    override func setUpWithError() throws {
        sut = Termios()
        startTermios = termios()
        tcgetattr(fd, &startTermios)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        startTermios = nil
    }
    
    //MARK: Helpers
    func lflagBitsOn(flags: [Int32], termiosStruct termios: termios) -> Bool {
        let uIntFlags = flags.map{UInt($0)}
        return termios.c_lflag & (uIntFlags.reduce(0){a,b in a | b}) == uIntFlags.reduce(0){a,b in a | b}
    }
    func lflagBitsOff(flags: [Int32], termiosStruct termios: termios) -> Bool {
        let uIntFlags = flags.map{UInt($0)}
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
        startTermios.c_lflag &= ~UInt(ECHO | ECHOE)
        tcsetattr(fd, TCSANOW, &startTermios)
        sut = Termios()
        //Check bitwise to make sure ECHO and ECHOE are off
        XCTAssertTrue(lflagBitsOff(flags: [ECHO, ECHOE], termiosStruct: sut.currentTermios))
        
        sut.setInputMode(.cbreak, echo: true)
        XCTAssertTrue(lflagBitsOn(flags: [ECHO, ECHOE], termiosStruct: sut.currentTermios))
   
        var terminalTermios = termios()
        tcgetattr(fd, &terminalTermios)
        XCTAssertTrue(lflagBitsOn(flags: [ECHO, ECHO], termiosStruct: terminalTermios))
    }
    
    func test_setInputMode_whenModeRaw_turnsOffICANONAndISIGInTerminal() {
        startTermios.c_lflag &= ~UInt(ICANON | SIGINT)
        tcsetattr(fd, TCSANOW, &startTermios)
        sut = Termios()
        XCTAssertTrue(lflagBitsOff(flags: [ICANON, SIGINT], termiosStruct: sut.currentTermios))
        
        sut.setInputMode(.raw, echo: false)
        
        XCTAssertTrue(lflagBitsOff(flags: [ICANON, SIGINT], termiosStruct: sut.currentTermios))
        tcgetattr(fd, &startTermios)
        XCTAssertTrue(lflagBitsOff(flags: [ICANON, SIGINT], termiosStruct: startTermios))
    }
    
    func test_setInputMode_whenCBreak_turnsOFFICANONAndTurnsONISIGInTerminal() {
        startTermios.c_lflag |= UInt(ICANON)
        startTermios.c_lflag &= ~UInt(ISIG)
        tcsetattr(fd, TCSANOW, &startTermios)
        sut = Termios()
        XCTAssertTrue(lflagBitsOn(flags: [ICANON], termiosStruct: sut.currentTermios))
        XCTAssertTrue(lflagBitsOff(flags: [ISIG], termiosStruct: sut.currentTermios))
        
        sut.setInputMode(.cbreak, echo: false)
        
        tcgetattr(fd, &startTermios)
        XCTAssertTrue(lflagBitsOff(flags: [ICANON], termiosStruct: startTermios))
        XCTAssertTrue(lflagBitsOn(flags: [ISIG], termiosStruct: startTermios))
    }
    
    func test_setInputMode_whenLineEditing_turnsOnICANONAndISIGInTerminal() {
        startTermios.c_lflag &= ~UInt(ICANON | ISIG)
        tcsetattr(fd, TCSANOW, &startTermios)
        sut = Termios()
        XCTAssertTrue(lflagBitsOff(flags: [ICANON, ISIG], termiosStruct: sut.currentTermios))
        
        sut.setInputMode(.lineEditing, echo: false)
        
        tcgetattr(fd, &startTermios)
        XCTAssertTrue(lflagBitsOn(flags: [ICANON, ISIG], termiosStruct: startTermios))
    }
    
    func test_restoreOriginalSettings_givenAlteredLFlags_returnsTerminalToOriginalSettings() throws {
        XCTAssertEqual(sut.originalTermios.c_lflag, startTermios.c_lflag)
        var termiosCopy = startTermios!
        termiosCopy.c_lflag = ~UInt(0)
        tcsetattr(fd, TCSANOW, &termiosCopy)
        tcgetattr(fd, &startTermios)
        XCTAssertNotEqual(sut.originalTermios.c_lflag, startTermios.c_lflag)
        
        sut.restoreOriginalSettings()
        
        tcgetattr(fd, &startTermios)
        XCTAssertEqual(sut.originalTermios.c_lflag, startTermios.c_lflag)
    }
}

