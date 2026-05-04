import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: DocumentStore
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)
            
            EditorSettingsView()
                .tabItem {
                    Label("Editor", systemImage: "pencil")
                }
                .tag(1)
        }
        .frame(width: 400, height: 250)
    }
}

struct GeneralSettingsView: View {
    @State private var launchAtLogin = false
    @State private var autoSave = true
    
    var body: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchAtLogin)
            Toggle("Auto-save", isOn: $autoSave)
        }
        .padding(20)
    }
}

struct EditorSettingsView: View {
    @State private var fontSize: Double = 16
    @State private var lineSpacing: Double = 6
    @State private var showLineNumbers = false
    
    var body: some View {
        Form {
            VStack(alignment: .leading) {
                Text("Font Size: \(Int(fontSize))")
                Slider(value: $fontSize, in: 12...24, step: 1)
            }
            
            VStack(alignment: .leading) {
                Text("Line Spacing: \(Int(lineSpacing))")
                Slider(value: $lineSpacing, in: 4...12, step: 1)
            }
            
            Toggle("Show Line Numbers", isOn: $showLineNumbers)
        }
        .padding(20)
    }
}
