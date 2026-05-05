import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Sheet Selected")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Select a sheet from the sidebar or create a new one")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
    }
}

struct EmptyEditorView: View {
    @State private var cursorVisible = true
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(NSColor.textBackgroundColor)
            
            HStack(spacing: 0) {
                if cursorVisible {
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 2, height: 20)
                }
            }
            .padding(.leading, 20)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation {
                    cursorVisible.toggle()
                }
            }
        }
    }
}
