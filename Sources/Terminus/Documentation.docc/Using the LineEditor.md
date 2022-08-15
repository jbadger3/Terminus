# Using the LineEditor

Basic usage and customization for collecting user input using the LineEditor class.

## Overview

The LineEditor editor class provides a familiar text editing experience out of the box.  To initiate user input call `.getInput()`.  While input is being captured you can use the arrowkeys to move the cursor, insert, and delete characters.  When you are finisehd editing press return/enter to receive the input string back.

> Note: The linefeed character "\n" used to end user interaction is *not* included in the returned string.

## Basic Usage

```swift
 import Terminus
 let terminal = Terminal.shared
 terminal.write("Type something: ")
 
 let lineEditor = LineEditor()
 let input = lineEditor.getInput()
 
 terminal.write("\nYou typed: \(input)")
 sleep(2)
 ```
 
 As user input is being captured it is stored in the ``LineEditor/buffer`` property.  Although the buffer is a public property, custom editing and styling should be applied using ``LineEditor/bufferHandler``.  See the 'Adding color and style to text' below for an exmaple.

## Customizing Behavior
If the default behavior of LineEditor doesn't suit your needs it can be customized.  If, for example, you want to add autocomplete, you can do that.  If you want to allow for inputs that include Linefeed ("\n") characters you can do that too.

All Inputs captured by the LineEditor are processed by key type (character, navigation, function, or control) using on of:

- characterKeyHandler: ((Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer))?
- navigationKeyHandler: ((Key) -> ShouldWriteBuffer)?
- functionKeyHandler: ((Key) -> ShouldWriteBuffer)?
- controlKeyHandler: ((Key) -> ShouldWriteBuffer)?

One final handler, `bufferHandler` is also available for adding text styling and color in between key presses. 

How you change the key handler property is up to you.  You can use closure syntax as in:
```swift
let lineEditor = LineEditor()
lineEditor.characterKeyHandler = { key in
    return(true, true)
}
```
Or you subclass LineEditor and set the handler properties after initialization.  

Before tackling a few examples take a look at the code for the default charcterKeyHandler:
```swift
func defaultCharacterHandler(key: Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer) {
    if key.rawValue == Backspace {
        let shouldWriteBuffer = defaultBackspaceKeyHandler()
        return (false, shouldWriteBuffer)
    }
    if key.rawValue == Linefeed {
        shouldEndEditing = true
        return (false, false)
    }
    if key.rawValue == Esc {
        return (false, false)
    }
    return (true, true)
}
```
This function does four things:
1.  Handles Backspace key presses.  (make sure to copy/paste the code from the if statement in your custom function)
2.  Checks if the return key ("\n") was pressed.  If so, shouldEndEditing is set to true signaling .getInput() to return the captured string.
3.  If the escape key is pressed, skips adding it to the buffer.
4.  For all other characters returns a tuple (true, true) indicating the key should be added to the buffer and the buffer should be written to the terminal.

### Example: Using the escape key to cancel editing

```swift
import Terminus
import Foundation

let terminal = Terminal.shared
let lineEditor = LineEditor()

class EscapingLineEditor: LineEditor {
    override init() {
        super.init()
        self.characterKeyHandler = handleCharacter
    }
    
    func handleCharacter(key: Terminus.Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer) {
        if key.rawValue == Backspace {
            let shouldWriteBuffer = defaultBackspaceKeyHandler()
            return (false, shouldWriteBuffer)
        }
        if key.rawValue == Linefeed {
            shouldEndEditing = true
            return (false, false)
        }
        if key.rawValue == Esc {
            shouldEndEditing = true
            let range = buffer.startIndex..<buffer.endIndex
            buffer.removeSubrange(range)
            return (false, false)
        }
       return (true, true)
    }
}

let escapingEditor = EscapingLineEditor()
let results = escapingEditor.getInput()
terminal.write("\n")
if results == "" {
    terminal.write("You escaped or didn't write anything.")
} else {
    terminal.write("You typed: \(results)")
}
sleep(3)
```

### Example: Adding support for multiple lines of text

```swift
import Terminus
import Foundation

let terminal = Terminal.shared

class MultiLineEditor: LineEditor {
    override init() {
        super.init()
        self.characterKeyHandler = handleCharacter
    }
    
    func handleCharacter(key: Terminus.Key) -> (ShouldAddKeyToLineBuffer, ShouldWriteBuffer) {
        if key.rawValue == Backspace {
            let shouldWriteBuffer = defaultBackspaceKeyHandler()
            return (false, shouldWriteBuffer)
        }
        if let currentLocation = terminal.cursor.location,
           let bufferIndex = bufferIndexForLocation(currentLocation),
           bufferIndex == buffer.characters.endIndex,
           buffer.characters.last == "\n",
           key.rawValue == "\n" {
            shouldEndEditing = true
            return (false, false)
        }
        if key.rawValue == Esc {
            return (false, false)
        }
        return (true, true)
    }
}

let multiLineEditor = MultiLineEditor()

while true {
    let lines = multiLineEditor.getInput()
    terminal.write(lines, attributes: [.color(Color(r: 20, g: 255, b: 20))])
}
```

### Example: Adding color and style to text

There is one additional handler, `bufferHandler`, that is called after a key press is received and added to the buffer, but before the buffer is rewritten to the terminal.  This is the place to add any color or styling.

```swift
import Terminus

let terminal = Terminal.shared
let lineEditor = LineEditor()

lineEditor.bufferHandler = {
    var shouldWriteBuffer = false
    if let greenRange = lineEditor.buffer.range(of: "green") {
        lineEditor.buffer[greenRange].terminalTextAttributes = [.color(Color(r: 0, g: 255, b: 0))]
        shouldWriteBuffer = true
    }
    if let yellowRange = lineEditor.buffer.range(of: "yellow") {
        lineEditor.buffer[yellowRange].terminalTextAttributes = [.color(Color(r: 255, g: 255, b: 0))]
        shouldWriteBuffer = true
    }
    if let redRange = lineEditor.buffer.range(of: "red") {
        lineEditor.buffer[redRange].terminalTextAttributes = [.color(Color(r: 255, g: 0, b: 0))]
        shouldWriteBuffer = true
    }
    return shouldWriteBuffer
}

let input = lineEditor.getInput()
```

