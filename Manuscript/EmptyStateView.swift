import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject var store: DocumentStore
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Sheet Selected")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Select a sheet from the sidebar or create a new one")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(action: { store.createSheet() }) {
                Label("Create New Sheet", systemImage: "plus")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
    }
}
