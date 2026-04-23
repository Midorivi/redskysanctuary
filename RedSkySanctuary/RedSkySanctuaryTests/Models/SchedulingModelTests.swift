import Testing
import Foundation
import SwiftData
@testable import RedSkySanctuary

@Suite("Reminder Model Tests")
struct ReminderModelTests {
    
    private func createModelContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Animal.self, Reminder.self, MaintenanceTask.self,
            AnimalPhoto.self, HealthRecord.self, HealthSign.self,
            TaskTemplate.self, TaskTemplateItem.self,
            TaskInstance.self, TaskInstanceItem.self,
            configurations: config
        )
    }
    
    @Test("Create reminder with default values")
    func testCreateReminderDefaults() throws {
        let reminder = Reminder()
        #expect(reminder.title == "")
        #expect(reminder.notes == nil)
        #expect(reminder.isRecurring == false)
        #expect(reminder.isCompleted == false)
        #expect(reminder.notificationIdentifier == nil)
    }
    
    @Test("Create reminder with custom values")
    func testCreateReminderCustom() throws {
        let date = Date(timeIntervalSince1970: 0)
        let reminder = Reminder(
            title: "Feed horses",
            notes: "Morning feeding",
            date: date,
            isRecurring: true,
            recurrencePattern: ReminderRecurrence.daily,
            isCompleted: false
        )
        #expect(reminder.title == "Feed horses")
        #expect(reminder.notes == "Morning feeding")
        #expect(reminder.date == date)
        #expect(reminder.isRecurring == true)
        #expect(reminder.recurrencePattern == ReminderRecurrence.daily)
    }
    
    @Test("Reminder CRUD - Create and read")
    func testReminderCRUD() throws {
        let container = try createModelContainer()
        let context = ModelContext(container)
        
        let reminder = Reminder(
            title: "Vet appointment",
            notes: "Annual checkup",
            date: .now,
            isRecurring: false
        )
        
        context.insert(reminder)
        try context.save()
        
        let descriptor = FetchDescriptor<Reminder>(predicate: #Predicate { $0.title == "Vet appointment" })
        let fetched = try context.fetch(descriptor)
        
        #expect(fetched.count == 1)
        #expect(fetched[0].title == "Vet appointment")
        #expect(fetched[0].notes == "Annual checkup")
    }
    
    @Test("Reminder recurring pattern validation")
    func testReminderRecurrencePatterns() throws {
        let patterns = [
            ReminderRecurrence.daily,
            ReminderRecurrence.weekly,
            ReminderRecurrence.monthly,
            ReminderRecurrence.yearly
        ]
        
        for pattern in patterns {
            let reminder = Reminder(
                title: "Test",
                isRecurring: true,
                recurrencePattern: pattern
            )
            #expect(reminder.recurrencePattern == pattern)
            #expect(reminder.isRecurring == true)
        }
    }
    
    @Test("Reminder completion marking")
    func testReminderCompletion() throws {
        let container = try createModelContainer()
        let context = ModelContext(container)
        
        let reminder = Reminder(title: "Task", isCompleted: false)
        context.insert(reminder)
        try context.save()
        
        reminder.isCompleted = true
        try context.save()
        
        #expect(reminder.isCompleted == true)
    }
    
    @Test("Reminder-Animal relationship")
    func testReminderAnimalRelationship() throws {
        let container = try createModelContainer()
        let context = ModelContext(container)
        
        let animal = Animal(name: "Bessie", animalType: AnimalType.horse)
        let reminder = Reminder(
            title: "Groom Bessie",
            relatedAnimal: animal
        )
        
        context.insert(animal)
        context.insert(reminder)
        try context.save()
        
        #expect(reminder.relatedAnimal?.name == "Bessie")
        #expect(animal.reminders?.contains { $0.title == "Groom Bessie" } ?? false)
    }
}

@Suite("MaintenanceTask Model Tests")
struct MaintenanceTaskModelTests {
    
    private func createModelContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Animal.self, Reminder.self, MaintenanceTask.self,
            AnimalPhoto.self, HealthRecord.self, HealthSign.self,
            TaskTemplate.self, TaskTemplateItem.self,
            TaskInstance.self, TaskInstanceItem.self,
            configurations: config
        )
    }
    
    @Test("Create maintenance task with default values")
    func testCreateMaintenanceTaskDefaults() throws {
        let task = MaintenanceTask()
        #expect(task.title == "")
        #expect(task.category == "property")
        #expect(task.notes == nil)
        #expect(task.isRecurring == false)
        #expect(task.nextDueDate == nil)
        #expect(task.lastCompletedDate == nil)
        #expect(task.completedBy == nil)
    }
    
    @Test("Create maintenance task with custom values")
    func testCreateMaintenanceTaskCustom() throws {
        let dueDate = Date(timeIntervalSince1970: 0)
        let task = MaintenanceTask(
            title: "Repair fence",
            category: MaintenanceCategory.property,
            notes: "North pasture fence",
            isRecurring: true,
            recurrencePattern: ReminderRecurrence.monthly,
            nextDueDate: dueDate
        )
        #expect(task.title == "Repair fence")
        #expect(task.category == MaintenanceCategory.property)
        #expect(task.notes == "North pasture fence")
        #expect(task.isRecurring == true)
        #expect(task.nextDueDate == dueDate)
    }
    
    @Test("MaintenanceTask CRUD - Create and read")
    func testMaintenanceTaskCRUD() throws {
        let container = try createModelContainer()
        let context = ModelContext(container)
        
        let task = MaintenanceTask(
            title: "Clean barn",
            category: MaintenanceCategory.property,
            notes: "Weekly cleaning"
        )
        
        context.insert(task)
        try context.save()
        
        let descriptor = FetchDescriptor<MaintenanceTask>(predicate: #Predicate { $0.title == "Clean barn" })
        let fetched = try context.fetch(descriptor)
        
        #expect(fetched.count == 1)
        #expect(fetched[0].title == "Clean barn")
        #expect(fetched[0].category == MaintenanceCategory.property)
    }
    
    @Test("MaintenanceTask category validation")
    func testMaintenanceTaskCategories() throws {
        let categories = [
            MaintenanceCategory.property,
            MaintenanceCategory.animal_care
        ]
        
        for category in categories {
            let task = MaintenanceTask(
                title: "Test",
                category: category
            )
            #expect(task.category == category)
        }
    }
    
    @Test("MaintenanceTask completion tracking")
    func testMaintenanceTaskCompletion() throws {
        let container = try createModelContainer()
        let context = ModelContext(container)
        
        let completionDate = Date()
        let task = MaintenanceTask(
            title: "Hay delivery",
            category: MaintenanceCategory.animal_care,
            lastCompletedDate: nil,
            completedBy: nil
        )
        
        context.insert(task)
        try context.save()
        
        task.lastCompletedDate = completionDate
        task.completedBy = "John"
        try context.save()
        
        #expect(task.lastCompletedDate != nil)
        #expect(task.completedBy == "John")
    }
    
    @Test("MaintenanceTask recurring with due date")
    func testMaintenanceTaskRecurringDueDate() throws {
        let container = try createModelContainer()
        let context = ModelContext(container)
        
        let dueDate = Date(timeIntervalSince1970: 86400)
        let task = MaintenanceTask(
            title: "Pasture inspection",
            category: MaintenanceCategory.property,
            isRecurring: true,
            recurrencePattern: ReminderRecurrence.weekly,
            nextDueDate: dueDate
        )
        
        context.insert(task)
        try context.save()
        
        #expect(task.isRecurring == true)
        #expect(task.recurrencePattern == ReminderRecurrence.weekly)
        #expect(task.nextDueDate == dueDate)
    }
}
