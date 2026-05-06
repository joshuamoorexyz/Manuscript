import SwiftUI
import WebKit
import PDFKit
import UniformTypeIdentifiers
import ObjectiveC
import CoreText

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
                MarkdownPreview(content: sheet.content)
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

        guard panel.runModal() == .OK, let url = panel.url else { return }

        let content = text.isEmpty ? " " : text
        let html = generateHTMLFromMarkdown(content)

        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")

        let group = DispatchGroup()
        group.enter()

        webView.loadHTMLString(html, baseURL: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let config = WKPDFConfiguration()
            webView.createPDF(configuration: config) { result in
                switch result {
                case .success(let data):
                    do {
                        try data.write(to: url)
                        print("PDF exported to \(url.path)")
                    } catch {
                        print("Export failed: \(error)")
                    }
                case .failure(let error):
                    print("PDF creation failed: \(error)")
                }
                group.leave()
            }
        }

        group.wait()
    }

    private func generateHTMLFromMarkdown(_ markdown: String) -> String {
        let isDark = colorScheme == .dark
        let bgColor = isDark ? "#1e1e1e" : "#ffffff"
        let textColor = isDark ? "#e0e0e0" : "#000000"
        let codeBg = isDark ? "#2d2d2d" : "#f5f5f5"

        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
            <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
            <script>
                window.MathJax = {
                    tex: { inlineMath: [['$', '$'], ['\\\\(', '\\\\)']] },
                    svg: { fontCache: 'global' }
                };
            </script>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                    font-size: 14px;
                    line-height: 1.6;
                    max-width: 750px;
                    margin: 20px auto;
                    padding: 0 20px;
                    background-color: \(bgColor);
                    color: \(textColor);
                }
                h1 { font-size: 2em; margin-top: 0.5em; border-bottom: 1px solid #ccc; }
                h2 { font-size: 1.5em; margin-top: 1em; }
                h3 { font-size: 1.17em; }
                strong { font-weight: bold; }
                em { font-style: italic; }
                code {
                    background-color: \(codeBg);
                    padding: 2px 6px;
                    border-radius: 3px;
                    font-family: 'SF Mono', Monaco, monospace;
                    font-size: 12px;
                }
                pre {
                    background-color: \(codeBg);
                    padding: 12px;
                    border-radius: 6px;
                    overflow-x: auto;
                }
                pre code { background: none; padding: 0; }
                blockquote {
                    border-left: 4px solid #ccc;
                    margin: 0;
                    padding-left: 16px;
                    color: #666;
                }
                ul, ol { padding-left: 30px; }
                a { color: #007AFF; text-decoration: none; }
                img { max-width: 100%; }
            </style>
        </head>
        <body>
        """

        html += parseMarkdown(markdown)
        html += "\n</body>\n</html>"
        return html
    }

    private func parseMarkdown(_ text: String) -> String {
        var html = ""
        let lines = text.components(separatedBy: "\n")
        var inCodeBlock = false
        var listType: String? = nil

        for line in lines {
            if line.hasPrefix("```") {
                if inCodeBlock {
                    html += "</pre>\n"
                    inCodeBlock = false
                } else {
                    html += "<pre><code>"
                    inCodeBlock = true
                }
                continue
            }

            if inCodeBlock {
                html += escapeHTML(line) + "\n"
                continue
            }

            if line.hasPrefix("# ") {
                if let type = listType { html += "</\(type)>\n"; listType = nil }
                html += "<h1>\(parseInline(String(line.dropFirst(2))))</h1>\n"
            } else if line.hasPrefix("## ") {
                if let type = listType { html += "</\(type)>\n"; listType = nil }
                html += "<h2>\(parseInline(String(line.dropFirst(3))))</h2>\n"
            } else if line.hasPrefix("### ") {
                if let type = listType { html += "</\(type)>\n"; listType = nil }
                html += "<h3>\(parseInline(String(line.dropFirst(4))))</h3>\n"
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                if listType != "ul" { if let type = listType { html += "</\(type)>\n" }; html += "<ul>\n"; listType = "ul" }
                html += "<li>\(parseInline(String(line.dropFirst(2))))</li>\n"
            } else if let match = line.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                if listType != "ol" { if let type = listType { html += "</\(type)>\n" }; html += "<ol>\n"; listType = "ol" }
                html += "<li>\(parseInline(String(line[match.upperBound...])))</li>\n"
            } else if line.isEmpty {
                if let type = listType { html += "</\(type)>\n"; listType = nil }
                html += "<br>\n"
            } else if line.hasPrefix("> ") {
                if let type = listType { html += "</\(type)>\n"; listType = nil }
                html += "<blockquote>\(parseInline(String(line.dropFirst(2))))</blockquote>\n"
            } else {
                if let type = listType { html += "</\(type)>\n"; listType = nil }
                html += "<p>\(parseInline(line))</p>\n"
            }
        }

        if let type = listType { html += "</\(type)>\n" }
        return html
    }

    private func parseInline(_ text: String) -> String {
        var result = escapeHTML(text)
        result = result.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"\*(.+?)\*"#, with: "<em>$1</em>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"`(.+?)`"#, with: "<code>$1</code>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"\[(.+?)\]\((.+?)\)"#, with: "<a href=\"$2\">$1</a>", options: .regularExpression)
        return result
    }

    private func escapeHTML(_ text: String) -> String {
        var result = text
        result = result.replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        return result
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
