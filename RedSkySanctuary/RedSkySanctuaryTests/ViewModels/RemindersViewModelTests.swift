import Foundation
import SwiftData
import Testing

@testable import RedSkySanctuary

@MainActor
@Suite("RemindersViewModel Tests")
struct RemindersViewModelTests {

    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Reminder.self, Animal.self, AnimalPhoto.self, HealthRecord.self, HealthSign.self,
            configurations: config
        )
    }

    @Test("createReminder inserts a reminder into the context")
    func createReminder() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let vm = RemindersViewModel()

        let reminder = vm.createReminder(
            title: "Muzzle horses every spring",
            notes: "Check all pasture horses",
            date: Date(timeIntervalSince1970: 1_700_000_000),
            isRecurring: true,
            recurrencePattern: ReminderRecurrence.yearly,
            in: context
        )

        #expect(reminder != nil)
        #expect(reminder?.title == "Muzzle horses every spring")
        #expect(reminder?.isRecurring == true)
        #expect(reminder?.recurrencePattern == ReminderRecurrence.yearly)

        let all = try context.fetch(FetchDescriptor<Reminder>())
        #expect(all.count == 1)
    }

    @Test("createReminder rejects empty title")
    func createReminderRejectsEmpty() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let vm = RemindersViewModel()

        let result = vm.createReminder(title: "   ", in: context)

        #expect(result == nil)
        let all = try context.fetch(FetchDescriptor<Reminder>())
        #expect(all.count == 0)
    }

    @Test("completeReminder sets isCompleted to true")
    func completeReminder() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let reminder = Reminder(title: "Deworm goats", date: .now)
        context.insert(reminder)
        try context.save()

        #expect(reminder.isCompleted == false)

        let vm = RemindersViewModel()
        vm.completeReminder(reminder)

        #expect(reminder.isCompleted == true)
    }

    @Test("deleteReminder removes reminder from context")
    func deleteReminder() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let reminder = Reminder(title: "Check fences", date: .now)
        context.insert(reminder)
        try context.save()

        let vm = RemindersViewModel()
        vm.deleteReminder(reminder, in: context)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<Reminder>())
        #expect(remaining.count == 0)
    }

    @Test("upcomingReminders returns incomplete reminders sorted by date")
    func upcomingRemindersFilter() {
        let early = Reminder(title: "Early", date: Date(timeIntervalSince1970: 1_000))
        let late = Reminder(title: "Late", date: Date(timeIntervalSince1970: 2_000))
        let completed = Reminder(title: "Done", date: Date(timeIntervalSince1970: 500), isCompleted: true)

        let vm = RemindersViewModel()
        let upcoming = vm.upcomingReminders(from: [late, completed, early])

        #expect(upcoming.count == 2)
        #expect(upcoming[0].title == "Early")
        #expect(upcoming[1].title == "Late")
    }

    @Test("recurringReminders returns only recurring reminders")
    func recurringRemindersFilter() {
        let recurring = Reminder(title: "Monthly check", isRecurring: true, recurrencePattern: ReminderRecurrence.monthly)
        let oneTime = Reminder(title: "One-off task", isRecurring: false)

        let vm = RemindersViewModel()
        let result = vm.recurringReminders(from: [recurring, oneTime])

        #expect(result.count == 1)
        #expect(result[0].title == "Monthly check")
    }

    @Test("createReminder links related animal")
    func createReminderWithAnimal() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let animal = Animal(name: "Rosie", animalType: AnimalType.horse)
        context.insert(animal)
        try context.save()

        let vm = RemindersViewModel()
        let reminder = vm.createReminder(
            title: "Farrier visit for Rosie",
            date: .now,
            relatedAnimal: animal,
            in: context
        )

        #expect(reminder?.relatedAnimal?.name == "Rosie")
    }
}
