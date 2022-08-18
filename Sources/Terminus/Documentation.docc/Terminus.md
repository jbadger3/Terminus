# ``Terminus``
A toolkit for making command line applications.

## Overview

The goal of Terminus is to make writing visually appealing command line applications fast, efficient, and intuitive.  It aims to provide both high level building blocks like menus and user prompts (y/n, multiple choice, REPL, etc.) as well as lower level access to ANSI escape codes for users that want more complete control.

>Note: Modern terminal emulators utilize [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code) (aka terminal control sequences), a legacy language of their physical ancestors, for tasks like controlling the cursor and changing the color of text.      


## Topics

### Essentials
- <doc:Getting-Started>
- <doc:Using-the-LineEditor>
- <doc:Color-Palette-Reference>

### Terminal and Cursor
- ``Terminal``
- ``Cursor``
- ``Location``

### Text Styling and Color
- ``Attribute``
- ``TerminalTextAttribute``
- ``Color``
- ``ColorPair``

### Color Palettes
- ``ColorPalette``
- ``BasicColorPalette``
- ``XTermPalette``
- ``X11WebPalette``

### User Interface
- ``LineEditor``
- ``Menu``

### Keys and Sequences
- ``Key``
- ``KeyType``
- ``NavigationKey``
- ``ControlKey``
- ``FunctionKey``
- ``Backspace``
- ``Bel``
- ``CSI``
- ``CarriageReturn``
- ``DCS``
- ``Esc``
- ``Linefeed``
- ``OSC``
- ``Tab``

### ANSI Escape Codes (control sequences)
- ``ANSIEscapeCode``
- ``ControlSequenceEmitting``





