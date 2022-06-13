# Terminus
![GitHub license](https://img.shields.io/github/license/jbadger3/Terminus) ![Version](https://img.shields.io/github/v/tag/jbadger3/Terminus)



# What is it?
The goal of Terminus is to make writing visually appealing command line applications fast, effecient, and intuitive.  It aims to provide both high level building blocks like menus and user prompts (y/n, multiple choice, REPL, etc.) as well as lower level access to things like terminal input modes, echoing, and the cursor.

* Please note: Terminus is an early stage project.  At this point none of the API should be relied upon as 'stable' or production ready.

# Usage/Examples

## Getting started
The `Terminal` class is a shared singleton that provides the primary interface for outputting text, moving the cursor, and interacting with the terminal.  When first instantiated, the input mode is set to .cbreak and echoing is turned off.

## Input modes
Terminals 

## Color
The majority of terminal emulators these days support 256 colors or more.  Colors in terminus can be specified using RGB as in:
```swift
let myColor = Color(r: 0, g: 0, b: 0) //black

```
## Stylized text


# Documentation

DocC files are hosted on https://swiftpackageindex.com 

# Installation

## Swift Package Manager 

To use `Terminus` in your own Swift PM based project, simply add it as a dependency for your package and executable target: 

```swift
let package = Package(
    // name, platforms, products, etc.
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/jbadger3/Terminus", from: "0.1.0"),
    ],
    targets: [
        .executableTarget(name: "YourAppName", dependencies: [
            // other dependencies
            .product(name: "Terminus", package: "Terminus"),
        ]),
        // other targets
    ]
)
```

## From XCode

In your current CLI project
1.  Select File > Swift Packages > Add Package Dependency. 
2. Copy and paste https://github.com/jbadger3/Terminus into the search URL
3. Select SwiftAnnoy and click next.
4. Choose a rule for dependency management.  Click next.
5. Click Finish.



# Credits/Resources

I am by no means an expert in all things terminal, nor can I say that I haven't cherry picked bits of code that I liked from other projects. Packages, sources of inspiration and sources with valuable information include: 

* [ConsolKit](https://github.com/vapor/console-kit) from the folks that make Vapor, an http server in swift.

* [commandlinekit](https://github.com/objecthub/swift-commandlinekit) from Matthias Zenger over at Google

* [Termios](https://github.com/Ponyboy47/Termios) - a more comprehensive Swifty wrapper for termios than I have implemented here.

* [XTerm control sequences](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html) One of the definitive sources of console related info IMO.

* The standard C library [read function] (https://pubs.opengroup.org/onlinepubs/009604599/functions/read.html)

* [Blog](https://blog.nelhage.com/2009/12/a-brief-introduction-to-termios/) on terminal emulators and termios 

* On [buffering of low level input streams](http://www.pixelbeat.org/programming/stdio_buffering/) at the kernel level 

* Summary of [ANSI Codes](https://www.real-world-systems.com/docs/ANSIcode.html)

* [rainbow](https://github.com/onevcat/Rainbow) : A nifty ANSI text styling package.
