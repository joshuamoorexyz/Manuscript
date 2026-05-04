import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DocumentStore
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var isFocusMode = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(isFocusMode: $isFocusMode)
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
        } detail: {
            if let sheet = store.selectedSheet {
                EditorView(sheet: sheet, isFocusMode: $isFocusMode, columnVisibility: $columnVisibility)
                    .id(sheet.id)
            } else {
                EmptyStateView()
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    withAnimation {
                        if columnVisibility == .all {
                            columnVisibility = .detailOnly
                        } else {
                            columnVisibility = .all
                        }
                    }
                }) {
                    Image(systemName: "sidebar.left")
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isFocusMode.toggle()
                }) {
                    Image(systemName: isFocusMode ? "eye.slash" : "eye")
                }
                .help("Toggle Focus Mode")
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: { store.createSheet() }) {
                    Image(systemName: "square.and.pencil")
                }
                .help("New Sheet")
            }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}
