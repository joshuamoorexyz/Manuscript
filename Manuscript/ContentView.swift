import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DocumentStore
    
    var body: some View {
        NavigationView {
            List(store.sheets) { sheet in
                VStack(alignment: .leading) {
                    Text(sheet.title)
                        .font(.headline)
                    Text(String(sheet.content.prefix(50)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    store.selectedSheet = sheet
                }
            }
            .frame(minWidth: 200)
            
            if let sheet = store.selectedSheet {
                TextEditor(text: Binding(
                    get: { sheet.content },
                    set: { sheet.content = $0 }
                ))
                .font(.system(size: 16))
                .padding()
                .navigationTitle(sheet.title)
            } else {
                Text("Select a sheet")
                    .foregroundColor(.secondary)
            }
        }
        .toolbar {
            Button(action: { store.createSheet() }) {
                Image(systemName: "plus")
            }
        }
    }
}
