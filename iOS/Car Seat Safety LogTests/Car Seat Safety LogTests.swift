import XCTest
@testable import Car Seat Safety Log

@MainActor
final class Car Seat Safety LogTests: XCTestCase {
    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.items.count, Store.freeItemLimit)
    }

    func testAddIncreasesCount() {
        let store = Store()
        let before = store.items.count
        store.add(title: "New")
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testCanAddWhenBelowLimitFree() {
        let store = Store()
        XCTAssertTrue(store.canAdd(isPro: false))
    }

    func testCannotAddWhenAtLimitFree() {
        let store = Store()
        while store.items.count < Store.freeItemLimit {
            store.add(title: "Filler")
        }
        XCTAssertFalse(store.canAdd(isPro: false))
    }

    func testProCanAlwaysAdd() {
        let store = Store()
        while store.items.count < Store.freeItemLimit {
            store.add(title: "Filler")
        }
        XCTAssertTrue(store.canAdd(isPro: true))
    }

    func testDeleteRemovesItem() {
        let store = Store()
        store.add(title: "ToDelete")
        let item = store.items[0]
        store.delete(item)
        XCTAssertFalse(store.items.contains(item))
    }

    func testToggleDoneFlipsFlag() {
        let store = Store()
        store.add(title: "ToggleMe")
        let item = store.items[0]
        XCTAssertFalse(item.isDone)
        store.toggleDone(item)
        XCTAssertTrue(store.items[0].isDone)
    }

    func testUpdateAppliesChanges() {
        let store = Store()
        store.add(title: "Original")
        var item = store.items[0]
        item.title = "Changed"
        store.update(item)
        XCTAssertEqual(store.items[0].title, "Changed")
    }
}
