import Foundation
import SwiftData
import Testing

@testable import RedSkySanctuary

@MainActor
@Suite("DashboardViewModel Tests")
struct DashboardViewModelTests {

    private let viewModel = DashboardViewModel()

    // MARK: - todaysTaskProgress

    @Test("todaysTaskProgress aggregates completed and total items across instances")
    func todaysTaskProgressAggregatesAcrossInstances() {
        let first = TaskInstance(date: .now, isAdHoc: false)
        first.items = [
            TaskInstanceItem(title: "Feed horses", isCompleted: true, completedBy: "A", completedAt: .now, sortOrder: 0),
            TaskInstanceItem(title: "Refresh water", sortOrder: 1)
        ]

        let second = TaskInstance(date: .now, isAdHoc: true)
        second.items = [
            TaskInstanceItem(title: "Check fence", isCompleted: true, completedBy: "B", completedAt: .now, sortOrder: 0)
        ]

        let progress = viewModel.todaysTaskProgress(instances: [first, second])

        #expect(progress.completed == 2)
        #expect(progress.total == 3)
    }

    @Test("todaysTaskProgress returns zero for empty instances")
    func todaysTaskProgressEmptyInstances() {
        let progress = viewModel.todaysTaskProgress(instances: [])

        #expect(progress.completed == 0)
        #expect(progress.total == 0)
    }

    // MARK: - upcomingEvents

    @Test("upcomingEvents sorts by date ascending and limits to 3")
    func upcomingEventsSortedAndLimited() {
        let now = Date.now
        let oneDay: TimeInterval = 86_400

        let r1 = Reminder(title: "Farrier visit", date: now.addingTimeInterval(oneDay * 3))
        let r2 = Reminder(title: "Order hay", date: now.addingTimeInterval(oneDay))

        let record = HealthRecord(
            date: now,
            recordType: RecordType.vetVisit,
            title: "Goat checkup",
            nextVisitDate: now.addingTimeInterval(oneDay * 2)
        )

        let task = MaintenanceTask(
            title: "Fix barn door",
            nextDueDate: now.addingTimeInterval(oneDay * 4)
        )

        let extraReminder = Reminder(title: "Budget review", date: now.addingTimeInterval(oneDay * 5))

        let events = viewModel.upcomingEvents(
            reminders: [r1, r2, extraReminder],
            records: [record],
            tasks: [task]
        )

        #expect(events.count == 3)
        #expect(events[0].title == "Order hay")
        #expect(events[1].title == "Goat checkup")
        #expect(events[2].title == "Farrier visit")
    }

    @Test("upcomingEvents excludes past and completed reminders")
    func upcomingEventsExcludesPastAndCompleted() {
        let now = Date.now
        let oneDay: TimeInterval = 86_400

        let past = Reminder(title: "Old reminder", date: now.addingTimeInterval(-oneDay))
        let completed = Reminder(title: "Done reminder", date: now.addingTimeInterval(oneDay), isCompleted: true)
        let future = Reminder(title: "Future reminder", date: now.addingTimeInterval(oneDay * 2))

        let events = viewModel.upcomingEvents(
            reminders: [past, completed, future],
            records: [],
            tasks: []
        )

        #expect(events.count == 1)
        #expect(events[0].title == "Future reminder")
    }

    // MARK: - attentionItems

    @Test("attentionItems includes unresolved health signs with severe first")
    func attentionItemsUnresolvedSignsSeverityOrder() {
        let mild = HealthSign(symptom: "Sneezing", severity: Severity.mild)
        let severe = HealthSign(symptom: "Limping", severity: Severity.severe)
        let resolved = HealthSign(symptom: "Cough", severity: Severity.moderate, isResolved: true)
        let moderate = HealthSign(symptom: "Low appetite", severity: Severity.moderate)

        let items = viewModel.attentionItems(
            signs: [mild, severe, resolved, moderate],
            tasks: [],
            inventory: []
        )

        let healthItems = items.filter { $0.type == "health" }
        #expect(healthItems.count == 3)
        #expect(healthItems[0].severity == Severity.severe)
        #expect(healthItems[1].severity == Severity.moderate)
        #expect(healthItems[2].severity == Severity.mild)
    }

    @Test("attentionItems includes overdue maintenance tasks")
    func attentionItemsOverdueMaintenance() {
        let yesterday = Date.now.addingTimeInterval(-86_400)
        let overdue = MaintenanceTask(title: "Replace fence post", nextDueDate: yesterday)
        let future = MaintenanceTask(title: "Paint barn", nextDueDate: Date.now.addingTimeInterval(86_400 * 7))

        let items = viewModel.attentionItems(
            signs: [],
            tasks: [overdue, future],
            inventory: []
        )

        let maintenanceItems = items.filter { $0.type == "maintenance" }
        #expect(maintenanceItems.count == 1)
        #expect(maintenanceItems[0].title == "Replace fence post")
    }

    @Test("attentionItems includes low stock inventory")
    func attentionItemsLowStock() {
        let low = InventoryItem(name: "Horse feed", quantity: 2, reorderThreshold: 5)
        let fine = InventoryItem(name: "Bedding", quantity: 10, reorderThreshold: 3)
        let noThreshold = InventoryItem(name: "Tools", quantity: 1)

        let items = viewModel.attentionItems(
            signs: [],
            tasks: [],
            inventory: [low, fine, noThreshold]
        )

        let inventoryItems = items.filter { $0.type == "inventory" }
        #expect(inventoryItems.count == 1)
        #expect(inventoryItems[0].title == "Horse feed")
    }

    // MARK: - animalCountByType

    @Test("animalCountByType groups and sorts by count descending")
    func animalCountByTypeGroupsCorrectly() {
        let animals = [
            Animal(name: "Buddy", animalType: AnimalType.horse),
            Animal(name: "Star", animalType: AnimalType.horse),
            Animal(name: "Daisy", animalType: AnimalType.horse),
            Animal(name: "Billy", animalType: AnimalType.goat),
            Animal(name: "Nanny", animalType: AnimalType.goat),
            Animal(name: "Wilbur", animalType: AnimalType.pig)
        ]

        let counts = viewModel.animalCountByType(animals: animals)

        #expect(counts.count == 3)
        #expect(counts[0].type == AnimalType.horse)
        #expect(counts[0].count == 3)
        #expect(counts[1].type == AnimalType.goat)
        #expect(counts[1].count == 2)
        #expect(counts[2].type == AnimalType.pig)
        #expect(counts[2].count == 1)
    }

    @Test("animalCountByType returns empty for no animals")
    func animalCountByTypeEmpty() {
        let counts = viewModel.animalCountByType(animals: [])

        #expect(counts.isEmpty)
    }
}
