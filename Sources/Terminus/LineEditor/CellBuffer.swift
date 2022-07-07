
//
//  Created by Jonathan Badger on 6/21/22.
//

import Foundation

/**
 
 */
public class CellBuffer {
    ///An array of ``Cell``s that constitutes the data in the buffer
    public var cells: [Cell] = []
    ///The contents of the linebuffer as a contiguous String
    public var stringValue: String {
        return cells.reduce("", {$0 + String($1.character)})
    }
    
    public init(cells: [Cell]? = nil) {
        if let cells = cells {
            self.cells = cells
        }
    }
    
    ///Adds a LineBufferCell at a specific index
    public func add(cell: Cell, index: Int) {
        if index >= 0 && index <= cells.endIndex + 1  {
            cells.insert(cell, at: index)
        }
    }
    
    ///Deletes a LineBufferCell at the given index
    public func deleteCell(index: Int) {
        if cells.indices.contains(index) {
            cells.remove(at: index)
        }
    }
    
    
    public func writeBuffer() {
        let terminal = Terminal.shared
        for cell in cells {
            terminal.write(String(cell.character), attributes: cell.attributes)
        }
    }
    
    public func set(attributes: [Attribute], forRange range: Range<Int>? = nil) {
        if let range = range {
            var newCells = [Cell]()
            for cell in cells[range] {
                newCells.append(Cell(contents: cell.character, attributes: attributes))
            }
            cells.replaceSubrange(range, with: newCells)
        } else {
            for (index, cell) in cells.enumerated() {
                cells[index] = Cell(contents: cell.character, attributes: attributes)
                
            }
        }
    }
    
    public func split(separator: Character) -> [CellBuffer] {
        let cellGroups = cells.split(whereSeparator: {$0.character == separator})
        return cellGroups.map({CellBuffer(cells: Array($0))})
    }
}

public extension Array where Element: CellBuffer  {
    func joined(separator: Cell) -> CellBuffer {
        let cellBuffer = CellBuffer()
        for (index, buffer) in self.enumerated() {
            cellBuffer.cells.append(contentsOf: buffer.cells)
            if index != self.count - 1 {
                cellBuffer.cells.append(separator)
            }
        }
        return cellBuffer
    }
}
