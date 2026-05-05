# Manuscript

A distraction-free writing experience for macOS with Apple Intelligence integration. Built with SwiftUI.

## Features

### Writing
- **Clean, minimal interface** - Focus on your writing without distractions
- **Sheet organization** - Organize your writing into groups and sheets
- **Markdown support** - Write in Markdown with live preview and LaTeX math
- **Focus mode** - Hide the sidebar and toolbar for a true full-screen writing experience
- **Dark mode** - Comfortable writing in any lighting condition
- **Native macOS app** - Built with SwiftUI for a native experience

### Markdown & Export
- **Full Markdown** - Bold, italic, headings, lists, blockquotes, code blocks, links
- **LaTeX math rendering** - Inline `$...$` and display `$$...$$` math via MathJax
- **Live preview** - Toggle preview with eye icon in toolbar
- **PDF export** - Export your writing to PDF with full formatting

### AI Features (Requires macOS 26.0+ with Apple Intelligence)
- **Proofread** - Check grammar, spelling, and clarity with on-device AI
- **Rewrite** - Rewrite text in different styles (concise, professional, creative, casual)
- **Summarize** - Create concise summaries of your content
- **Generate** - Generate new content from prompts
- **Continue Writing** - AI continues your writing in the same style
- **Expand** - Expand text with more detail and description
- **Change Tone** - Change writing tone (professional, casual, friendly, authoritative, humorous)
- **Outline** - Generate document outlines with headings
- **Character Development** - AI-powered character profile generation
- **Plot Analysis** - Analyze plot structure (exposition, climax, resolution)
- **AI Chat** - Ask questions about your writing
- **AI Suggestions** - Get writing improvement tips
- **AI Analysis** - Analyze tension, pacing, and hooks
- **AI Stats** - View readability, sentiment, word count, and complexity
- **Smart Paste** - Improve pasted text to fit with existing content

### Organization
- **Groups** - Organize sheets into collections
- **Favorites** - Mark important sheets for quick access
- **Search** - Find sheets quickly with search bar
- **Auto-title** - Sheet titles auto-update from first line

## Screenshots

Coming soon.

## Requirements

- macOS 26.0 or later (for AI features)
- macOS 14.0 or later (basic features)
- Apple Intelligence enabled (for AI features)
- Xcode 15 or later (for building from source)

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/anomalyco/Manuscript.git
   ```

2. Open `Manuscript.xcodeproj` in Xcode

3. Build and run the project (⌘R)

## Usage

### Getting Started
- **Blank page** - App starts with blank page and blinking cursor
- **Create a sheet** - Click the pen icon in the toolbar
- **Toggle sidebar** - Use View menu → Show/Hide Sidebar
- **Minimal interface** - Toolbars collapsed by default, click to expand

### Editor
- **Format tools** - Click "Aa" button to show formatting toolbar
- **AI features** - Click brain icon to show AI toolbar
- **Markdown preview** - Toggle preview in the editor toolbar
- **Focus mode** - Click the eye icon to hide distractions
- **Export PDF** - Click export button (↑) to save as PDF

### AI Features
- **Select text** - Select text or place cursor for document-wide AI
- **Click AI button** - Choose from 10+ AI actions
- **Configure options** - Set style, tone, or prompt in the panel
- **Apply result** - Replace selection or insert at cursor

For detailed instructions, see [GETTING_STARTED.md](GETTING_STARTED.md)

## Architecture

Manuscript is built entirely with SwiftUI and follows a simple architecture:

- `DocumentStore` - Observable object managing the app's data (groups, sheets)
- `ContentView` - Main navigation with sidebar and editor
- `SidebarView` - Sheet and group organization with AI stats
- `EditorView` - Markdown editor with preview and AI toolbar
- `AIService` - Core AI service using Apple FoundationModels
- `AIViews` - AI panel, analysis, suggestions, and chat views
- `MarkdownPreview` - WebKit-based preview with LaTeX support
- `SettingsView` - App settings including AI tab

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Icon design inspired by Apple's design language
- Built with SwiftUI and modern macOS frameworks
- Apple Intelligence powered by FoundationModels framework
- LaTeX rendering via MathJax
