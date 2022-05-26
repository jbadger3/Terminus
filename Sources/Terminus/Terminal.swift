import Foundation


/**
 The starting point for a command line application.


 */
public class Terminal {
    public static let shared = Terminal()
    private var termios = Termios()
    var standardInput = FileHandle.standardInput
    var standardOutput = FileHandle.standardOutput
    public private(set) var inputMode: InputMode
    public private(set) var echo: Bool
    
    init(inputMode: InputMode = .cbreak, echo: Bool = false) {
        termios.set(inputMode, echo: echo)
        self.inputMode = inputMode
        self.echo = echo
    }

    deinit {
        termios.restoreOriginalSettings()
    }
    
    /**
    Sets the input mode and echo of the terminal.
     
     
     */
    public func set(inputMode: InputMode, echo: Bool = false) {
        termios.set(inputMode, echo: echo)
        self.inputMode = inputMode
        self.echo = echo
    }
    

    /**
     Awaits a keypress from the user and returns the input as `Key`
     */
    public func getKey() -> Key? {
        /*
         Using 32 bytes allows for some of the bigger grapheme clusters to be captured...such as 👨‍❤️‍👨 and 👨‍👨‍👧‍👧.  Not sure if this is the best choice, but works for now. Note: Echo mode spits out UTF-8 in 4 byte increments (single code point) to the console (at least in iTerm), which means multi code point characters get spit out as two or more characters instead. */
        if let inputString = self.read(nBytes: 32) {
            return Key(rawValue: inputString)
        }
        return nil
    }
    
    // internal read function
    func read(nBytes: Int) -> String? {
        /*
         The read function uses the low level system read call and some argue not to use it, but I have yet to get fread, getchar, etc to work properly in a scenario where the number of bytes expected to be in stdin varies or is unknown.
         */
        let bytesP = UnsafeMutableRawPointer.allocate(byteCount: nBytes, alignment: MemoryLayout<UInt8>.alignment).initializeMemory(as: UInt8.self, repeating: 0, count: nBytes)
        
        var bytesRead = 0
       
        #if os(macOS)
        bytesRead = Darwin.read(standardInput.fileDescriptor, bytesP, nBytes)
        #elseif os(Linux)
        bytesRead = Glibc.read(standardInput.fileDescriptor, bytesP, nBytes)
        #elseif os(Windows)
        #endif

        if bytesRead <= 0 {
            return nil
        }
        let bufferPointer = UnsafeRawBufferPointer(start: bytesP, count: bytesRead)
        
        /*
        //useful for debugging
         for (index, byte) in bufferPointer.enumerated() {
             print("byte \(index): \(byte)")
         }
         */
        return String(bytes: bufferPointer, encoding: .utf8)
    }
    
    /**
     Prints output to the terminal with attributes such as text style and color.
     */
    public func write(_ string: String, attributes: [Attribute] = []) {
        let attributesStr = attributes.map{$0.stringValue()}.reduce(""){$0 + $1}
        print(attributesStr, terminator: "")
        print(string, terminator: "")
        executeControlSequence(ANSIEscapeCode.eraseToEndOfLine) //prevents color bug when \n characters are present
        let resetAttributes = attributes.map{$0.resetValue()}.joined(separator: "")
        print(resetAttributes, terminator: "")
        fflush(stdout)
    }

    /**
     Executes a terminal control sequences / ANSI escape code
     */
    public func executeControlSequence(_ controlSequence: ControlSequence) {
        print(controlSequence.stringValue(), terminator: "")
        fflush(stdout)
    }

    /**
     Executes a terminal control sequence where a response is expected.
     
     Example: The control sequence CSI 6n ("\u{1B}[6n ") is used to get the current position of the cursor which is returned as CSI#;#R ("\u{1B}[row;columnR").
     */
    public func executeControlSequenceWithResponse(_ controlSequence: ControlSequence) -> String? {
        print(controlSequence.stringValue(), terminator: "")
        fflush(stdout)
        return read(nBytes: 64)
    }
    
    /**
     Performs a soft terminal resent.
     
     */
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
