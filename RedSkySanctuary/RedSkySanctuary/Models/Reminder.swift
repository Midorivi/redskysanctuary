import SwiftData
import Foundation

@Model
final class Reminder {
    var id: UUID = UUID()
    var title: String = ""
    var notes: String? = nil
    var date: Date = .now
    var isRecurring: Bool = false
    var recurrencePattern: String? = nil
    var recurrenceEndDate: Date? = nil
    var isCompleted: Bool = false
    var notificationIdentifier: String? = nil
    
    var relatedAnimal: Animal? = nil
    
    init(
        title: String = "",
        notes: String? = nil,
        date: Date = .now,
        isRecurring: Bool = false,
        recurrencePattern: String? = nil,
        recurrenceEndDate: Date? = nil,
        isCompleted: Bool = false,
        notificationIdentifier: String? = nil,
        relatedAnimal: Animal? = nil
    ) {
        self.title = title
        self.notes = notes
        self.date = date
        self.isRecurring = isRecurring
        self.recurrencePattern = recurrencePattern
        self.recurrenceEndDate = recurrenceEndDate
        self.isCompleted = isCompleted
        self.notificationIdentifier = notificationIdentifier
        self.relatedAnimal = relatedAnimal
    }
}

struct ReminderRecurrence {
    static let yearly = "yearly"
    static let monthly = "monthly"
    static let weekly = "weekly"
    static let daily = "daily"
}
