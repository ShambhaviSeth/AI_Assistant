import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var speechService = SpeechService()
    @State private var currentInput: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient for the entire view.
                LinearGradient(gradient: Gradient(colors: [Color("BackgroundStart"), Color("BackgroundEnd")]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Chat messages list.
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageRow(message: message)
                                    .transition(.move(edge: .bottom))
                                    .animation(.easeInOut, value: viewModel.messages.count)
                            }
                        }
                        .padding()
                    }
                    
                    Divider()
                    
                    // Input area combining text field and voice command button.
                    HStack {
                        TextField("Type your command...", text: $currentInput)
                            .padding(12)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(20)
                            .shadow(radius: 2)
                        
                        // Microphone button to toggle voice input.
                        Button(action: {
                            if speechService.isRecording {
                                speechService.stopRecording()
                                currentInput = speechService.transcribedText
                            } else {
                                do {
                                    try speechService.startRecording()
                                } catch {
                                    print("Error starting speech recognition: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            Image(systemName: speechService.isRecording ? "stop.fill" : "mic.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        
                        // Send button and progress indicator.
                        if viewModel.isSending {
                            ProgressView()
                                .padding(8)
                        } else {
                            Button("Send") {
                                viewModel.sendMessage(currentInput)
                                currentInput = ""
                            }
                            .padding(12)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
            .navigationTitle("AI Assistant")
        }
    }
}

struct MessageRow: View {
    var message: Message
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Use distinct icons for the assistant and the user.
            if message.sender == .assistant {
                Image(systemName: "bubble.left.fill")
                    .foregroundColor(Color.blue)
                    .font(.system(size: 24))
            } else {
                Image(systemName: "person.fill")
                    .foregroundColor(Color.green)
                    .font(.system(size: 24))
            }
            
            // Message bubble with custom styling.
            Text(message.text)
                .padding(12)
                .background(message.sender == .assistant ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                .cornerRadius(15)
                .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .previewDevice("iPhone 13")
    }
}
