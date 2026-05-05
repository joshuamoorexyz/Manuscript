import SwiftUI
import WebKit
import PDFKit
import UniformTypeIdentifiers
import ObjectiveC

struct EditorView: View {
    @ObservedObject var sheet: Sheet
    @Binding var isFocusMode: Bool
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var aiService: AIService
    @State private var text: String = ""
    @State private var showPreview = false
    @State private var showAIPanel = false
    @State private var aiAction: AIAction?
    @State private var showAIFeatures = false
    @State private var showFormatTools = false
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if showPreview {
                MarkdownPreview(content: text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TextEditor(text: $text)
                    .font(.system(size: 16))
                    .lineSpacing(6)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .focused($isEditorFocused)
                    .onAppear {
                        text = sheet.content
                        isEditorFocused = true
                    }
                    .onChange(of: text) { _, newValue in
                        sheet.content = newValue
                        sheet.lastModified = Date()
                        sheet.updateTitle()
                    }
                    .disabled(isFocusMode && !NSEvent.modifierFlags.contains(.command))
            }
            
            if aiService.isAvailable && showAIFeatures {
                Divider()
                AISuggestionsView(sheet: sheet)
                    .frame(height: 150)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
        .navigationTitle(sheet.title)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Button(action: { showAIFeatures.toggle() }) {
                    Image(systemName: "brain")
                }
                .help("AI Features")
                
                if showAIFeatures {
                    Button(action: { aiAction = .proofread }) {
                        Image(systemName: "checkmark.seal")
                    }
                    .help("Proofread with AI")
                    .disabled(!aiService.isAvailable || aiService.isGenerating)
                    
                    Button(action: { aiAction = .rewrite }) {
                        Image(systemName: "pencil.and.outline")
                    }
                    .help("Rewrite with AI")
                    .disabled(!aiService.isAvailable || aiService.isGenerating)
                    
                    Button(action: { aiAction = .summarize }) {
                        Image(systemName: "text.badge.plus")
                    }
                    .help("Summarize with AI")
                    .disabled(!aiService.isAvailable || aiService.isGenerating)
                    
                    Button(action: { aiAction = .generate }) {
                        Image(systemName: "wand.and.stars")
                    }
                    .help("Generate with AI")
                    .disabled(!aiService.isAvailable || aiService.isGenerating)
                    
                    Button(action: { aiAction = .continueWriting }) {
                        Image(systemName: "text.append")
                    }
                    .help("Continue Writing with AI")
                    .disabled(!aiService.isAvailable || aiService.isGenerating)
                    
                    Button(action: { aiAction = .expand }) {
                        Image(systemName: "text.viewfinder")
                    }
                    .help("Expand Text with AI")
                    .disabled(!aiService.isAvailable || aiService.isGenerating)
                    
                    Button(action: { aiAction = .changeTone }) {
                        Image(systemName: "speaker.wave.2")
                    }
                    .help("Change Tone with AI")
                    .disabled(!aiService.isAvailable || aiService.isGenerating)
                    
                    Divider()
                    
                    Button(action: { aiAction = .outline }) {
                        Image(systemName: "list.bullet.indent")
                    }
                    .help("Generate Outline with AI")
                    .disabled(!aiService.isAvailable || aiService.isGenerating)
                    
                    Button(action: { aiAction = .character }) {
                        Image(systemName: "person.fill")
                    }
                    .help("Develop Character with AI")
                    .disabled(!aiService.isAvailable || aiService.isGenerating)
                    
                    Button(action: { aiAction = .plot }) {
                        Image(systemName: "chart.xyaxis.line")
                    }
                    .help("Analyze Plot with AI")
                    .disabled(!aiService.isAvailable || aiService.isGenerating)
                }
                
                Divider()
                
                Button(action: { showFormatTools.toggle() }) {
                    Image(systemName: "textformat")
                }
                .help("Format Tools")
                
                if showFormatTools {
                    Button(action: { insertMarkup(before: "**", after: "**") }) {
                        Image(systemName: "bold")
                    }
                    .help("Bold")
                    
                    Button(action: { insertMarkup(before: "*", after: "*") }) {
                        Image(systemName: "italic")
                    }
                    .help("Italic")
                    
                    Button(action: { insertMarkup(before: "## ", after: "\n") }) {
                        Image(systemName: "h.square.fill")
                    }
                    .help("Heading")
                    
                    Button(action: { insertAtLineStart(text: "- ") }) {
                        Image(systemName: "list.bullet")
                    }
                    .help("Bullet List")
                    
                    Button(action: { insertAtLineStart(text: "1. ") }) {
                        Image(systemName: "list.number")
                    }
                    .help("Numbered List")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Toggle(isOn: $showPreview) {
                    Image(systemName: "eye")
                }
                .toggleStyle(ButtonToggleStyle())
                .help("Toggle Preview")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: exportToPDF) {
                    Image(systemName: "square.and.arrow.up")
                }
                .help("Export to PDF")
            }
        }
        .sheet(item: $aiAction) { action in
            switch action {
            case .outline:
                AIOutlineView(sheet: sheet)
                    .environmentObject(aiService)
            default:
                AIPanelView(action: action, text: text, sheet: sheet)
                    .environmentObject(aiService)
            }
        }
    }
    
    private func exportToPDF() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.pdf]
        panel.nameFieldStringValue = "\(sheet.title).pdf"
        
        if panel.runModal() == .OK, let url = panel.url {
            let textView = NSTextView(frame: CGRect(x: 0, y: 0, width: 595, height: 842))
            textView.string = text.isEmpty ? " " : text
            textView.font = NSFont.systemFont(ofSize: 12)
            
            let printInfo = NSPrintInfo.shared
            printInfo.jobDisposition = .save
            printInfo.dictionary()[NSPrintInfo.AttributeKey.jobDisposition] = NSPrintInfo.JobDisposition.save
            printInfo.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = url
            
            let printOperation = NSPrintOperation(view: textView, printInfo: printInfo)
            printOperation.run()
        }
    }
    
    private func insertMarkup(before: String, after: String) {
        guard let selectedRange = getSelectedRange() else {
            text += before + "text" + after
            return
        }
        
        let startIndex = text.index(text.startIndex, offsetBy: selectedRange.location)
        let endIndex = text.index(startIndex, offsetBy: selectedRange.length)
        let selectedText = String(text[startIndex..<endIndex])
        
        let newText: String
        if selectedText.isEmpty {
            newText = before + "text" + after
        } else {
            newText = before + selectedText + after
        }
        
        let newString = text.prefix(upTo: startIndex) + newText + text.suffix(from: endIndex)
        text = String(newString)
    }
    
    private func insertAtLineStart(text: String) {
        let newText = "\n" + text
        self.text += newText
    }
    
    private func getSelectedRange() -> NSRange? {
        guard let window = NSApp.keyWindow,
              let textView = window.firstResponder as? NSTextView else {
            return nil
        }
        
        let selectedRange = textView.selectedRange()
        return selectedRange
    }
}
