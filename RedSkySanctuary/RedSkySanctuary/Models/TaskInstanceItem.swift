import SwiftData
import Foundation

@Model
final class TaskInstanceItem {
    var id: UUID = UUID()
    var title: String = ""
    var isCompleted: Bool = false
    var completedBy: String? = nil
    var completedAt: Date? = nil
    var sortOrder: Int = 0
    
    var instance: TaskInstance?
    
    init(
        title: String = "",
        isCompleted: Bool = false,
        completedBy: String? = nil,
        completedAt: Date? = nil,
        sortOrder: Int = 0
    ) {
        self.title = title
        self.isCompleted = isCompleted
        self.completedBy = completedBy
        self.completedAt = completedAt
        self.sortOrder = sortOrder
    }
    
    func markComplete(by user: String) {
        self.isCompleted = true
        self.completedBy = user
        self.completedAt = .now
    }
}
