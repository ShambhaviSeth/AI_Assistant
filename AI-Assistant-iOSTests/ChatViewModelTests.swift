import XCTest
@testable import AI_Assistant_iOS

/// A stub executor that immediately returns a fixed response.
private class StubExecutor: CommandExecuting {
    let response: String
    init(response: String) { self.response = response }
    func execute(command: String, completion: @escaping (String) -> Void) {
        completion(response)
    }
}

final class ChatViewModelTests: XCTestCase {
    func testSendMessage_appendsUserAndAssistantMessages() {
        let stubResponse = "stub reply"
        let viewModel = ChatViewModel(commandExecutor: StubExecutor(response: stubResponse))
        
        XCTAssertEqual(viewModel.messages.count, 1)  // initial welcome
        
        viewModel.sendMessage("hello")
        // after sendMessage, user message appended synchronously
        XCTAssertEqual(viewModel.messages.last?.text, "hello")
        XCTAssertEqual(viewModel.messages.last?.sender, .user)
    }
}
