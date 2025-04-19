//
//  AI_Assistant_iOSUITestsLaunchTests.swift
//  AI-Assistant-iOSUITests
//
//  Created by Shambhavi Seth on 4/11/25.
//

import XCTest

final class AI_Assistant_iOSUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Captures a screenshot of the launch screen for verification.
    @MainActor
    func testLaunch_showLaunchScreen() throws {
        let app = XCUIApplication()
        app.launch()

        // Take and attach a screenshot of the initial UI state.
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
