import Foundation
import Observation

@Observable
final class DashboardViewModel {

    private static let severityOrder: [String: Int] = [
        Severity.severe: 0,
        Severity.moderate: 1,
        Severity.mild: 2
    ]

    func todaysTaskProgress(instances: [TaskInstance]) -> (completed: Int, total: Int) {
        var completed = 0
        var total = 0

        for instance in instances {
            let items = instance.items ?? []
            total += items.count
            completed += items.filter(\.isCompleted).count
        }

        return (completed, total)
    }

    func upcomingEvents(
        reminders: [Reminder],
        records: [HealthRecord],
        tasks: [MaintenanceTask]
    ) -> [(title: String, date: Date, type: String)] {
        let now = Date.now
        var events: [(title: String, date: Date, type: String)] = []

        for reminder in reminders where !reminder.isCompleted && reminder.date > now {
            events.append((reminder.title, reminder.date, "reminder"))
        }

        for record in records {
            if let nextVisit = record.nextVisitDate, nextVisit > now {
                events.append((record.title, nextVisit, "vet_visit"))
            }
        }

        for task in tasks {
            if let dueDate = task.nextDueDate, dueDate > now {
                events.append((task.title, dueDate, "maintenance"))
            }
        }

        return events
            .sorted { $0.date < $1.date }
            .prefix(3)
            .map { $0 }
    }

    func attentionItems(
        signs: [HealthSign],
        tasks: [MaintenanceTask],
        inventory: [InventoryItem]
    ) -> [(title: String, type: String, severity: String)] {
        var items: [(title: String, type: String, severity: String)] = []

        let unresolvedSigns = signs
            .filter { !$0.isResolved }
            .sorted { lhs, rhs in
                let lhsOrder = Self.severityOrder[lhs.severity] ?? 3
                let rhsOrder = Self.severityOrder[rhs.severity] ?? 3
                return lhsOrder < rhsOrder
            }

        for sign in unresolvedSigns {
            let animalName = sign.animal?.displayName
            let title = animalName.map { "\($0): \(sign.symptom)" } ?? sign.symptom
            items.append((title, "health", sign.severity))
        }

        let now = Date.now
        for task in tasks {
            if let dueDate = task.nextDueDate, dueDate < now {
                items.append((task.title, "maintenance", "overdue"))
            }
        }

        for item in inventory where item.isLowStock {
            items.append((item.name, "inventory", "low"))
        }

        return items
    }

    func animalCountByType(animals: [Animal]) -> [(type: String, count: Int)] {
        var grouped: [String: Int] = [:]

        for animal in animals {
            grouped[animal.animalType, default: 0] += 1
        }

        return grouped
            .map { (type: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
}
