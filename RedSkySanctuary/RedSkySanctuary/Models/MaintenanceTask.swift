import SwiftData
import Foundation

@Model
final class MaintenanceTask {
    var id: UUID = UUID()
    var title: String = ""
    var category: String = "property"
    var notes: String? = nil
    var isRecurring: Bool = false
    var recurrencePattern: String? = nil
    var nextDueDate: Date? = nil
    var lastCompletedDate: Date? = nil
    var completedBy: String? = nil
    
    init(
        title: String = "",
        category: String = "property",
        notes: String? = nil,
        isRecurring: Bool = false,
        recurrencePattern: String? = nil,
        nextDueDate: Date? = nil,
        lastCompletedDate: Date? = nil,
        completedBy: String? = nil
    ) {
        self.title = title
        self.category = category
        self.notes = notes
        self.isRecurring = isRecurring
        self.recurrencePattern = recurrencePattern
        self.nextDueDate = nextDueDate
        self.lastCompletedDate = lastCompletedDate
        self.completedBy = completedBy
    }
}

struct MaintenanceCategory {
    static let property = "property"
    static let animal_care = "animal_care"
}
