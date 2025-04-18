import Foundation

class APIClient {
    static let shared = APIClient()
    
    func sendMessage(_ message: String, completion: @escaping (String) -> Void) {
        // Simulate a network delay and an AI assistant response.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let response = "You said: \(message)"
            completion(response)
        }
    }
}
