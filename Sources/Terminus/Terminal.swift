import Foundation


/**
 The starting point for a command line application.


 */
public class Terminal {
    public static let shared = Terminal()
    public private(set) var termios = Termios()
    var standardInput = FileHandle.standardInput
    var standardOutput = FileHandle.standardOutput

    init(inputMode: InputMode = .cbreak, echo: Bool = false) {
        termios.setInputMode(inputMode, echo: echo)
    }


    deinit {
        termios.restoreOriginalSettings()
    }
    
    ///Sets the input mode and echo of the terminal
    public func setInputMode(inputMode: InputMode, echo: Bool = false) {
        termios.setInputMode(inputMode, echo: echo)
    }



    /**

     */
    public func getch() -> Key? {
        /*
         Using 32 bytes allows for some of the bigger grapheme clusters to be captured...such as 👨‍❤️‍👨 and 👨‍👨‍👧‍👧.  Not sure if this is the best choice, but works for now. Note: Echo mode spits out UTF-8 in 4 byte increments (single code point) to the console (at least in iTerm). */
        if let inputString = self.read(nBytes: 32) {
            return Key(rawValue: inputString)
        }
        return nil
    }

    func write(_ string: inout String, to fh: FileHandle) {
        #if os(macOS)
        Darwin.write(fh.fileDescriptor, &string, string.lengthOfBytes(using: .utf8))
        #elseif os(Linux)
        Glibc.write(fh.fileDescriptor, &string, string.lengthOfBytes(using: .utf8))
        #endif
    }


    func read(nBytes: Int) -> String? {
        /*
         Trying a while loop reading one byte at a time fails...reason unknown.  The loop just stops.  So instead read a given number of bytes
         */
        let bytesP = UnsafeMutableRawPointer.allocate(byteCount: 64, alignment: MemoryLayout<UInt8>.alignment).initializeMemory(as: UInt8.self, repeating: 0, count: nBytes)
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
    public func print(_ string: String, attributes: [Attribute] = []) {
        var str = attributes.map{$0.stringValue()}.reduce(""){$0 + $1} + string
        write(&str, to: standardOutput)
        var resetAttributes = attributes.map{$0.resetValue()}.joined(separator: "")
        write(&resetAttributes, to: standardOutput)
    }

    public func executeControlSequence(_ controlSequence: ControlSequence) {
        var cs = controlSequence.stringValue()
        write(&cs, to: standardOutput)
    }

    public func executeControlSequenceWithResponse(_ controlSequence: ControlSequence) -> String? {
        var cs = controlSequence.stringValue()
        write(&cs, to: standardOutput)
        return read(nBytes: 64)
    }


    public func quit() {
        termios.restoreOriginalSettings()
        exit(0)
    }
}
