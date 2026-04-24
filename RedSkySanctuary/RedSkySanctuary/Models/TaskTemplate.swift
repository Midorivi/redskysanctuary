import SwiftData
import Foundation

@Model
final class TaskTemplate {
    var id: UUID = UUID()
    var name: String = ""
    var isRecurring: Bool = true
    var recurrencePattern: String? = "daily"
    var createdAt: Date = Date.now
    
    @Relationship(deleteRule: .cascade, inverse: \TaskTemplateItem.template)
    var templateItems: [TaskTemplateItem]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \TaskInstance.template)
    var instances: [TaskInstance]? = []
    
    init(
        name: String = "",
        isRecurring: Bool = true,
        recurrencePattern: String? = "daily"
    ) {
        self.name = name
        self.isRecurring = isRecurring
        self.recurrencePattern = recurrencePattern
    }
    
    var displayName: String {
        name.isEmpty ? "Unnamed Task" : name
    }
}

struct RecurrencePattern {
    static let daily = "daily"
    static let weekly = "weekly"
    static let monthly = "monthly"
}
