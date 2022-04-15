import Foundation


/**
 The starting point for a command line application.


 */
public class Terminal {
    public static let shared = Terminal()
    public private(set) var termios = Termios()
    var standardInput = FileHandle.standardInput
    var standardOutput = FileHandle.standardOutput
    public var inputMode: InputMode
    public var echo: Bool

    init(inputMode: InputMode = .cbreak, echo: Bool = false) {
        termios.setInputMode(inputMode, echo: echo)
        self.inputMode = inputMode
        self.echo = echo
    }


    deinit {
        termios.restoreOriginalSettings()
    }
    
    ///Sets the input mode and echo of the terminal
    public func setInputMode(inputMode: InputMode, echo: Bool = false) {
        termios.setInputMode(inputMode, echo: echo)
    }



    /**
        similar to getch in ncurses
     */
    public func getKey() -> Key? {
        /*
         Using 32 bytes allows for some of the bigger grapheme clusters to be captured...such as 👨‍❤️‍👨 and 👨‍👨‍👧‍👧.  Not sure if this is the best choice, but works for now. Note: Echo mode spits out UTF-8 in 4 byte increments (single code point) to the console (at least in iTerm). */
        if let inputString = self.read(nBytes: 32) {
            return Key(rawValue: inputString)
        }
        return nil
    }

    func write(_ string: inout String, toFileHandle fh: FileHandle) {
        /*There are some issues with writing chunks of data larger than 10-15 bytes to standard output.  They end up garbled in the terminal output.*/
        var str = string
        #if os(macOS)
        Darwin.write(fh.fileDescriptor, &str, str.lengthOfBytes(using: .utf8))
        #elseif os(Linux)
        Glibc.write(fh.fileDescriptor, &str, str.lengthOfBytes(using: .utf8))
        #endif
    }


    func read(nBytes: Int) -> String? {
        /*
         Trying a while loop reading one byte at a time fails...reason unknown.  The loop just stops before reaching the current EOF.  So instead read a given number of bytes
         */
        let bytesP = UnsafeMutableRawPointer.allocate(byteCount: nBytes, alignment: MemoryLayout<UInt8>.alignment).initializeMemory(as: UInt8.self, repeating: 0, count: nBytes)
        
        var bytesRead = 0
       
        #if os(macOS)
        bytesRead = Darwin.read(standardInput.fileDescriptor, bytesP, nBytes)
        #elseif os(Linux)
        bytesRead = Glibc.read(standardInput.fileDescriptor, bytesP, nBytes)
        #endif


        if bytesRead <= 0 {
            return nil
        }
        let bufferPointer = UnsafeRawBufferPointer(start: bytesP, count: bytesRead)
        /* useful for debugging
         for (index, byte) in bufferPointer.enumerated() {
             print("byte \(index): \(byte)")
         }
         */
        return String(bytes: bufferPointer, encoding: .utf8)
    }
    
    public func write(_ string: String, attributes: [Attribute] = []) {
        let attributesStr = attributes.map{$0.stringValue()}.reduce(""){$0 + $1}
        print(attributesStr, terminator: "")
        print(string, terminator: "")
        let resetAttributes = attributes.map{$0.resetValue()}.joined(separator: "")
        print(resetAttributes, terminator: "")
        fflush(stdout)
    }

    public func executeControlSequence(_ controlSequence: ControlSequence) {
        var cs = controlSequence.stringValue()
        write(&cs, toFileHandle: standardOutput)
    }

    public func executeControlSequenceWithResponse(_ controlSequence: ControlSequence) -> String? {
        var cs = controlSequence.stringValue()
        write(&cs, toFileHandle: standardOutput)
        return read(nBytes: 64)
    }
    
    public func softReset() {
        executeControlSequence(ANSIEscapeCode.softReset)
    }
    
    public func screenSize() -> (x: Int, y: Int) {
        guard let resultString = executeControlSequenceWithResponse(ANSIEscapeCode.screenSize) else {return (x:-1, y:-1)}
        let items = resultString.strippingCSI().split(separator: ";").map{$0.trimmingCharacters(in: .letters)}.map{Int($0)}.filter({$0 != nil})
        if items.count == 2,
            let x = items[1],
            let y = items[0] {
            return (x: x, y: y)
        }
        return (x: -1, y: -1)
    }

    public func quit() {
        softReset()
        termios.restoreOriginalSettings()
        exit(0)
    }
}
