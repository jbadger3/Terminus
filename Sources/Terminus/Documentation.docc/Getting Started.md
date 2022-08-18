# Getting Started

An introduction to using Terminus.

## Overview
The starting point for any command line application using Terminus begins with the terminal. The ``Terminal`` class is a shared singleton that provides the primary interface for outputting text, moving the cursor, and interacting with the terminal.
```swift
import Terminus
let terminal = Terminal.shared
```

### Printing output
To print to the screen use one of the `terminal`'s write methods: 
* ``Terminal/write(_:attributes:)``
* ``Terminal/write(attributedString:)``.

```swift
terminal.write("Hello world!")
```
Unlike Swift's built in `print()` function, ``Terminal/write(_:attributes:)`` doesn't automatically insert a linefeed ("\n") character  by default.  Linefeeds must be added manually.
```swift
terminal.write("Hello world with a new line!\n")
```
![Linefeed Example](example_write_and_linefeed_handling)

>Note:You can still use the built-in `print()` function if you wish.  Just keep in mind you won't be able to add color or styling.

### Text Attributes
Most modern terminal emulators support text styling and color (256 is typical).  To add one or more styles to text you can pass an array of attributes when calling write.  See ``Attribute`` for the list of text styles and color support.
```swift
terminal.write("I am bold and underlined.\n", attributes: [.bold, .underline])
```
Attributes do not persist between calls to write.
```swift
terminal.write("This is inverse,", attributes: [.reverse])
terminal.write(" but not anymore.\n")
```

You can also use attributed strings to add styling as in:
```swift
var attributedString = AttributedString("Hello, bold, underlined, world.")
if let boldRange = attributedString.range(of: "bold") {
    attributedString[boldRange].terminalTextAttributes = [.bold]
}
if let underlinedRange = attributedString.range(of: "underlined") {
    attributedString[underlinedRange].terminalTextAttributes = [.underline]
}
terminal.write(attributedString: attributedString)
```
![style persistance](example_printing_output)

### Colors
Terminal cells have a foreground color (typically white) and background color (typically black).  Colors can be explicitly defined using RGB or selected by name from built-in color palettes.

>Note: Terminus does not 'check' for color support like frameworks such as ncurses.  As such, some terminals may not respond to ANSI codes to set colors ("CSI 38;2;{r};{g};{b}m", and "CSI 48;2;{r};{g};{b}m") or may interpret them differently.

You can specify the foreground color using ``Attribute/color(_:)`` and any ``Color`` specified in RGB.
```swift
let greenColor = Color(r:0, g:255, b:0)
terminal.write("Grass is green.\n", attributes: [.color(greenColor)])
```
To set both the foreground and background colors use ``Attribute/colorPair(_:)`` passing in a ``ColorPair``.
```swift
let redColor = Color(r: 255, g:0, b:0)
let grayColor = Color(r: 200, g:200, b:200)
let redOnGray = ColorPair(foreground: redColor, background: grayColor)
terminal.write("Red rum.\n", attributes: [.colorPair(redOnGray)])
```

Terminus also has built-in color palettes that can be used to specify colors by name.  Colors from palettes are passed around just like any other ``Color`` in Terminus.
```swift
let palette = XTermPalette()
let blueOneYellow = ColorPair(foreground: palette.Blue1, background: palette.Yellow1)
terminal.write("Blue on yellow", attributes: [.colorPair(blueOneYellow)])
```
See <doc:Color-Palette-Reference> for visual charts.
![Color Example](example_colors)

### Getting User Input
To catpure a single keypress use ``Terminal/getKey()``.
```swift
terminal.write("Press any key: ")
if let key = try? terminal.getKey() {
    terminal.write("\nYou pressed the \(key.rawValue) key.")
}
```
The ``Key`` that is returned can be checked to see what ``KeyType`` the user inputed using a switch statement or using computed properties.
```swift
terminal.write("Press any key: ")
if let key = try? terminal.getKey() {
    switch key.type {
    case .character:
        terminal.write("You pressed a character key.")
    case .control(_):
        terminal.write("You pressed the a control key.")
    case .function(_):
        terminal.write("You pressed a function key.")
    case .navigation(_):
        terminal.write("You pressed a navigation key.")
    }
}
```
or using computed properties.
```swift
if let key = try? terminal.getKey() {
    if key.isCharacter {
        terminal.write("You pressed a character key.")
    }
}
```

To capture an entire line of text (until a "\n" is received) use the ``Terminal/getLine()`` function.
```swift
let line = terminal.getLine()
```
For more advanced line-based input capture see <doc:Using-the-LineEditor>

### Working with the cursor
The window of the terminal is diveded up into evenly spaced cells typically arranged with 80 columns and 24 rows.  The cursor, which always sits in one of these cells, can be identified by its row (y), and column (x).  You can find the current location of the cursor using the the ``Terminal``.

>Note: The origin in terminal coordinates is the upper left corner of the screen and begins with (1, 1).

```swift
if let currentLocation = terminal.cursor.location {
    terminal.write("The cursor is/was at \(currentLocation)")
}
```

You can move the cursor to the home position (1, 1),
```swift
terminal.cursor.moveToHome()
```
to a specific location,
```swift
let location = Location(x: 5, y: 10)
terminal.cursor.move(toLocation: location)
```
or n units in the direction of your choosing.
```swift
terminal.cursor.move(5, direction: .right)
```


