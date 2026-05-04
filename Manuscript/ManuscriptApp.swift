import SwiftUI

@main
struct ManuscriptApp: App {
    @StateObject private var store = DocumentStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 900, minHeight: 600)
        }
        .commands {
            SidebarCommands()
            TextEditingCommands()
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1200, height: 800)
        
        Settings {
            SettingsView()
                .environmentObject(store)
        }
    }
}
