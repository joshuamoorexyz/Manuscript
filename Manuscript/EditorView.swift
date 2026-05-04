import SwiftUI

struct EditorView: View {
    @ObservedObject var sheet: Sheet
    @Binding var isFocusMode: Bool
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @State private var text: String = ""
    @State private var showPreview = false
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !isFocusMode {
                EditorToolbar(text: $text, showPreview: $showPreview)
            }
            
            if showPreview {
                MarkdownPreview(content: text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TextEditor(text: $text)
                    .font(.system(size: 16))
                    .lineSpacing(6)
                    .padding(.horizontal, isFocusMode ? 120 : 60)
                    .padding(.vertical, 20)
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
        .navigationTitle(sheet.title)
    }
}

struct EditorToolbar: View {
    @Binding var text: String
    @Binding var showPreview: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { insertText("**Bold**") }) {
                Image(systemName: "bold")
            }
            .help("Bold")
            
            Button(action: { insertText("*Italic*") }) {
                Image(systemName: "italic")
            }
            .help("Italic")
            
            Button(action: { insertText("## Heading") }) {
                Image(systemName: "text.heading")
            }
            .help("Heading")
            
            Divider()
            
            Button(action: { insertText("- List item") }) {
                Image(systemName: "list.bullet")
            }
            .help("Bullet List")
            
            Button(action: { insertText("1. List item") }) {
                Image(systemName: "list.number")
            }
            .help("Numbered List")
            
            Spacer()
            
            Toggle(isOn: $showPreview) {
                Image(systemName: "eye")
            }
            .toggleStyle(ButtonToggleStyle())
            .help("Toggle Preview")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(Divider(), alignment: .bottom)
    }
    
    private func insertText(_ newText: String) {
        text += (text.isEmpty ? "" : "\n") + newText
    }
}

struct MarkdownPreview: View {
    let content: String
    
    var body: some View {
        ScrollView {
            if let attributedString = try? AttributedString(markdown: content) {
                Text(attributedString)
                    .font(.system(size: 16))
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(content)
                    .font(.system(size: 16))
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
