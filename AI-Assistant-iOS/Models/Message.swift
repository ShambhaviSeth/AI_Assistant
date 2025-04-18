import Foundation

enum Sender {
    case user
    case assistant
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let sender: Sender
}
