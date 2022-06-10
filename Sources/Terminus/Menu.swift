//
//  Created by Jonathan Badger on 6/7/22.
//

import Foundation

/**
 For vertical scrolling cells are filled left to right, top to bottom.  For horizontal filling items are filled top to bottom, left to right
 */
public class Menu {
    enum ScrollDirection {
        case vertical
        case horizontal
    }
    
    public var location: Location
    public let items: [String]
    public let itemAttributes: [Attribute]
    public let selectionAttributes: [Attribute]
    static let defaultItemColorPair = ColorPair(foreground: XTermPalette().Black, background: XTermPalette().Silver)
    static let defaultSelectionColorPair = ColorPair(foreground: XTermPalette().Black, background: XTermPalette().Grey46)
    
    var hidden: Bool = true
    public let maxColumns: Int
    public let maxRows: Int
    var columnWidth: Int = 0
    typealias TableDimensions = (nRows: Int, nColumns: Int)
    var tableDimensions: TableDimensions = (1, 1)
    typealias ItemPosition = (row: Int, column: Int)
    var currentSelection: (row: Int, column: Int) = (0, 0)
    var scrollOffset: Int = 0
    let scrollDirection: ScrollDirection

    init(location: Location?, items: [String], maxColumns: Int = Int.max, maxRows: Int = Int.max, scrollDirection: ScrollDirection = .vertical, itemAttributes: [Attribute] = [.colorPair(defaultItemColorPair)], selectionAttributes: [Attribute] = [.colorPair(defaultSelectionColorPair)]) {
        if let location = location {
            self.location = location
        } else {
            let cursor = Cursor()
            self.location = cursor.location == nil ? Location(x: 1, y: 1) : cursor.location!
        }
        self.items = items
        self.maxColumns = maxColumns
        self.maxRows = maxRows
        self.scrollDirection = scrollDirection
        self.itemAttributes = itemAttributes
        self.selectionAttributes = selectionAttributes
    }
    
    func indexFor(itemPosition: ItemPosition) -> Int {
        switch scrollDirection {
        case .vertical:
            return (itemPosition.row + scrollOffset) * tableDimensions.nColumns + itemPosition.column
        case .horizontal:
            return itemPosition.row + tableDimensions.nRows * (itemPosition.column + scrollOffset)
        }
    }
    
    
    func show() {
        
    }
    
    func hide() {
        
    }
    
    func calculateTableDimensions() {
    /*
     1. Determine number of rows and columns available based on the location of where the menu will be drawn.
     2. Calculate the maxVisible rows/columns/cells taking the smaller of the visible dimension or user specified max
     3. If the total number of visible cells is less than the total number of items...use all available space
     4. Otherwise fill maximally in the direction opposite of the scroll, calculating needed columns/rows to fit.
     
     */
        let terminal = Terminal.shared
        
        //1.
        let textArea = terminal.textAreaSize()
        guard textArea != (-1, -1) else { return }
        let rowsAvailable = textArea.height - location.y + 1
        
        let availableCharWidth = textArea.width - location.x + 1
        columnWidth = items.reduce(0, { max($0, $1.count)}) + 2
        var columnsAvailable = 1
        if availableCharWidth >= columnWidth {
            columnsAvailable = availableCharWidth / columnWidth
        }
        
        //2.
        let maxVisibleColumns = min(maxColumns, columnsAvailable)
        let maxVisibleRows = min(maxRows, rowsAvailable)
        let maxVisibleCells = maxVisibleRows * maxVisibleColumns
        
        var nRows = 1
        var nColumns = 1
        
        //3.
        if maxVisibleCells <= items.count {
            nRows = maxVisibleRows
            nColumns = maxVisibleColumns
        } else {
            //4.
            switch scrollDirection {
            case .vertical:
                if maxVisibleColumns > items.count {
                    nColumns = items.count
                } else {
                    nColumns = maxVisibleColumns
                    nRows = Int((Float(items.count) / Float(nColumns)).rounded(.up))
                }
            case .horizontal:
                if maxVisibleRows > items.count {
                    nRows = items.count
                } else {
                    nRows = maxVisibleRows
                    nColumns =  Int((Float(items.count) / Float(nRows)).rounded(.up))
                }
            }
        }
        tableDimensions = TableDimensions(nRows: nRows, nColumns: nColumns)
    }
    
    func draw() {
        /*
         1.  save the current cursor location...the draw func should not ever change the current cursor location once complete.
         2.
         */
        let terminal = Terminal.shared
        let cursor = Cursor()
        cursor.save()
        cursor.set(visibility: false)
        calculateTableDimensions()
        
        let startingLocation = location
        for column in 0..<tableDimensions.nColumns {
            for row in 0..<tableDimensions.nRows {
                let itemLocation = Location(x: startingLocation.x + column * columnWidth , y: startingLocation.y + row)
                cursor.move(toLocation: itemLocation)
                let currentItem = ItemPosition(row: row, column: column)
                let currentIndex = indexFor(itemPosition: currentItem)
                var itemString = ""
                if currentIndex < items.count {
                    itemString = items[currentIndex]
                }
                itemString = " \(itemString)".padding(toLength: columnWidth, withPad: " ", startingAt: 0)
                if currentItem == currentSelection {
                    terminal.write(itemString, attributes: selectionAttributes)
                } else {
                    terminal.write(itemString, attributes: itemAttributes)
                }
            }
        }
        
        cursor.restore()
        cursor.set(visibility: true)
    }
    
    func awaitSelection(selectionHandler: @escaping ((_ selection: String?) -> Void)) {
        let terminal = Terminal.shared
        while true {
            if let key = terminal.getKey() {
                if key.keyCode == .KEY_ESC {
                    return selectionHandler(nil)
                }
                if key.keyCode == .KEY_LF {
                    let itemIndex = indexFor(itemPosition: currentSelection)
                    return selectionHandler(items[itemIndex])
                }
                if key.isArrowKey {
                    moveSelection(key: key)
                }
            }
        }
    }
    
    func moveSelection(key: Key) {
        guard key.isArrowKey else { return }
        guard let keyCode = key.keyCode else { return }
        switch keyCode {
        case .KEY_DOWN:
            let proposedPosition = ItemPosition(row: currentSelection.row + 1, column: currentSelection.column)
            let proposedIndex = indexFor(itemPosition: proposedPosition)
            if proposedIndex < items.count {
                if currentSelection.row < tableDimensions.nRows - 1 {
                    currentSelection.row += 1
                } else if scrollDirection == .vertical {
                    scrollOffset += 1
                }
            }
        case .KEY_UP:
            let proposedPosition = ItemPosition(row: currentSelection.row - 1, column: currentSelection.column)
            if proposedPosition.row < 0 && scrollDirection == .vertical && scrollOffset > 0 {
                scrollOffset -= 1
            } else if proposedPosition.row >= 0 {
                currentSelection.row -= 1
            }
        case .KEY_LEFT:
            let proposedPosition = ItemPosition(row: currentSelection.row, column: currentSelection.column - 1)
            if proposedPosition.column < 0 && scrollDirection == .horizontal && scrollOffset > 0 {
                scrollOffset -= 1
            } else if proposedPosition.column >= 0 {
                currentSelection.column -= 1
            }
        case .KEY_RIGHT:
            let proposedPosition = ItemPosition(row: currentSelection.row, column: currentSelection.column + 1)
            let proposedIndex = indexFor(itemPosition: proposedPosition)
            if proposedIndex < items.count {
                if currentSelection.column < tableDimensions.nColumns - 1 {
                    currentSelection.column += 1
                } else if scrollDirection == .horizontal {
                    scrollOffset += 1
                }
            }
        default:
            return
        }
        draw()
    }
     
    
    
}
