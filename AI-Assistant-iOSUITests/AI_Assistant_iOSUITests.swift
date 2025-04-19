//
//  AI_Assistant_iOSUITests.swift
//  AI-Assistant-iOSUITests
//
//  Created by Shambhavi Seth on 4/11/25.
//

import XCTest

final class AI_Assistant_iOSUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Ensure a fresh launch for each test
        app.terminate()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    /// Test that the app launches and shows the initial welcome message.
    @MainActor
    func testLaunchShowsWelcomeMessage() throws {
        app.launch()
        // Expect the very first assistant message
        let firstBubble = app.staticTexts["Welcome! How can I help you today?"]
        XCTAssertTrue(firstBubble.waitForExistence(timeout: 2), "Welcome message should be visible on launch")
    }

    /// Test sending a text command and receiving a response.
    @MainActor
    func testSendTextCommandDisplaysAssistantReply() throws {
        app.launch()

        let textField = app.textFields["Type your command..."]
        XCTAssertTrue(textField.exists, "The command text field should exist")
        textField.tap()
        textField.typeText("what is the time?\n")

        // Tap the Send button
        let sendButton = app.buttons["Send"]
        XCTAssertTrue(sendButton.exists, "Send button should exist")
        sendButton.tap()

        // Wait for the assistant response to appear
        let responsePredicate = NSPredicate(format: "label CONTAINS[c] 'current time is'")
        let response = app.staticTexts.containing(responsePredicate).firstMatch
        XCTAssertTrue(response.waitForExistence(timeout: 5), "Assistant should respond with current time")
    }

    /// Test that the microphone button exists and toggles recording state.
    @MainActor
    func testMicrophoneButtonTogglesRecording() throws {
        app.launch()

        let micButton = app.buttons["mic.fill"]
        XCTAssertTrue(micButton.exists, "Microphone button should exist")

        // Start recording
        micButton.tap()
        // The button symbol should change to "stop.fill" when recording
        let stopButton = app.buttons["stop.fill"]
        XCTAssertTrue(stopButton.waitForExistence(timeout: 2), "Stop button should appear when recording starts")

        // Stop recording
        stopButton.tap()
        XCTAssertTrue(micButton.waitForExistence(timeout: 2), "Microphone button should reappear when recording stops")
    }

    /// Measure app launch performance, terminating before each launch.
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.terminate()
            app.launch()
        }
    }
}
