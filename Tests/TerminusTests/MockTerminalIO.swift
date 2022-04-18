//
//  File.swift
//  
//
//  Created by Jonathan Badger on 4/18/22.
//

import Foundation
@testable import Terminus

func mockTerminalIO(terminal: Terminal) {
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                        isDirectory: true)
    let stdinURL = temporaryDirectoryURL.appendingPathComponent("stdin.\(UUID())")
    
    let stdoutURL = temporaryDirectoryURL.appendingPathComponent("stdout.\(UUID())")
    let fileManager = FileManager.default
    fileManager.createFile(atPath: stdinURL.path, contents: nil)
    fileManager.createFile(atPath: stdoutURL.path, contents: nil)
    
    terminal.standardInput = try! FileHandle(forUpdating: stdinURL)
    terminal.standardOutput = try! FileHandle(forUpdating: stdoutURL)
}


func write(_ string: String, toFileHandle fh: FileHandle) {
    /*There are some issues with writing chunks of data larger than 10-15 bytes to standard output.  They end up garbled in the terminal output.*/
    guard var str = string.cString(using: .utf8)  else { return }
    str.removeLast()
    #if os(macOS)
    Darwin.write(fh.fileDescriptor, &str, str.count)
    #elseif os(Linux)
    Glibc.write(fh.fileDescriptor, &str, str.count)
    #endif
}
 
