import Foundation
import Combine

class Group: Identifiable, ObservableObject {
    let id = UUID()
    var name: String
    @Published var sheets: [Sheet]
    
    init(name: String, sheets: [Sheet] = []) {
        self.name = name
        self.sheets = sheets
    }
}
