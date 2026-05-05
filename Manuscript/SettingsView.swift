import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: DocumentStore
    @EnvironmentObject var aiService: AIService
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
            
            AISettingsView()
                .tabItem {
                    Label("AI", systemImage: "brain")
                }
                .tag(2)
        }
        .frame(width: 400, height: 280)
    }
}

struct GeneralSettingsView: View {
    @State private var launchAtLogin = false
    @State private var autoSave = true
    @AppStorage("appearance") private var appearance = "system"
    
    var body: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchAtLogin)
            Toggle("Auto-save", isOn: $autoSave)
            
            Picker("Appearance", selection: $appearance) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .onChange(of: appearance) { _, newValue in
                updateAppearance(newValue)
            }
        }
        .padding(20)
    }
    
    private func updateAppearance(_ value: String) {
        switch value {
        case "light":
            NSApp.appearance = NSAppearance(named: .aqua)
        case "dark":
            NSApp.appearance = NSAppearance(named: .darkAqua)
        default:
            NSApp.appearance = nil
        }
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

struct AISettingsView: View {
    @EnvironmentObject var aiService: AIService
    
    var body: some View {
        Form {
            Section(header: Text("Apple Intelligence")) {
                HStack {
                    Text("Status:")
                    Spacer()
                    if aiService.isAvailable {
                        Label("Available", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Label("Not Available", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                
                if !aiService.isAvailable {
                    Text("Requires macOS 15.0+ with Apple Intelligence enabled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Actions")) {
                NavigationLink("AI Features") {
                    VStack(alignment: .leading, spacing: 12) {
                        AISettingRow(title: "Proofread", description: "Check grammar and clarity", icon: "checkmark.seal")
                        AISettingRow(title: "Rewrite", description: "Rewrite in different styles", icon: "pencil.and.outline")
                        AISettingRow(title: "Summarize", description: "Create concise summaries", icon: "text.badge.plus")
                        AISettingRow(title: "Generate", description: "Create new content from prompts", icon: "wand.and.stars")
                        AISettingRow(title: "Analyze", description: "Analyze tension, pacing, and hooks", icon: "chart.bar")
                    }
                    .padding()
                }
            }
        }
        .padding(20)
    }
}

struct AISettingRow: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
