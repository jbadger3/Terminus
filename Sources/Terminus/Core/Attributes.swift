//
//  File.swift
//  
//
//  Created by Jonathan Badger on 3/23/22.
//

///Used to specify the appearance of characters on screen.  Mutliple attributes can be combined for varying effects.
public enum Attribute: ControlSequence {
    case resetToDefault //CSI 0m
    case bold //CSI 1m
    case dim //CSI 2m
    case italic //CSI 3m
    case underline //CSI 4m
    case blinking //CSI 5m
    case reverse //CSI 7m
    case hidden //CSI 8m
    case strikethrough //CSI 9m
    case color(Color)
    case colorPair(ColorPair)
    
    ///A string representation of the ANSI escape sequence
    public func csString() -> String {
        switch self {
        case .resetToDefault:
            return CSI + "0m"
        case .bold:
            return CSI + "1m"
        case .dim:
            return CSI + "2m"
        case .italic:
            return CSI + "3m"
        case .underline:
            return CSI + "4m"
        case .blinking:
            return CSI + "5m"
        case .reverse:
            return CSI + "7m"
        case .hidden:
            return CSI + "8m"
        case .strikethrough:
            return CSI + "9m"
        case .color(let color):
            return ANSIEscapeCode.colorSetForegroundRGB(r: color.r, g: color.g, b: color.b).csString()
        case .colorPair(let colorPair):
            let fgColor = colorPair.foreground
            let fgString = ANSIEscapeCode.colorSetForegroundRGB(r: fgColor.r , g: fgColor.g, b: fgColor.b)
            let bgColor = colorPair.background
            let bgString = ANSIEscapeCode.colorSetBackgroundRGB(r: bgColor.r, g: bgColor.g, b: bgColor.b)
            return fgString + bgString
        }
    }
    
    ///A string representation of the ANSI escape sequence used to turn off the associated attribute.  This function is used by Terminal.write and in general should not need to be manually called.
    public func resetValue() -> String {
        switch self {
        case .resetToDefault:
            return""
        case .bold:
            return CSI + "22m"
        case .dim:
            return CSI + "22m"
        case .italic:
            return CSI + "23m"
        case .underline:
            return CSI + "24m"
        case .blinking:
            return CSI + "25m"
        case .reverse:
            return CSI + "27m"
        case .hidden:
            return CSI + "28m"
        case .strikethrough:
            return CSI + "29m"
        case .color(_):
            return CSI + "39m"
        case .colorPair(_):
            return CSI + "39;49m"
        }
    }
}

extension Attribute: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.csString())
    }
    
}
