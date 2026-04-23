import Foundation
import SwiftData
import Testing

@testable import RedSkySanctuary

@Suite("TasksViewModel Tests")
struct TasksViewModelTests {

    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: TaskTemplate.self,
            TaskTemplateItem.self,
            TaskInstance.self,
            TaskInstanceItem.self,
            configurations: config
        )
    }

    private func createTemplate(in context: ModelContext, titles: [String] = ["Feed horses", "Refresh water"]) -> TaskTemplate {
        let template = TaskTemplate(name: "Morning Chores", isRecurring: true, recurrencePattern: RecurrencePattern.daily)
        let items = titles.enumerated().map { index, title in
            let item = TaskTemplateItem(title: title, sortOrder: index)
            item.template = template
            return item
        }
        template.templateItems = items
        context.insert(template)
        return template
    }

    @Test("generateDailyInstance creates a task instance and individual item records")
    func generateDailyInstanceCreatesItems() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let template = createTemplate(in: context)
        try context.save()
        let viewModel = TasksViewModel(currentUserName: "Tester")
        let targetDate = Date(timeIntervalSince1970: 1_700_000_000)

        let instance = viewModel.generateDailyInstance(from: template, for: targetDate, in: context)

        #expect(instance.template?.id == template.id)
        #expect(instance.isAdHoc == false)
        #expect(instance.items?.count == 2)

        let itemRecords = try context.fetch(FetchDescriptor<TaskInstanceItem>())
        #expect(itemRecords.count == 2)
        #expect(itemRecords.map(\.title) == ["Feed horses", "Refresh water"])
        #expect(itemRecords.allSatisfy { $0.instance?.id == instance.id })
    }

    @Test("generateDailyInstance returns existing instance for the same template and day")
    func generateDailyInstanceAvoidsDuplicates() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let template = createTemplate(in: context)
        try context.save()
        let viewModel = TasksViewModel(currentUserName: "Tester")
        let targetDate = Date(timeIntervalSince1970: 1_700_000_000)

        let first = viewModel.generateDailyInstance(from: template, for: targetDate, in: context)
        let second = viewModel.generateDailyInstance(from: template, for: targetDate.addingTimeInterval(3600), in: context)

        let instances = try context.fetch(FetchDescriptor<TaskInstance>())
        #expect(instances.count == 1)
        #expect(first.id == second.id)
    }

    @Test("toggleItem updates only the individual task instance item record")
    func toggleItemUpdatesIndividualRecord() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let instance = TaskInstance(date: .now, isAdHoc: false)
        let firstItem = TaskInstanceItem(title: "Feed goats", sortOrder: 0)
        let secondItem = TaskInstanceItem(title: "Sweep aisle", sortOrder: 1)
        firstItem.instance = instance
        secondItem.instance = instance
        instance.items = [firstItem, secondItem]
        context.insert(instance)
        try context.save()

        let viewModel = TasksViewModel(currentUserName: "Alex")
        viewModel.toggleItem(firstItem)

        #expect(firstItem.isCompleted == true)
        #expect(firstItem.completedBy == "Alex")
        #expect(secondItem.isCompleted == false)
        #expect(instance.items?.count == 2)
    }

    @Test("toggleItem sets completedAt when an item is completed")
    func toggleItemSetsCompletedAt() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let instance = TaskInstance(date: .now, isAdHoc: false)
        let item = TaskInstanceItem(title: "Lock gates", sortOrder: 0)
        item.instance = instance
        instance.items = [item]
        context.insert(instance)
        try context.save()

        let viewModel = TasksViewModel(currentUserName: "Taylor")
        viewModel.toggleItem(item)

        #expect(item.isCompleted == true)
        #expect(item.completedAt != nil)
    }

    @Test("addAdHocTask creates an ad-hoc instance with one item")
    func addAdHocTaskCreatesInstance() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let viewModel = TasksViewModel(currentUserName: "Tester")

        let instance = viewModel.addAdHocTask(title: "  Check fence  ", to: .now, in: context)

        #expect(instance != nil)
        #expect(instance?.isAdHoc == true)
        #expect(instance?.items?.count == 1)
        #expect(instance?.items?.first?.title == "Check fence")
    }

    @Test("completionProgress returns completed and total counts")
    func completionProgressCountsItems() {
        let instance = TaskInstance(date: .now, isAdHoc: false)
        let first = TaskInstanceItem(title: "Task 1", isCompleted: true, completedBy: "A", completedAt: .now, sortOrder: 0)
        let second = TaskInstanceItem(title: "Task 2", sortOrder: 1)
        let third = TaskInstanceItem(title: "Task 3", isCompleted: true, completedBy: "B", completedAt: .now, sortOrder: 2)
        instance.items = [first, second, third]

        let progress = TasksViewModel().completionProgress(for: instance)

        #expect(progress.completed == 2)
        #expect(progress.total == 3)
    }

    @Test("createTemplate persists a template with ordered items")
    func createTemplatePersistsItems() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let viewModel = TasksViewModel(currentUserName: "Tester")

        let template = viewModel.createTemplate(
            name: "  Closing  ",
            items: ["Secure barn", " ", "Refill hay"],
            isRecurring: true,
            pattern: RecurrencePattern.weekly,
            in: context
        )

        #expect(template != nil)
        #expect(template?.name == "Closing")
        #expect(template?.recurrencePattern == RecurrencePattern.weekly)
        #expect(template?.templateItems?.count == 2)
        #expect(template?.templateItems?.map(\.sortOrder) == [0, 1])
    }
}
