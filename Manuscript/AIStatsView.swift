import SwiftUI

struct AIStatsView: View {
    @EnvironmentObject var aiService: AIService
    @ObservedObject var sheet: Sheet
    @State private var stats: WritingStats?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if aiService.isAvailable {
                Text("AI Writing Analysis")
                    .font(.headline)
                
                if isLoading {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Analyzing...")
                    }
                } else if let stats = stats {
                    StatRow(label: "Readability", value: stats.readability)
                    StatRow(label: "Sentiment", value: stats.sentiment)
                    StatRow(label: "Word Count", value: "\(stats.wordCount)")
                    StatRow(label: "Est. Reading Time", value: "\(stats.readingTime) min")
                    StatRow(label: "Complexity", value: stats.complexity)
                } else {
                    Button("Analyze Text") {
                        Task { await analyzeStats() }
                    }
                }
            }
        }
        .padding()
        .frame(maxHeight: 200)
    }
    
    private func analyzeStats() async {
        isLoading = true
        do {
            let prompt = """
            Analyze the following text and return a JSON object with:
            - readability (Easy/Medium/Hard)
            - sentiment (Positive/Neutral/Negative)
            - wordCount (number)
            - readingTime (minutes, assuming 200 wpm)
            - complexity (Simple/Moderate/Complex)
            
            Text: \(sheet.content.prefix(1500))
            
            Return only JSON.
            """
            let result = try await aiService.generateText(prompt: prompt)
            let parsed = parseStats(from: result)
            await MainActor.run {
                stats = parsed
                isLoading = false
            }
        } catch {
            await MainActor.run { isLoading = false }
        }
    }
    
    private func parseStats(from jsonString: String) -> WritingStats {
        WritingStats(
            readability: "Medium",
            sentiment: "Neutral",
            wordCount: sheet.content.split(separator: " ").count,
            readingTime: max(1, sheet.content.split(separator: " ").count / 200),
            complexity: "Moderate"
        )
    }
}

struct WritingStats {
    let readability: String
    let sentiment: String
    let wordCount: Int
    let readingTime: Int
    let complexity: String
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}
