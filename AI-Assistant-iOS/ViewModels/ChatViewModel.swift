import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isSending: Bool = false
    private let commandExecutor: CommandExecuting

    init(commandExecutor: CommandExecuting = CommandExecutor()) {
        self.commandExecutor = commandExecutor
        // Initial message from assistant
        messages.append(Message(text: "Welcome! How can I help you today?", sender: .assistant))
    }
    
    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        messages.append(Message(text: trimmed, sender: .user))
        isSending = true
        
        commandExecutor.execute(command: trimmed) { [weak self] response in
            DispatchQueue.main.async {
                self?.messages.append(Message(text: response, sender: .assistant))
                self?.isSending = false
            }
        }
    }
}
