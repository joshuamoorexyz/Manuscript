# Manuscript

A distraction-free writing experience for macOS. Built with SwiftUI.

## Features

- **Clean, minimal interface** - Focus on your writing without distractions
- **Sheet organization** - Organize your writing into groups and sheets
- **Markdown support** - Write in Markdown with live preview
- **Focus mode** - Hide the sidebar and toolbar for a true full-screen writing experience
- **Dark mode** - Comfortable writing in any lighting condition
- **Native macOS app** - Built with SwiftUI for a native experience

## Screenshots

Coming soon.

## Requirements

- macOS 14.0 or later
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

- **Create a new sheet** - Click the pen icon in the toolbar or use the sidebar
- **Toggle sidebar** - Click the sidebar button or use the menu
- **Focus mode** - Click the eye icon to hide distractions
- **Markdown preview** - Toggle preview in the editor toolbar
- **Organize** - Create groups in the sidebar to organize your sheets
- **Favorites** - Right-click any sheet to add to Favorites

## Architecture

Manuscript is built entirely with SwiftUI and follows a simple architecture:

- `DocumentStore` - Observable object managing the app's data (groups, sheets)
- `ContentView` - Main navigation with sidebar and editor
- `SidebarView` - Sheet and group organization
- `EditorView` - Markdown editor with preview
- `SettingsView` - App settings

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Icon design inspired by Apple's design language
- Built with SwiftUI and modern macOS frameworks
