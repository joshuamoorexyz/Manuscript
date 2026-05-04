import Foundation
import Combine

class Sheet: Identifiable, ObservableObject {
    let id = UUID()
    @Published var title: String
    @Published var content: String
    @Published var isFavorite: Bool
    @Published var lastModified = Date()
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
        self.isFavorite = false
    }
    
    func updateTitle() {
        let firstLine = content.components(separatedBy: .newlines).first ?? ""
        let cleaned = firstLine.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespaces)
        if !cleaned.isEmpty && title == "Untitled" {
            title = String(cleaned.prefix(50))
        }
    }
    
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
