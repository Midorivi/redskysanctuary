import Testing
import SwiftData
import Foundation

@testable import RedSkySanctuary

@Suite("Task Models")
struct TaskModelTests {
    
    // MARK: - Helper: Create In-Memory ModelContainer
    
    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Animal.self, AnimalPhoto.self, HealthRecord.self, HealthSign.self,
                TaskTemplate.self, TaskTemplateItem.self, TaskInstance.self, TaskInstanceItem.self,
            configurations: config
        )
    }
    
    // MARK: - TaskTemplate CRUD Tests
    
    @Test("TaskTemplate creation with defaults")
    func testTaskTemplateDefaults() throws {
        let template = TaskTemplate()
        
        #expect(!template.id.uuidString.isEmpty)
        #expect(template.name == "")
        #expect(template.isRecurring == true)
        #expect(template.recurrencePattern == "daily")
        #expect(template.templateItems == [])
        #expect(template.instances == [])
    }
    
    @Test("TaskTemplate creation with custom values")
    func testTaskTemplateCustom() throws {
        let template = TaskTemplate(
            name: "Morning Chores",
            isRecurring: true,
            recurrencePattern: RecurrencePattern.daily
        )
        
        #expect(template.name == "Morning Chores")
        #expect(template.isRecurring == true)
        #expect(template.recurrencePattern == "daily")
    }
    
    @Test("TaskTemplate displayName")
    func testTaskTemplateDisplayName() throws {
        let emptyTemplate = TaskTemplate(name: "")
        #expect(emptyTemplate.displayName == "Unnamed Task")
        
        let namedTemplate = TaskTemplate(name: "Evening Chores")
        #expect(namedTemplate.displayName == "Evening Chores")
    }
    
    @Test("TaskTemplate with items persists to container")
    func testTaskTemplateWithItems() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let template = TaskTemplate(name: "Morning Chores")
        let item1 = TaskTemplateItem(title: "Feed animals", sortOrder: 0)
        let item2 = TaskTemplateItem(title: "Clean stalls", sortOrder: 1)
        
        template.templateItems = [item1, item2]
        item1.template = template
        item2.template = template
        
        context.insert(template)
        try context.save()
        
        let descriptor = FetchDescriptor<TaskTemplate>(predicate: #Predicate { $0.name == "Morning Chores" })
        let fetched = try context.fetch(descriptor)
        
        #expect(fetched.count == 1)
        #expect(fetched[0].templateItems?.count == 2)
        #expect(fetched[0].templateItems?[0].title == "Feed animals")
    }
    
    // MARK: - TaskTemplateItem Tests
    
    @Test("TaskTemplateItem creation")
    func testTaskTemplateItemCreation() throws {
        let item = TaskTemplateItem(title: "Feed animals", sortOrder: 0)
        
        #expect(!item.id.uuidString.isEmpty)
        #expect(item.title == "Feed animals")
        #expect(item.sortOrder == 0)
        #expect(item.template == nil)
    }
    
    // MARK: - TaskInstance Generation from Template
    
    @Test("TaskInstance generation from template")
    func testTaskInstanceFromTemplate() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let template = TaskTemplate(name: "Daily Tasks")
        let templateItem1 = TaskTemplateItem(title: "Task 1", sortOrder: 0)
        let templateItem2 = TaskTemplateItem(title: "Task 2", sortOrder: 1)
        
        template.templateItems = [templateItem1, templateItem2]
        templateItem1.template = template
        templateItem2.template = template
        
        context.insert(template)
        try context.save()
        
        // Create instance from template
        let instance = TaskInstance(date: .now, isAdHoc: false)
        instance.template = template
        
        let instanceItem1 = TaskInstanceItem(title: templateItem1.title, sortOrder: 0)
        let instanceItem2 = TaskInstanceItem(title: templateItem2.title, sortOrder: 1)
        
        instance.items = [instanceItem1, instanceItem2]
        instanceItem1.instance = instance
        instanceItem2.instance = instance
        
        context.insert(instance)
        try context.save()
        
        let descriptor = FetchDescriptor<TaskInstance>()
        let instances = try context.fetch(descriptor)
        
        #expect(instances.count == 1)
        #expect(instances[0].items?.count == 2)
        #expect(instances[0].template?.name == "Daily Tasks")
    }
    
    // MARK: - TaskInstanceItem Check-off Tests
    
    @Test("TaskInstanceItem individual check-off")
    func testTaskInstanceItemCheckOff() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let instance = TaskInstance(date: .now, isAdHoc: false)
        var item = TaskInstanceItem(title: "Feed animals", sortOrder: 0)
        item.instance = instance
        instance.items = [item]
        
        context.insert(instance)
        try context.save()
        
        // Mark item complete
        item.markComplete(by: "John")
        try context.save()
        
        let descriptor = FetchDescriptor<TaskInstanceItem>()
        let fetched = try context.fetch(descriptor)
        
        #expect(fetched.count == 1)
        #expect(fetched[0].isCompleted == true)
        #expect(fetched[0].completedBy == "John")
        #expect(fetched[0].completedAt != nil)
    }
    
    @Test("Multiple items can be checked independently")
    func testMultipleItemsIndependentCheckOff() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let instance = TaskInstance(date: .now, isAdHoc: false)
        var item1 = TaskInstanceItem(title: "Task 1", sortOrder: 0)
        var item2 = TaskInstanceItem(title: "Task 2", sortOrder: 1)
        
        item1.instance = instance
        item2.instance = instance
        instance.items = [item1, item2]
        
        context.insert(instance)
        try context.save()
        
        // Check off only item1
        item1.markComplete(by: "Alice")
        try context.save()
        
        let descriptor = FetchDescriptor<TaskInstanceItem>()
        let fetched = try context.fetch(descriptor)
        
        let completed = fetched.filter { $0.isCompleted }
        let incomplete = fetched.filter { !$0.isCompleted }
        
        #expect(completed.count == 1)
        #expect(incomplete.count == 1)
        #expect(completed[0].title == "Task 1")
        #expect(incomplete[0].title == "Task 2")
    }
    
    // MARK: - Ad-hoc Instance Tests
    
    @Test("Ad-hoc TaskInstance creation")
    func testAdHocTaskInstance() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let adHocInstance = TaskInstance(date: .now, isAdHoc: true)
        let item = TaskInstanceItem(title: "Unexpected task", sortOrder: 0)
        item.instance = adHocInstance
        adHocInstance.items = [item]
        
        context.insert(adHocInstance)
        try context.save()
        
        let descriptor = FetchDescriptor<TaskInstance>(predicate: #Predicate { $0.isAdHoc == true })
        let fetched = try context.fetch(descriptor)
        
        #expect(fetched.count == 1)
        #expect(fetched[0].isAdHoc == true)
        #expect(fetched[0].template == nil)
    }
    
    // MARK: - Date Filtering Tests
    
    @Test("Filter TaskInstances by date")
    func testFilterInstancesByDate() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let today = Calendar.current.startOfDay(for: .now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let instance1 = TaskInstance(date: today, isAdHoc: false)
        let instance2 = TaskInstance(date: tomorrow, isAdHoc: false)
        
        context.insert(instance1)
        context.insert(instance2)
        try context.save()
        
        let descriptor = FetchDescriptor<TaskInstance>(
            predicate: #Predicate { instance in
                Calendar.current.isDate(instance.date, inSameDayAs: today)
            }
        )
        let todayInstances = try context.fetch(descriptor)
        
        #expect(todayInstances.count == 1)
        #expect(Calendar.current.isDate(todayInstances[0].date, inSameDayAs: today))
    }
    
    // MARK: - Cascade Delete Tests
    
    @Test("Cascade delete removes template items")
    func testCascadeDeleteTemplateItems() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let template = TaskTemplate(name: "To Delete")
        let item1 = TaskTemplateItem(title: "Item 1", sortOrder: 0)
        let item2 = TaskTemplateItem(title: "Item 2", sortOrder: 1)
        
        template.templateItems = [item1, item2]
        item1.template = template
        item2.template = template
        
        context.insert(template)
        try context.save()
        
        // Delete template
        context.delete(template)
        try context.save()
        
        let descriptor = FetchDescriptor<TaskTemplateItem>()
        let remaining = try context.fetch(descriptor)
        
        #expect(remaining.count == 0)
    }
    
    @Test("Cascade delete removes instance items")
    func testCascadeDeleteInstanceItems() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let instance = TaskInstance(date: .now, isAdHoc: false)
        let item1 = TaskInstanceItem(title: "Item 1", sortOrder: 0)
        let item2 = TaskInstanceItem(title: "Item 2", sortOrder: 1)
        
        instance.items = [item1, item2]
        item1.instance = instance
        item2.instance = instance
        
        context.insert(instance)
        try context.save()
        
        // Delete instance
        context.delete(instance)
        try context.save()
        
        let descriptor = FetchDescriptor<TaskInstanceItem>()
        let remaining = try context.fetch(descriptor)
        
        #expect(remaining.count == 0)
    }
    
    // MARK: - RecurrencePattern Constants
    
    @Test("RecurrencePattern constants")
    func testRecurrencePatternConstants() throws {
        #expect(RecurrencePattern.daily == "daily")
        #expect(RecurrencePattern.weekly == "weekly")
        #expect(RecurrencePattern.monthly == "monthly")
    }
}
