import XCTest
@testable import HomeManagerCore

final class HomeTreeEngineTests: XCTestCase {
    func testAddSpaceAndBreadcrumb() {
        var engine = HomeTreeEngine(rootName: "我的家")

        let roomID = engine.addSpace(name: "主卧", parentID: engine.rootID)
        XCTAssertNotNil(roomID)

        let closetID = engine.addSpace(name: "衣柜", parentID: roomID!)
        XCTAssertNotNil(closetID)

        let path = engine.breadcrumb(for: closetID!).map(\.name)
        XCTAssertEqual(path, ["我的家", "主卧", "衣柜"])
    }

    func testMoveSpaceCyclePrevention() {
        var engine = HomeTreeEngine(rootName: "我的家")
        let roomID = engine.addSpace(name: "主卧", parentID: engine.rootID)!
        let closetID = engine.addSpace(name: "衣柜", parentID: roomID)!

        XCTAssertFalse(engine.canMoveSpace(roomID, to: closetID))
        XCTAssertFalse(engine.moveSpace(roomID, to: closetID))
        XCTAssertTrue(engine.moveSpace(closetID, to: engine.rootID))
    }

    func testRecursiveDeleteSpaceAlsoRemovesItems() {
        var engine = HomeTreeEngine(rootName: "我的家")
        let roomID = engine.addSpace(name: "主卧", parentID: engine.rootID)!
        let closetID = engine.addSpace(name: "衣柜", parentID: roomID)!
        let drawerID = engine.addSpace(name: "上层抽屉", parentID: closetID)!

        let itemID = engine.addItem(name: "护照", spaceID: drawerID)
        XCTAssertNotNil(itemID)

        XCTAssertTrue(engine.deleteSpace(roomID))
        XCTAssertTrue(engine.items.isEmpty)
        XCTAssertNil(engine.spaces[roomID])
        XCTAssertNil(engine.spaces[closetID])
        XCTAssertNil(engine.spaces[drawerID])
    }

    func testSearchWithinScopedSubtree() {
        var engine = HomeTreeEngine(rootName: "我的家")
        let bedID = engine.addSpace(name: "主卧", parentID: engine.rootID)!
        let kitchenID = engine.addSpace(name: "厨房", parentID: engine.rootID)!

        _ = engine.addItem(name: "护照", spaceID: bedID, tags: ["证件"])
        _ = engine.addItem(name: "锅铲", spaceID: kitchenID, tags: ["厨具"])

        let (spaces, items) = engine.search(keyword: "护", in: bedID)
        XCTAssertEqual(spaces.count, 0)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "护照")
    }

    func testUpdateItemQuantityMinimumIsOne() {
        var engine = HomeTreeEngine(rootName: "我的家")
        let roomID = engine.addSpace(name: "主卧", parentID: engine.rootID)!
        let itemID = engine.addItem(name: "充电线", spaceID: roomID, quantity: 2)!

        XCTAssertTrue(engine.updateItemQuantity(itemID, quantity: 0))
        XCTAssertEqual(engine.items[itemID]?.quantity, 1)
    }
}
