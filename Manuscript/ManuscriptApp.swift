import SwiftUI

@main
struct ManuscriptApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DocumentStore())
        }
    }
}
