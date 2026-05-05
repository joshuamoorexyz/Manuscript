import SwiftUI

struct AIChatView: View {
    @EnvironmentObject var aiService: AIService
    @ObservedObject var sheet: Sheet
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding()
            }
            
            Divider()
            
            HStack {
                TextField("Ask about your writing...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { sendMessage() }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(inputText.isEmpty || isLoading || !aiService.isAvailable)
            }
            .padding(8)
        }
        .frame(width: 300)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, text: inputText)
        messages.append(userMessage)
        
        let prompt = inputText
        inputText = ""
        isLoading = true
        
        Task {
            do {
                let context = sheet.content.prefix(1000)
                let fullPrompt = """
                Context: \(context)
                
                Question: \(prompt)
                
                Provide a helpful response about the writing.
                """
                let response = try await aiService.generateText(prompt: fullPrompt)
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, text: response))
                    isLoading = false
                }
            } catch {
                await MainActor.run { isLoading = false }
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let text: String
}

enum MessageRole {
    case user
    case assistant
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            Text(message.text)
                .padding(10)
                .background(message.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(10)
                .frame(maxWidth: 250, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}
