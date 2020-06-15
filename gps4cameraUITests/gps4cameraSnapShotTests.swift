//
//  gps4cameraSnapShotTests.swift
//  gps4cameraUITests
//
//  Created by Astro on 6/14/20.
//  Copyright © 2020 RSB. All rights reserved.
//

import Foundation
import XCTest

class gps4cameraSnapShotTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTakeSnapshots() {
        var step = 1
        
        let app = XCUIApplication()
        setupSnapshot(app)
        
        addUIInterruptionMonitor(withDescription: "System Dialog") {
          (alert) -> Bool in
          alert.buttons["Allow While Using App"].tap()
          return true
        }
        app.tap()
        
        snapshot("\(String(format: "%03d", step))-AppStart")
        step += 1

        app.buttons[""].tap()
        snapshot("\(String(format: "%03d", step))-GPSStart")
        step += 1

        app.buttons[""].tap()
        snapshot("\(String(format: "%03d", step))-GPSStop")
        step += 1

        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Sync"].tap()
        snapshot("\(String(format: "%03d", step))-Sync")
        step += 1

        tabBarsQuery.buttons["Files"].tap()
        snapshot("\(String(format: "%03d", step))-Files")
        step += 1

        app.tables.element(boundBy: 0).cells.element(boundBy: 0).tap()
        snapshot("\(String(format: "%03d", step))-Map")
        step += 1

        let navigationBar = app.navigationBars.firstMatch
        navigationBar.buttons["Share"].tap()
        snapshot("\(String(format: "%03d", step))-Share")
        step += 1

        if UIDevice.current.userInterfaceIdiom == .pad {
            let popoverdismissregionElement = app/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
            popoverdismissregionElement.tap()
        } else {
            // iPad doesn't have a cancel button and will crash the test if we try looking for it
            app.sheets["Share Format"].scrollViews.otherElements.buttons["Cancel"].tap()
        }
        
        navigationBar.buttons["Files"].tap()
        tabBarsQuery.buttons["Settings"].tap()
        snapshot("\(String(format: "%03d", step))-Settings")
        step += 1
    }
}
