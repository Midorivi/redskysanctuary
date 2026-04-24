import Testing
import SwiftData
@testable import RedSkySanctuary

@Suite("MaintenanceViewModel Tests")
struct MaintenanceViewModelTests {

    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: MaintenanceTask.self,
            configurations: config
        )
    }

    @Test("createTask inserts a task into the context")
    func createTask() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let vm = MaintenanceViewModel()

        vm.createTask(
            title: "Fix barn door",
            category: MaintenanceCategory.property,
            notes: "Hinge is loose",
            isRecurring: false,
            in: context
        )
        try context.save()

        let tasks = try context.fetch(FetchDescriptor<MaintenanceTask>())
        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "Fix barn door")
        #expect(tasks.first?.category == MaintenanceCategory.property)
        #expect(tasks.first?.notes == "Hinge is loose")
    }

    @Test("markComplete sets lastCompletedDate")
    func markCompleteSetsDate() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let task = MaintenanceTask(
            title: "Deworm horses",
            category: MaintenanceCategory.animal_care
        )
        context.insert(task)
        #expect(task.lastCompletedDate == nil)

        let vm = MaintenanceViewModel()
        vm.markComplete(task)

        #expect(task.lastCompletedDate != nil)
        #expect(task.completedBy == "Staff")
    }

    @Test("markComplete calculates next due date for recurring weekly task")
    func markCompleteRecurringWeekly() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let dueDate = Date.now
        let task = MaintenanceTask(
            title: "Check fences",
            category: MaintenanceCategory.property,
            isRecurring: true,
            recurrencePattern: RecurrencePattern.weekly,
            nextDueDate: dueDate
        )
        context.insert(task)

        let vm = MaintenanceViewModel()
        vm.markComplete(task)

        let expected = Calendar.current.date(byAdding: .day, value: 7, to: dueDate)!
        let diff = abs(task.nextDueDate!.timeIntervalSince(expected))
        #expect(diff < 1)
    }

    @Test("markComplete calculates next due date for recurring monthly task")
    func markCompleteRecurringMonthly() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let dueDate = Date.now
        let task = MaintenanceTask(
            title: "Farrier visit",
            category: MaintenanceCategory.animal_care,
            isRecurring: true,
            recurrencePattern: RecurrencePattern.monthly,
            nextDueDate: dueDate
        )
        context.insert(task)

        let vm = MaintenanceViewModel()
        vm.markComplete(task)

        let expected = Calendar.current.date(byAdding: .month, value: 1, to: dueDate)!
        let diff = abs(task.nextDueDate!.timeIntervalSince(expected))
        #expect(diff < 1)
    }

    @Test("overdueTasks returns only tasks past due date")
    func overdueDetection() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let pastDate = Calendar.current.date(byAdding: .day, value: -3, to: .now)!
        let futureDate = Calendar.current.date(byAdding: .day, value: 3, to: .now)!

        let overdueTask = MaintenanceTask(
            title: "Overdue fence repair",
            category: MaintenanceCategory.property,
            nextDueDate: pastDate
        )
        let upcomingTask = MaintenanceTask(
            title: "Future barn cleaning",
            category: MaintenanceCategory.property,
            nextDueDate: futureDate
        )
        let noDateTask = MaintenanceTask(
            title: "No date task",
            category: MaintenanceCategory.animal_care
        )
        context.insert(overdueTask)
        context.insert(upcomingTask)
        context.insert(noDateTask)

        let vm = MaintenanceViewModel()
        let overdue = vm.overdueTasks(from: [overdueTask, upcomingTask, noDateTask])

        #expect(overdue.count == 1)
        #expect(overdue.first?.title == "Overdue fence repair")
    }

    @Test("deleteTask removes task from context")
    func deleteTask() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let task = MaintenanceTask(
            title: "Remove old fencing",
            category: MaintenanceCategory.property
        )
        context.insert(task)
        try context.save()

        let vm = MaintenanceViewModel()
        vm.deleteTask(task, in: context)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<MaintenanceTask>())
        #expect(remaining.count == 0)
    }

    @Test("markComplete calculates next due date for recurring daily task")
    func markCompleteRecurringDaily() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let dueDate = Date.now
        let task = MaintenanceTask(
            title: "Feed barn cats",
            category: MaintenanceCategory.animal_care,
            isRecurring: true,
            recurrencePattern: RecurrencePattern.daily,
            nextDueDate: dueDate
        )
        context.insert(task)

        let vm = MaintenanceViewModel()
        vm.markComplete(task)

        let expected = Calendar.current.date(byAdding: .day, value: 1, to: dueDate)!
        let diff = abs(task.nextDueDate!.timeIntervalSince(expected))
        #expect(diff < 1)
    }
}
