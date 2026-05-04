import Foundation

class Sheet: Identifiable, ObservableObject {
    let id = UUID()
    @Published var title: String
    @Published var content: String
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}
