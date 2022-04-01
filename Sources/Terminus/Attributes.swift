//
//  File.swift
//  
//
//  Created by Jonathan Badger on 3/23/22.
//

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
    
    public func stringValue() -> String {
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
        }
    }
    
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
        }
    }
    
    
    
     
    
}
