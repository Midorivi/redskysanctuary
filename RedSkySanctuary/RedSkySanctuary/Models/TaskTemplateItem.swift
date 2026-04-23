import SwiftData
import Foundation

@Model
final class TaskTemplateItem {
    var id: UUID = UUID()
    var title: String = ""
    var sortOrder: Int = 0
    
    var template: TaskTemplate?
    
    init(
        title: String = "",
        sortOrder: Int = 0
    ) {
        self.title = title
        self.sortOrder = sortOrder
    }
}
