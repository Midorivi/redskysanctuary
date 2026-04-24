import Foundation
import Observation
import SwiftData

@Observable
final class RemindersViewModel {

    // MARK: - CRUD

    @discardableResult
    func createReminder(
        title: String,
        notes: String? = nil,
        date: Date = .now,
        isRecurring: Bool = false,
        recurrencePattern: String? = nil,
        recurrenceEndDate: Date? = nil,
        relatedAnimal: Animal? = nil,
        in context: ModelContext
    ) -> Reminder? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let reminder = Reminder(
            title: trimmed,
            notes: notes,
            date: date,
            isRecurring: isRecurring,
            recurrencePattern: isRecurring ? recurrencePattern : nil,
            recurrenceEndDate: isRecurring ? recurrenceEndDate : nil,
            relatedAnimal: relatedAnimal
        )
        context.insert(reminder)
        try? context.save()
        return reminder
    }

    func completeReminder(_ reminder: Reminder) {
        reminder.isCompleted = true
        try? reminder.modelContext?.save()
    }

    func deleteReminder(_ reminder: Reminder, in context: ModelContext) {
        context.delete(reminder)
        try? context.save()
    }

    // MARK: - Filters

    func upcomingReminders(from reminders: [Reminder]) -> [Reminder] {
        reminders
            .filter { !$0.isCompleted }
            .sorted { $0.date < $1.date }
    }

    func recurringReminders(from reminders: [Reminder]) -> [Reminder] {
        reminders.filter(\.isRecurring)
    }

    func completedReminders(from reminders: [Reminder]) -> [Reminder] {
        reminders
            .filter(\.isCompleted)
            .sorted { $0.date > $1.date }
    }
}
