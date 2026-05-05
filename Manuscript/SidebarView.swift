import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var store: DocumentStore
    @EnvironmentObject var aiService: AIService
    @Binding var isFocusMode: Bool
    @State private var searchText = ""
    @State private var showAIAnalysis = false
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            
            List(store.groups, id: \.id) { group in
                Section(header: GroupHeader(name: group.name)) {
                    ForEach(group.sheets, id: \.id) { sheet in
                        SheetRow(sheet: sheet)
                            .onTapGesture {
                                store.selectedSheet = sheet
                            }
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    store.deleteSheet(sheet)
                                }
                                Button(sheet.isFavorite ? "Remove from Favorites" : "Add to Favorites") {
                                    store.toggleFavorite(sheet)
                                }
                            }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            
            Divider()
            
            if let selectedSheet = store.selectedSheet, aiService.isAvailable {
                Button(action: { showAIAnalysis = true }) {
                    Label("Analyze with AI", systemImage: "chart.bar")
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(8)
                .sheet(isPresented: $showAIAnalysis) {
                    AIAnalysisView(sheet: selectedSheet)
                        .environmentObject(aiService)
                }
                
                NavigationLink {
                    AIChatView(sheet: selectedSheet)
                        .environmentObject(aiService)
                } label: {
                    Label("AI Chat", systemImage: "message")
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(8)
                
                AIStatsView(sheet: selectedSheet)
                    .padding(.horizontal, 8)
            }
            
            HStack {
                Button(action: { store.createSheet() }) {
                    Label("New Sheet", systemImage: "plus")
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(8)
                
                Spacer()
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .disabled(isFocusMode)
    }
}

struct GroupHeader: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }
}

struct SheetRow: View {
    let sheet: Sheet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(sheet.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Spacer()
                if sheet.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 10))
                }
            }
            
            Text(sheet.content.prefix(60))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(sheet.lastModified, style: .date)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search sheets...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(6)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
}
