import SwiftUI

struct EditorView: View {
    @ObservedObject var sheet: Sheet
    @Binding var isFocusMode: Bool
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @State private var text: String = ""
    @State private var showPreview = false
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if showPreview {
                MarkdownPreview(content: text)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
        .navigationTitle(sheet.title)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Button(action: { text += "**Bold**" }) {
                    Image(systemName: "bold")
                }
                .help("Bold")
                
                Button(action: { text += "*Italic*" }) {
                    Image(systemName: "italic")
                }
                .help("Italic")
                
                Button(action: { text += "\n## Heading" }) {
                    Image(systemName: "text.heading")
                }
                .help("Heading")
                
                Button(action: { text += "\n- List item" }) {
                    Image(systemName: "list.bullet")
                }
                .help("Bullet List")
                
                Button(action: { text += "\n1. List item" }) {
                    Image(systemName: "list.number")
                }
                .help("Numbered List")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Toggle(isOn: $showPreview) {
                    Image(systemName: "eye")
                }
                .toggleStyle(ButtonToggleStyle())
                .help("Toggle Preview")
            }
        }
    }
}

struct MarkdownPreview: View {
    let content: String
    
    var body: some View {
        ScrollView {
            Text(try! AttributedString(markdown: content, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
                .font(.system(size: 16))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
