import Foundation

/**
 The starting point and primary means of interaction for a command line application.
 */
public class Terminal {
    ///The shared singleton Terminal object.
    public static let shared = Terminal()
    ///The cursor associated with the terminal
    public let cursor = Cursor()
    private var termios = Termios()
    var standardInput = FileHandle.standardInput
    var standardOutput = FileHandle.standardOutput

    
    init() {
        termios.set()
    }

    deinit {
        termios.restoreOriginalSettings()
    }
    
    public func set(attributes: [Attribute]) {
        let attributeString = attributes.map({$0.csString()}).joined(separator: "")
        print(attributeString, terminator: "")
        fflush(stdout)
    }
    
    public func reset(attributes: [Attribute]) {
        let attributeString = attributes.map({$0.resetValue()}).joined(separator: "")
        print(attributeString, terminator: "")
        fflush(stdout)
    }
    
    /**
     Awaits a keypress from the user and returns the input as ``Key``
     */
    public func getKey() throws ->  Key {
        /*
         Using at least 32 bytes allows for some of the bigger grapheme clusters to be captured...such as 👨‍❤️‍👨 and 👨‍👨‍👧‍👧.  Not sure if this is the best choice, but works for now. Note: Echo mode spits out UTF-8 in 4 byte increments (single code point) to the console (at least in iTerm), which means multi code point characters get spit out as two or more characters instead.
         To capture all text from the input buffer in the case of copy/pase operations nBytes is set to 1MB (1048576 bytes)
         */
        
        let inputString = try self.read(nBytes: 1048576)
        return Key(rawValue: inputString)
    }
    
    /**
        Awaits a press of the return key from the user and returns the captured input.
     */
    public func getLine() -> String {
        return LineEditor().getInput()
    }
    
    // internal read function
    func read(nBytes: Int) throws -> String {
        /*
         The read function uses the low level system read call.  Attempts with fread, getchar, etc fail to work properly in a scenario where the number of bytes expected to be in stdin varies or is unknown.
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
            throw TerminalError.zeroByteSystemRead
        }
        let bufferPointer = UnsafeRawBufferPointer(start: bytesP, count: bytesRead)
        
        guard let str = String(bytes: bufferPointer, encoding: .utf8) else {
            throw TerminalError.stringDecodingInSystemReadFailed
        }
        
        /*
        //useful for debugging
         for (index, byte) in bufferPointer.enumerated() {
             print("byte \(index): \(byte)")
         }
         */
        return str
    }
    
    /**
     Prints output to the terminal with attributes such as text style and color.
     */
    public func write(_ string: String, attributes: [Attribute] = []) {
        let attributesStr = attributes.map{$0.csString()}.reduce(""){$0 + $1}
        print(attributesStr + string, terminator: "")
        let resetAttributes = attributes.map{$0.resetValue()}.joined(separator: "")
        print(resetAttributes, terminator: "")
        fflush(stdout)
    }
    
    /**
     Prints an AttributedString to the terminal that can include text styling and coloring.
     */
    public func write(attributedString: AttributedString) {
        for run in attributedString.runs {
            let subString = String(attributedString[run.range].characters)
            let attributes = run.terminalTextAttributes ?? []
            write(subString, attributes: attributes)
        }
    }

    /**
     Executes a terminal control sequences / ANSI escape code
     */
    public func executeControlSequence(_ controlSequence: ControlSequenceEmitting) {
        print(controlSequence.csString(), terminator: "")
        fflush(stdout)
    }

    /**
     Executes a terminal control sequence where a response is expected.
     
     Example: The control sequence CSI 6n ("\u{1B}[6n ") is used to get the current position of the cursor which is returned as CSI#;#R ("\u{1B}[row;columnR").
     */
    public func executeControlSequenceWithResponse(_ controlSequence: ControlSequenceEmitting) throws -> String {
        print(controlSequence.csString(), terminator: "")
        fflush(stdout)
        do {
            let responseString = try read(nBytes: 64)
            return responseString
        } catch {
            throw TerminalError.failedToReadTerminalResponse(message: "A response from the terminal for the control sequence \(controlSequence.csString()) was expected, but a read from standard input failed with \(error)")
        }
    }
    
    
    ///Performs a soft terminal reset.
    public func softReset() {
        executeControlSequence(ANSIEscapeCode.softReset)
    }
    
    ///Returns the size of the screen in characters.
    public func textAreaSize() throws -> (width: Int, height: Int) {
        do {
            let resultString = try executeControlSequenceWithResponse(ANSIEscapeCode.textAreaSize)
            let items = resultString.strippingCSI().split(separator: ";").map{$0.trimmingCharacters(in:.letters)}.map{Int($0)}.filter({$0 != nil})
            if items.count == 3,
               let width = items[2],
               let height = items[1] {
                return (width: width, height: height)
            } else {
                throw TerminalError.failedToParseTerminalResponse(message: "Unable to parse respone for text area size control sequence. Response: \(resultString)")
            }
        } catch {
            throw TerminalError.failedToReadTerminalResponse(message: "A response for the textAreaSize control sequence was expected, but a read from standard input failed.")
        }
    }
    
    ///Returns the size of the screen as indicated by the terminal.
    public func screenSize() throws -> (width: Int, height: Int) {
        do {
            let resultString = try executeControlSequenceWithResponse(ANSIEscapeCode.screenSize)
            let items = resultString.strippingCSI().split(separator: ";").map{$0.trimmingCharacters(in: .letters)}.map{Int($0)}.filter({$0 != nil})
            if  items.count == 3,
                let width = items[2],
                let height = items[1] {
                return (width: width, height: height)
            } else {
                throw TerminalError.failedToParseTerminalResponse(message: "Unable to parse respone for screenSize control sequence. Response: \(resultString)")
            }
        } catch {
            throw TerminalError.failedToReadTerminalResponse(message: "A response for the screenSize control sequence was expected, but a read from standard input failed.")
        }

    }
    
    ///Clears the contents of the current screen
    public func clearScreen() {
        executeControlSequence(ANSIEscapeCode.clearScreen)
    }

    ///Performs a soft terminal reset, restores termios settings (Unix/MacOs), and exits the program.
    public func quit() {
        softReset()
        termios.restoreOriginalSettings()
        exit(0)
    }
}

enum TerminalError: Error, CustomStringConvertible {
    case zeroByteSystemRead
    case stringDecodingInSystemReadFailed
    case failedToParseTerminalResponse(message: String)
    case failedToReadTerminalResponse(message: String)
    
    var description: String {
        switch self {
        case .zeroByteSystemRead:
            return "Low level system returned zero bytes."
        case .stringDecodingInSystemReadFailed:
            return "Failed to decode bytes from system read to UTF-8 formatted string."
        case .failedToParseTerminalResponse(let message):
            return "Failed to parse terminal response. \(message)"
        case .failedToReadTerminalResponse(let message):
            return message
        }
    }
}
