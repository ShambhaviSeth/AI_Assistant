import XCTest
@testable import AI_Assistant_iOS

final class CommandExecutorTests: XCTestCase {
    var executor: CommandExecutor!
    
    override func setUp() {
        super.setUp()
        executor = CommandExecutor()
    }
    
    func testTimeCommand_returnsCurrentTime() {
        let exp = expectation(description: "time")
        executor.execute(command: "What is the time?") { response in
            XCTAssertTrue(response.lowercased().contains("current time is"))
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTipCommand_calculation() {
        let exp = expectation(description: "tip")
        executor.execute(command: "calculate tip for 200 at 10%") { response in
            XCTAssertTrue(response.contains("tip is 20.0") && response.contains("total is 220.0"))
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUnknownCommand_fallback() {
        let exp = expectation(description: "fallback")
        executor.execute(command: "gibberish command") { response in
            XCTAssertEqual(response, "I did not understand the command: gibberish command")
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
