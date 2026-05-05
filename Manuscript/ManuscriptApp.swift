import SwiftUI

@main
struct ManuscriptApp: App {
    @StateObject private var store = DocumentStore()
    @StateObject private var aiService: AIService
    
    init() {
        if #available(macOS 15.0, *) {
            _aiService = StateObject(wrappedValue: AIService())
        } else {
            _aiService = StateObject(wrappedValue: AIService())
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(aiService)
                .frame(minWidth: 900, minHeight: 600)
        }
        .commands {
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
