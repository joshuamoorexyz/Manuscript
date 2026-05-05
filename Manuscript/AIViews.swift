import SwiftUI

enum AIAction: String, Identifiable {
    case proofread
    case rewrite
    case summarize
    case generate
    case analyze
    case continueWriting
    case expand
    case changeTone
    case outline
    case character
    case plot
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .proofread: return "Proofread"
        case .rewrite: return "Rewrite"
        case .summarize: return "Summarize"
        case .generate: return "Generate"
        case .analyze: return "Analyze"
        case .continueWriting: return "Continue Writing"
        case .expand: return "Expand"
        case .changeTone: return "Change Tone"
        case .outline: return "Outline"
        case .character: return "Character"
        case .plot: return "Plot"
        }
    }
    
    var icon: String {
        switch self {
        case .proofread: return "checkmark.seal"
        case .rewrite: return "pencil.and.outline"
        case .summarize: return "text.badge.plus"
        case .generate: return "wand.and.stars"
        case .analyze: return "chart.bar"
        case .continueWriting: return "text.append"
        case .expand: return "text.viewfinder"
        case .changeTone: return "speaker.wave.2"
        case .outline: return "list.bullet.indent"
        case .character: return "person.fill"
        case .plot: return "chart.xyaxis.line"
        }
    }
}

struct AIPanelView: View {
    let action: AIAction
    let text: String
    @ObservedObject var sheet: Sheet
    @EnvironmentObject var aiService: AIService
    @Environment(\.dismiss) var dismiss
    @State private var prompt: String = ""
    @State private var style: String = "concise"
    @State private var tone: String = "professional"
    @State private var result: String = ""
    @State private var isProcessing = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if aiService.isGenerating {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Processing with Apple Intelligence...")
                    }
                    .padding()
                }
                
                if !aiService.isAvailable {
                    ContentUnavailableView(
                        "Apple Intelligence Not Available",
                        systemImage: "exclamationmark.triangle",
                        description: Text("This feature requires Apple Intelligence on macOS 15.0+")
                    )
                } else {
                    if action == .generate {
                        TextField("Enter prompt for generation...", text: $prompt, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                            .padding(.horizontal)
                    }
                    
                    if action == .rewrite {
                        Picker("Style", selection: $style) {
                            Text("Concise").tag("concise")
                            Text("Professional").tag("professional")
                            Text("Creative").tag("creative")
                            Text("Casual").tag("casual")
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    
                    if action == .changeTone {
                        Picker("Tone", selection: $tone) {
                            Text("Professional").tag("professional")
                            Text("Casual").tag("casual")
                            Text("Friendly").tag("friendly")
                            Text("Authoritative").tag("authoritative")
                            Text("Humorous").tag("humorous")
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    
                    if !result.isEmpty {
                        Text("Result:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            Text(result)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        HStack {
                            Button("Replace Selection") {
                                if !result.isEmpty && !text.isEmpty {
                                    sheet.content = sheet.content.replacingOccurrences(of: text, with: result)
                                } else if !result.isEmpty {
                                    sheet.content += "\n\n" + result
                                }
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Insert at Cursor") {
                                sheet.content += "\n\n" + result
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
            .navigationTitle(action.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action.title) {
                        Task { await performAction() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(aiService.isGenerating || !aiService.isAvailable)
                }
            }
        }
        .frame(width: 500, height: 400)
    }
    
    private func performAction() async {
        do {
            let processed: String
            switch action {
            case .proofread:
                processed = try await aiService.proofread(text: text)
            case .rewrite:
                processed = try await aiService.rewrite(text: text, style: style)
            case .summarize:
                processed = try await aiService.summarize(text: text)
            case .generate:
                processed = try await aiService.generateChapter(prompt: prompt, existingContent: text)
            case .analyze:
                _ = try await aiService.analyzeText(text)
                processed = "Analysis complete"
            case .continueWriting:
                processed = try await aiService.continueWriting(text: text)
            case .expand:
                processed = try await aiService.expandText(text: text)
            case .changeTone:
                processed = try await aiService.changeTone(text: text, tone: tone)
            case .character:
                processed = try await aiService.developCharacter(name: "Character", context: text)
            case .plot:
                processed = try await aiService.analyzePlot(content: text)
            case .outline:
                processed = try await aiService.generateOutline(content: text)
            }
            await MainActor.run { result = processed }
        } catch {
            await MainActor.run {
                result = "Error: \(error.localizedDescription)"
            }
        }
    }
}

struct AIAnalysisView: View {
    @ObservedObject var sheet: Sheet
    @EnvironmentObject var aiService: AIService
    @Environment(\.dismiss) var dismiss
    @State private var analysis: TextAnalysis?
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                if isAnalyzing {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Analyzing with Apple Intelligence...")
                    }
                    .padding()
                } else if let analysis = analysis {
                    VStack(alignment: .leading, spacing: 16) {
                        AnalysisRow(title: "Tension Level", value: "\(analysis.tension)/10", icon: "gauge.high")
                        AnalysisRow(title: "Pacing", value: analysis.pacing.capitalized, icon: "speedometer")
                        AnalysisRow(title: "Strongest Hook", value: analysis.hook, icon: "hook")
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "No Analysis Yet",
                        systemImage: "chart.bar",
                        description: Text("Tap Analyze to get AI insights about your text")
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Analysis")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Analyze") {
                        Task { await performAnalysis() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isAnalyzing || !aiService.isAvailable)
                }
            }
        }
        .frame(width: 400, height: 300)
    }
    
    private func performAnalysis() async {
        isAnalyzing = true
        do {
            let result = try await aiService.analyzeText(sheet.content)
            await MainActor.run {
                analysis = result
                isAnalyzing = false
            }
        } catch {
            await MainActor.run { isAnalyzing = false }
        }
    }
}

struct AnalysisRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            Spacer()
        }
    }
}
