import SwiftUI

struct AISuggestionsView: View {
    @EnvironmentObject var aiService: AIService
    @ObservedObject var sheet: Sheet
    @State private var suggestions: [AISuggestion] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if aiService.isAvailable {
                Text("AI Suggestions")
                    .font(.headline)
                    .padding(.horizontal)
                
                if isLoading {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Generating suggestions...")
                    }
                    .padding()
                } else if suggestions.isEmpty {
                    Button("Get Suggestions") {
                        Task { await generateSuggestions() }
                    }
                    .padding(.horizontal)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(suggestions) { suggestion in
                                SuggestionRow(suggestion: suggestion) {
                                    applySuggestion(suggestion)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                ContentUnavailableView(
                    "AI Not Available",
                    systemImage: "brain",
                    description: Text("Enable Apple Intelligence to get writing suggestions")
                )
            }
        }
        .padding(.vertical)
        .frame(maxHeight: 200)
    }
    
    private func generateSuggestions() async {
        isLoading = true
        do {
            let prompt = """
            Analyze the following text and provide 3 specific writing suggestions for improvement.
            Return as a simple list, one suggestion per line:
            
            \(sheet.content.prefix(1000))
            """
            let result = try await aiService.generateText(prompt: prompt)
            let items = result.components(separatedBy: "\n")
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                .prefix(3)
                .enumerated()
                .map { AISuggestion(id: $0.offset, text: $0.element) }
            
            await MainActor.run {
                suggestions = items
                isLoading = false
            }
        } catch {
            await MainActor.run { isLoading = false }
        }
    }
    
    private func applySuggestion(_ suggestion: AISuggestion) {
        sheet.content += "\n\n" + suggestion.text
    }
}

struct AISuggestion: Identifiable {
    let id: Int
    let text: String
}

struct SuggestionRow: View {
    let suggestion: AISuggestion
    let onApply: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "lightbulb")
                .foregroundColor(.yellow)
                .font(.system(size: 12))
            
            Text(suggestion.text)
                .font(.system(size: 11))
                .lineLimit(3)
            
            Spacer()
            
            Button("Apply") {
                onApply()
            }
            .buttonStyle(.link)
            .font(.system(size: 10))
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
}
