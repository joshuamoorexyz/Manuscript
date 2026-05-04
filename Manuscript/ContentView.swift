import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DocumentStore
    @State private var showSidebar = true
    @State private var isFocusMode = false
    
    var body: some View {
        NavigationView {
            if showSidebar && !isFocusMode {
                SidebarView(isFocusMode: $isFocusMode)
                    .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
            }
            
            if let sheet = store.selectedSheet {
                EditorView(sheet: sheet, isFocusMode: $isFocusMode)
                    .id(sheet.id)
            } else {
                EmptyStateView()
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    showSidebar.toggle()
                }) {
                    Image(systemName: "sidebar.left")
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: { 
                    withAnimation {
                        isFocusMode.toggle()
                    }
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
