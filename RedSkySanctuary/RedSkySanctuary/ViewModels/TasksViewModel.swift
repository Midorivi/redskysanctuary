import Foundation
import Observation
import SwiftData

@Observable
final class TasksViewModel {
    private let currentUserName: String
    private let calendar: Calendar

    init(currentUserName: String = "Sanctuary Team", calendar: Calendar = .current) {
        self.currentUserName = currentUserName
        self.calendar = calendar
    }

    @discardableResult
    func generateDailyInstance(from template: TaskTemplate, for date: Date, in context: ModelContext) -> TaskInstance {
        let targetDate = calendar.startOfDay(for: date)

        if let existing = existingInstance(for: template, on: targetDate, in: context) {
            return existing
        }

        let instance = TaskInstance(date: targetDate, isAdHoc: false)
        instance.template = template

        let templateItems = (template.templateItems ?? []).sorted { lhs, rhs in
            lhs.sortOrder < rhs.sortOrder
        }

        let instanceItems = templateItems.map { templateItem in
            let item = TaskInstanceItem(
                title: templateItem.title,
                sortOrder: templateItem.sortOrder
            )
            item.instance = instance
            return item
        }

        instance.items = instanceItems
        context.insert(instance)
        try? context.save()
        return instance
    }

    func toggleItem(_ item: TaskInstanceItem) {
        item.isCompleted.toggle()

        if item.isCompleted {
            item.completedAt = .now
            item.completedBy = currentUserName
        } else {
            item.completedAt = nil
            item.completedBy = nil
        }

        try? item.modelContext?.save()
    }

    @discardableResult
    func addAdHocTask(title: String, to date: Date, in context: ModelContext) -> TaskInstance? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return nil }

        let targetDate = calendar.startOfDay(for: date)
        let instance = TaskInstance(date: targetDate, isAdHoc: true)
        let item = TaskInstanceItem(title: trimmedTitle, sortOrder: 0)
        item.instance = instance
        instance.items = [item]

        context.insert(instance)
        try? context.save()
        return instance
    }

    @discardableResult
    func createTemplate(
        name: String,
        items: [String],
        isRecurring: Bool,
        pattern: String?,
        in context: ModelContext
    ) -> TaskTemplate? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedItems = items
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !trimmedName.isEmpty, !cleanedItems.isEmpty else { return nil }

        let template = TaskTemplate(
            name: trimmedName,
            isRecurring: isRecurring,
            recurrencePattern: isRecurring ? (pattern ?? RecurrencePattern.daily) : nil
        )

        let templateItems = cleanedItems.enumerated().map { index, title in
            let item = TaskTemplateItem(title: title, sortOrder: index)
            item.template = template
            return item
        }

        template.templateItems = templateItems
        context.insert(template)
        try? context.save()
        return template
    }

    func completionProgress(for instance: TaskInstance) -> (completed: Int, total: Int) {
        let items = sortedItems(for: instance)
        let completed = items.filter(\.isCompleted).count
        return (completed, items.count)
    }

    func generateMissingInstances(for date: Date, templates: [TaskTemplate], in context: ModelContext) {
        let targetDate = calendar.startOfDay(for: date)

        for template in templates where shouldGenerateInstance(for: template, on: targetDate) {
            _ = generateDailyInstance(from: template, for: targetDate, in: context)
        }
    }

    func sortedItems(for instance: TaskInstance) -> [TaskInstanceItem] {
        (instance.items ?? []).sorted { lhs, rhs in
            if lhs.sortOrder == rhs.sortOrder {
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            return lhs.sortOrder < rhs.sortOrder
        }
    }

    private func existingInstance(for template: TaskTemplate, on date: Date, in context: ModelContext) -> TaskInstance? {
        let start = calendar.startOfDay(for: date)
        let descriptor = FetchDescriptor<TaskInstance>()

        return try? context.fetch(descriptor).first(where: { instance in
            instance.isAdHoc == false &&
            instance.template?.id == template.id &&
            calendar.isDate(instance.date, inSameDayAs: start)
        })
    }

    private func shouldGenerateInstance(for template: TaskTemplate, on date: Date) -> Bool {
        guard template.isRecurring else { return false }

        switch template.recurrencePattern ?? RecurrencePattern.daily {
        case RecurrencePattern.daily:
            return true
        case RecurrencePattern.weekly:
            return calendar.component(.weekday, from: date) == calendar.firstWeekday
        case RecurrencePattern.monthly:
            return calendar.component(.day, from: date) == 1
        default:
            return true
        }
    }
}
