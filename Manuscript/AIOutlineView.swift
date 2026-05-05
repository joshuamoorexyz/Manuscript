import SwiftUI

struct AIOutlineView: View {
    @EnvironmentObject var aiService: AIService
    @ObservedObject var sheet: Sheet
    @Environment(\.dismiss) var dismiss
    @State private var outline: String = ""
    @State private var isGenerating = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if isGenerating {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Generating outline with AI...")
                    }
                    .padding()
                } else if !outline.isEmpty {
                    Text("Generated Outline:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        Text(outline)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    Button("Insert as Headings") {
                        insertAsHeadings()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                } else {
                    ContentUnavailableView(
                        "No Outline Yet",
                        systemImage: "list.bullet.indent",
                        description: Text("Generate an AI-powered outline for your content")
                    )
                }
                
                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("AI Outline Generator")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Generate") {
                        Task { await generateOutline() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isGenerating || !aiService.isAvailable || sheet.content.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 400)
    }
    
    private func generateOutline() async {
        isGenerating = true
        do {
            let prompt = """
            Create a detailed outline for the following content. 
            Use markdown headings (## for main sections, ### for subsections).
            Return only the outline:
            
            \(sheet.content.prefix(2000))
            """
            let result = try await aiService.generateText(prompt: prompt)
            await MainActor.run {
                outline = result
                isGenerating = false
            }
        } catch {
            await MainActor.run { isGenerating = false }
        }
    }
    
    private func insertAsHeadings() {
        let lines = outline.components(separatedBy: "\n")
        let headings = lines.filter { $0.hasPrefix("##") || $0.hasPrefix("###") }
        let textToInsert = headings.joined(separator: "\n") + "\n\n"
        sheet.content += "\n\n" + textToInsert
    }
}
