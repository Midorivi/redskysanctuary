import SwiftUI
import SwiftData

@MainActor @Observable
final class MaintenanceViewModel {

    // MARK: - CRUD

    func createTask(
        title: String,
        category: String,
        notes: String? = nil,
        isRecurring: Bool = false,
        recurrencePattern: String? = nil,
        nextDueDate: Date? = nil,
        in context: ModelContext
    ) {
        let task = MaintenanceTask(
            title: title,
            category: category,
            notes: notes,
            isRecurring: isRecurring,
            recurrencePattern: recurrencePattern,
            nextDueDate: nextDueDate
        )
        context.insert(task)
    }

    func markComplete(_ task: MaintenanceTask) {
        task.lastCompletedDate = .now
        task.completedBy = "Staff"

        if task.isRecurring, let pattern = task.recurrencePattern {
            let baseDate = task.nextDueDate ?? .now
            task.nextDueDate = nextDate(from: baseDate, pattern: pattern)
        }
    }

    func deleteTask(_ task: MaintenanceTask, in context: ModelContext) {
        context.delete(task)
    }

    // MARK: - Queries

    func overdueTasks(from tasks: [MaintenanceTask]) -> [MaintenanceTask] {
        let now = Date.now
        return tasks.filter { task in
            guard let dueDate = task.nextDueDate else { return false }
            return dueDate < now
        }
    }

    // MARK: - Helpers

    private func nextDate(from date: Date, pattern: String) -> Date {
        let calendar = Calendar.current
        switch pattern {
        case RecurrencePattern.daily:
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case RecurrencePattern.weekly:
            return calendar.date(byAdding: .day, value: 7, to: date) ?? date
        case RecurrencePattern.monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        default:
            return date
        }
    }
}
