# Apple Intelligence Features Added to Manuscript

## Overview
Added comprehensive Apple Intelligence (Foundation Models) integration to the Manuscript writing app, enabling on-device AI features powered by Apple's ~3B parameter language model.

## Files Created/Modified

### New Files
- **AIService.swift** - Core AI service using FoundationModels framework
- **AIViews.swift** - AI panel and analysis views
- **AISuggestionsView.swift** - AI writing suggestions
- **AI_FEATURES.md** - This documentation

### Modified Files
- **ManuscriptApp.swift** - Added AIService as environment object
- **EditorView.swift** - Added AI toolbar buttons and suggestions panel
- **SidebarView.swift** - Added AI analysis button
- **SettingsView.swift** - Added AI settings tab
- **project.pbxproj** - Updated macOS deployment target to 15.0

## AI Features Added

### 1. Text Editing AI Actions
- **Proofread** - Grammar, spelling, and clarity checking
- **Rewrite** - Rewrite text in different styles (concise, professional, creative, casual)
- **Summarize** - Create concise 2-3 sentence summaries
- **Generate** - Generate new content from prompts
- **Continue Writing** - AI-powered text continuation
- **Expand** - Expand text with more detail and description
- **Change Tone** - Change writing tone (professional, casual, friendly, authoritative, humorous)

### 2. AI Analysis
- **Text Analysis** - Analyze tension, pacing, and hooks
- **AI Suggestions** - Get writing improvement suggestions

### 3. User Interface
- **AI Toolbar** - Quick access buttons in editor toolbar
- **AI Panel** - Modal panel for AI actions with style/tone pickers
- **AI Analysis View** - Detailed analysis view in sidebar
- **AI Suggestions** - Live suggestions below editor
- **AI Settings** - Settings tab showing AI status and features

### 4. Keyboard Shortcuts
- `Cmd+Shift+Return` - Quick proofread
- `Cmd+Shift+G` - Quick generate

## Technical Details

### Requirements
- macOS 15.0+ (Sequoia)
- Apple Intelligence enabled on device
- FoundationModels framework (introduced WWDC 2025)

### Architecture
- `AIService` class marked with `@Observable` for SwiftUI reactivity
- Uses `LanguageModelSession` for on-device inference
- Proper availability checks with `#available` and `@available` attributes
- Conditional imports with `#if canImport(FoundationModels)`

### Error Handling
- Graceful degradation when AI not available
- User-friendly error messages
- Loading states during generation

## Usage

1. Ensure macOS 15.0+ and Apple Intelligence enabled
2. Open Manuscript - AI features appear automatically when available
3. Select text in editor and click AI toolbar buttons
4. Use keyboard shortcuts for quick access
5. View AI analysis from sidebar button
6. Check AI status in Settings > AI tab

## Future Enhancements
- Cloud AI support (BYOK for OpenAI, Anthropic, Gemini)
- Custom AI prompts and templates
- AI writing statistics and insights
- Chapter generation with context awareness
- AI-powered search and organization
