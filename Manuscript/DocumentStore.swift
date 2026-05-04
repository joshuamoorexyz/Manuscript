import Foundation
import SwiftUI

class DocumentStore: ObservableObject {
    @Published var sheets: [Sheet] = []
    @Published var selectedSheet: Sheet?
    
    init() {
        let welcome = Sheet(title: "Welcome", content: "Welcome to Manuscript")
        sheets = [welcome]
        selectedSheet = welcome
    }
    
    func createSheet() {
        let sheet = Sheet(title: "Untitled", content: "")
        sheets.insert(sheet, at: 0)
        selectedSheet = sheet
    }
}
