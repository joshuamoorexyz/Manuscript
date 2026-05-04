import Foundation
import Combine

class DocumentStore: ObservableObject {
    @Published var groups: [Group] = []
    @Published var sheets: [Sheet] = []
    @Published var selectedSheet: Sheet?
    @Published var selectedGroup: Group?
    @Published var searchText = ""
    
    init() {
        let welcome = Sheet(title: "Welcome to Manuscript", content: """
# Welcome to Manuscript

A distraction-free writing experience for macOS.

## Features
- Clean, minimal interface
- Markdown support
- Sheet organization
- Focus mode
- Dark mode

Start writing here...
""")
        
        let tips = Sheet(title: "Writing Tips", content: """
# Writing Tips

1. **Focus** - Eliminate distractions
2. **Flow** - Keep writing without stopping
3. **Edit later** - First draft, then refine
""")
        
        let inbox = Group(name: "Inbox", sheets: [welcome, tips])
        let drafts = Group(name: "Drafts", sheets: [])
        let favorites = Group(name: "Favorites", sheets: [])
        
        groups = [inbox, drafts, favorites]
        sheets = [welcome, tips]
        selectedSheet = welcome
        selectedGroup = inbox
    }
    
    var filteredSheets: [Sheet] {
        if searchText.isEmpty {
            return selectedGroup?.sheets ?? sheets
        }
        return sheets.filter { sheet in
            sheet.title.localizedCaseInsensitiveContains(searchText) ||
            sheet.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func createSheet() {
        let sheet = Sheet(title: "Untitled", content: "")
        sheets.insert(sheet, at: 0)
        if let group = selectedGroup {
            group.sheets.insert(sheet, at: 0)
        } else if let inbox = groups.first {
            inbox.sheets.insert(sheet, at: 0)
        }
        selectedSheet = sheet
    }
    
    func deleteSheet(_ sheet: Sheet) {
        sheets.removeAll { $0.id == sheet.id }
        for group in groups {
            group.sheets.removeAll { $0.id == sheet.id }
        }
        if selectedSheet?.id == sheet.id {
            selectedSheet = sheets.first
        }
    }
    
    func toggleFavorite(_ sheet: Sheet) {
        if let index = sheets.firstIndex(where: { $0.id == sheet.id }) {
            sheets[index].isFavorite.toggle()
            if sheets[index].isFavorite {
                groups.first { $0.name == "Favorites" }?.sheets.append(sheets[index])
            } else {
                groups.first { $0.name == "Favorites" }?.sheets.removeAll { $0.id == sheet.id }
            }
        }
    }
}
