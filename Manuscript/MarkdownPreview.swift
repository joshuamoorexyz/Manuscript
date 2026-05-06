import SwiftUI

struct MarkdownPreview: View {
    let content: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(parseMarkdown(content), id: \.id) { block in
                    renderBlock(block)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(colorScheme == .dark ? Color(hex: 0x1e1e1e) : Color(NSColor.textBackgroundColor))
    }
    
    @ViewBuilder
    private func renderBlock(_ block: MarkdownBlock) -> some View {
        switch block {
        case .heading(let level, let text):
            renderInlineText(text)
                .font(headingFont(for: level))
                .fontWeight(headingWeight(for: level))
                .padding(.top, level == 1 ? 8 : 4)
                .padding(.bottom, 2)
                .overlay(alignment: .bottom) {
                    if level == 1 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                }
        case .paragraph(let text):
            renderInlineText(text)
                .lineSpacing(6)
        case .codeBlock(let code):
            Text(code)
                .font(.system(size: 14, design: .monospaced))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: colorScheme == .dark ? 0x2d2d2d : 0xf5f5f5))
                .cornerRadius(6)
        case .blockquote(let text):
            renderInlineText(text)
                .padding(.leading, 16)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 4)
                }
        case .bulletList(let items):
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 4) {
                        Text("•")
                        renderInlineText(item)
                    }
                }
            }
            .padding(.leading, 20)
        case .numberedList(let items):
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 4) {
                        Text("\(index + 1).")
                        renderInlineText(item)
                    }
                }
            }
            .padding(.leading, 20)
        case .empty:
            Spacer()
                .frame(height: 12)
        }
    }
    
    @ViewBuilder
    private func renderInlineText(_ text: String) -> some View {
        if text.contains("**") || text.contains("*") || text.contains("`") || text.contains("[") {
            Text(try! AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
        } else {
            Text(text)
        }
    }
    
    private func headingFont(for level: Int) -> Font {
        switch level {
        case 1: return .system(size: 32)
        case 2: return .system(size: 24)
        case 3: return .system(size: 20)
        default: return .system(size: 16)
        }
    }
    
    private func headingWeight(for level: Int) -> Font.Weight {
        level <= 2 ? .bold : .semibold
    }
    
    private func parseMarkdown(_ text: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        let lines = text.components(separatedBy: "\n")
        var currentParagraph: [String] = []
        var inCodeBlock = false
        var codeLines: [String] = []
        var inBulletList = false
        var bulletItems: [String] = []
        var inNumberedList = false
        var numberedItems: [String] = []
        
        func flushParagraph() {
            if !currentParagraph.isEmpty {
                blocks.append(.paragraph(currentParagraph.joined(separator: " ")))
                currentParagraph.removeAll()
            }
        }
        
        func flushLists() {
            if inBulletList {
                blocks.append(.bulletList(bulletItems))
                bulletItems.removeAll()
                inBulletList = false
            }
            if inNumberedList {
                blocks.append(.numberedList(numberedItems))
                numberedItems.removeAll()
                inNumberedList = false
            }
        }
        
        for line in lines {
            if line.hasPrefix("```") {
                if inCodeBlock {
                    blocks.append(.codeBlock(codeLines.joined(separator: "\n")))
                    codeLines.removeAll()
                    inCodeBlock = false
                } else {
                    flushParagraph()
                    flushLists()
                    inCodeBlock = true
                }
                continue
            }
            
            if inCodeBlock {
                codeLines.append(line)
                continue
            }
            
            if line.hasPrefix("# ") {
                flushParagraph()
                flushLists()
                blocks.append(.heading(1, String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                flushParagraph()
                flushLists()
                blocks.append(.heading(2, String(line.dropFirst(3))))
            } else if line.hasPrefix("### ") {
                flushParagraph()
                flushLists()
                blocks.append(.heading(3, String(line.dropFirst(4))))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                flushParagraph()
                if !inBulletList { inBulletList = true }
                bulletItems.append(String(line.dropFirst(2)))
            } else if let match = line.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                flushParagraph()
                if !inNumberedList { inNumberedList = true }
                numberedItems.append(String(line[match.upperBound...]))
            } else if line.hasPrefix("> ") {
                flushParagraph()
                flushLists()
                blocks.append(.blockquote(String(line.dropFirst(2))))
            } else if line.isEmpty {
                flushParagraph()
                flushLists()
                blocks.append(.empty)
            } else {
                if inBulletList || inNumberedList {
                    flushLists()
                }
                currentParagraph.append(line)
            }
        }
        
        flushParagraph()
        flushLists()
        
        return blocks
    }
}

enum MarkdownBlock {
    case heading(Int, String)
    case paragraph(String)
    case codeBlock(String)
    case blockquote(String)
    case bulletList([String])
    case numberedList([String])
    case empty
    
    var id: String {
        switch self {
        case .heading(let level, let text): return "h\(level)-\(text)"
        case .paragraph(let text): return "p-\(text)"
        case .codeBlock(let code): return "code-\(code)"
        case .blockquote(let text): return "quote-\(text)"
        case .bulletList(let items): return "ul-\(items.joined())"
        case .numberedList(let items): return "ol-\(items.joined())"
        case .empty: return "empty-\(UUID())"
        }
    }
}

extension Color {
    init(hex: Int) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}
