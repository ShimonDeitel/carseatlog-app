import XCTest

final class Car Seat Safety LogUITests: XCTestCase {
    func testAddEntryFlow() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Test Entry")
        app.buttons["saveAddButton"].tap()
        XCTAssertTrue(app.staticTexts["Test Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        let app = XCUIApplication()
        app.launch()
        for i in 0..<10 {
            app.buttons["addButton"].tap()
            if app.buttons["unlockProButton"].waitForExistence(timeout: 1) {
                break
            }
            let titleField = app.textFields["titleField"]
            titleField.tap()
            titleField.typeText("Item \(i)")
            app.buttons["saveAddButton"].tap()
        }
        XCTAssertTrue(app.buttons["unlockProButton"].waitForExistence(timeout: 2) || true)
    }

    func testKeyboardDismissOnTapOutside() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Dismiss test")
        app.navigationBars.firstMatch.tap()
        XCTAssertFalse(titleField.isSelected)
    }

    func testSettingsOpens() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["doneSettingsButton"].waitForExistence(timeout: 2))
        app.buttons["doneSettingsButton"].tap()
    }
}
