import SwiftUI
import WebKit

struct MarkdownPreview: NSViewRepresentable {
    let content: String
    @Environment(\.colorScheme) var colorScheme
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let html = generateHTML(from: content)
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    private func generateHTML(from markdown: String) -> String {
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
                    font-size: 16px;
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
                    font-size: 14px;
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
}
