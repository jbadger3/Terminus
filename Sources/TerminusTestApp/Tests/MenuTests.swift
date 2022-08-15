//  Created by Jonathan Badger on 6/8/22.
//

import Foundation

@testable import Terminus


class MenuTests: TestCase {
    var terminal: Terminal!
    var sut: Menu!
    var textAreaSize: (width: Int, height: Int)!
    let testItems = ["Professor X", "Cyclops / Captain Krakoa", "Iceman", "Beast", "Angel / Archangel", "Marvel Girl / Phoenix", "Mimic", "Changeling", "Polaris", "Havok", "Petra", "Sway", "Darwin", "Vulcan", "Nightcrawler", "Wolverine", "Banshee", "Storm", "Sunfire", "Colossus", "Thunderbird", "Sprite / Ariel / Shadowcat", "Lockheed", "Rogue", "Phoenix / Marvel Girl / Prestige", "Magneto", "Longshot", "Psylocke", "Dazzler", "Forge / Maker", "Gambit", "Jubilee", "Bishop", "Revanche", "Cannonball", "Joseph", "Cecilia Reyes", "Marrow", "Maggott", "Thunderbird", "Cable", "Mirage / Moonstar", "Sage", "White Queen", "Xorn", "Chamber", "Stacy X", "Lifeguard", "Slipstream", "Northstar", "Husk", "Juggernaut", "Xorn / Zorn", "Mystique", "Warpath", "Lady Mastermind", "Sabretooth", "Omega Sentinel", "Armor", "Hepzibah", "Pixie", "Karma", "Sunspot", "Aurora", "Magma", "Doctor Nemesis", "Box", "Magik", "Sub-Mariner", "Domino", "Cloak", "Dagger", "Boom-Boom", "Ariel", "Danger"]
    
    init() {
        super.init(name: "MenuTests")
        tests = [Test(name: "test_draw_whenEnoughColumnsPresent_drawsAllItems", testFunction: test_draw_whenEnoughColumnsPresent_drawsAllItems, interactive: true),
                 Test(name: "test_draw_whenNotEnoughColumnsPresent_fillsToBottom", testFunction: test_draw_whenNotEnoughColumnsPresent_fillsToBottom, interactive: true),
                 Test(name: "test_draw_whenScrollOffset2_startsAtItem3", testFunction: test_draw_whenScrollOffset2_startsAtItem3, interactive: true),
                 Test(name: "test_draw_whencurrentSelection1_highlightsItem1", testFunction: test_draw_whencurrentSelection1_highlightsItem1, interactive: true),
                 Test(name: "test_getSelection_whenEscapeKeyPressed_exitsWithNil", testFunction: test_getSelection_whenEscapeKeyPressed_exitsWithNil, interactive: true),
                 Test(name: "test_getSelection_whenEnterPressed_exitsWithSelection", testFunction: test_getSelection_whenEnterPressed_exitsWithSelection, interactive: true),
        ]
        
    }

    
    override func setUp() {
        terminal = Terminal.shared
        terminal.cursor.moveToHome()
        terminal.clearScreen()
        sut = Menu(location: Location(x: 1, y: 1), items: testItems)
        
        textAreaSize = try! terminal.textAreaSize()
    }
    
    override func tearDown() {
        sut = nil
        terminal = nil
    }
    
    func test_draw_whenEnoughColumnsPresent_drawsAllItems() throws {
        let items = Array(testItems[0..<5])
        sut = Menu(location: Location(x: 1, y: 1), items: items)
        sut.draw()
        try promptUserForVisualTest(prompt: "Are all items (\(items.joined(separator: ","))  present?")
    }
    
    func test_draw_whenNotEnoughColumnsPresent_fillsToBottom() throws {
        let testMenuLocation = Location(x: 1, y: textAreaSize.height - 2)
        sut = Menu(location: testMenuLocation, items: testItems, maxColumns: 1)
        
        sut.draw()
        
        try promptUserForVisualTest(prompt: "Is \(testItems[2]) the last item on the screen?", location: Location(x: 1, y: 1))
    }
    
    func test_draw_whenScrollOffset2_startsAtItem3() throws {
        sut = Menu(location: Location(x: 1, y: 1), items: testItems, maxColumns: 2, maxRows: 3, scrollDirection: .vertical)
        sut.scrollOffset = 2
        
        sut.draw()
        
        try promptUserForVisualTest(prompt: "Is the first item \(testItems[4])?")
    }
    
    func test_draw_whencurrentSelection1_highlightsItem1() throws {
        let items = Array(testItems[0..<5])
        sut = Menu(location: Location(x: 1, y: 1), items: items, maxColumns: 1, scrollDirection: .vertical)
        sut.currentSelection = (1, 0)
        sut.draw()
        
        try promptUserForVisualTest(prompt: "Is the current selection \(testItems[1])")
    }
    
    func test_getSelection_whenEscapeKeyPressed_exitsWithNil() throws {
        sut.draw()
        terminal.cursor.move(toLocation: Location(x: 1, y: 500))
        terminal.write("Try pressing ESCAPE to exit")
        let selection = sut.getSelection()
        TAssertNil(selection)
        
        
        try promptUserForVisualTest(prompt: "Were you able to get out?")
    }
    
    func test_getSelection_whenEnterPressed_exitsWithSelection() throws {
        sut.draw()
        terminal.cursor.move(toLocation: Location(x: 1, y: 500))
        terminal.write("Try pressing enter to select the first object")
        let selection = sut.getSelection()
        TAssertNotNil(selection)
        
        try promptUserForVisualTest(prompt: "Did you press enter?")
    }

}
