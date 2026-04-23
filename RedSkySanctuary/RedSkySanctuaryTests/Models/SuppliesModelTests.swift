import Testing
import SwiftData
@testable import RedSkySanctuary

@Suite
struct SuppliesModelTests {
    
    // MARK: - Helper: In-Memory ModelContainer
    static func createModelContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: InventoryItem.self, Expense.self, configurations: config)
        return container
    }
    
    // MARK: - InventoryItem Tests
    
    @Test("InventoryItem: Create with defaults")
    func inventoryItemCreateDefaults() {
        let item = InventoryItem()
        #expect(item.name == "")
        #expect(item.category == "other")
        #expect(item.quantity == 0)
        #expect(item.unit == nil)
        #expect(item.reorderThreshold == nil)
        #expect(item.notes == nil)
        #expect(item.lastRestocked == nil)
    }
    
    @Test("InventoryItem: Create with custom values")
    func inventoryItemCreateCustom() {
        let item = InventoryItem(
            name: "Horse Feed",
            category: "feed",
            quantity: 50,
            unit: "bags",
            reorderThreshold: 10,
            notes: "Keep dry",
            lastRestocked: Date.now
        )
        #expect(item.name == "Horse Feed")
        #expect(item.category == "feed")
        #expect(item.quantity == 50)
        #expect(item.unit == "bags")
        #expect(item.reorderThreshold == 10)
        #expect(item.notes == "Keep dry")
        #expect(item.lastRestocked != nil)
    }
    
    @Test("InventoryItem: isLowStock returns false when no threshold")
    func inventoryItemLowStockNoThreshold() {
        let item = InventoryItem(
            name: "Bedding",
            category: "bedding",
            quantity: 5,
            reorderThreshold: nil
        )
        #expect(item.isLowStock == false)
    }
    
    @Test("InventoryItem: isLowStock returns true when quantity below threshold")
    func inventoryItemLowStockBelowThreshold() {
        let item = InventoryItem(
            name: "Medical Supplies",
            category: "medical",
            quantity: 3,
            reorderThreshold: 10
        )
        #expect(item.isLowStock == true)
    }
    
    @Test("InventoryItem: isLowStock returns false when quantity meets threshold")
    func inventoryItemLowStockMetThreshold() {
        let item = InventoryItem(
            name: "Fencing",
            category: "fencing",
            quantity: 10,
            reorderThreshold: 10
        )
        #expect(item.isLowStock == false)
    }
    
    @Test("InventoryItem: isLowStock returns false when quantity above threshold")
    func inventoryItemLowStockAboveThreshold() {
        let item = InventoryItem(
            name: "Tools",
            category: "tools",
            quantity: 20,
            reorderThreshold: 10
        )
        #expect(item.isLowStock == false)
    }
    
    @Test("InventoryItem: CRUD with ModelContainer")
    async func inventoryItemCRUD() throws {
        let container = try Self.createModelContainer()
        let context = ModelContext(container)
        
        let item = InventoryItem(
            name: "Hay Bales",
            category: "feed",
            quantity: 100,
            unit: "bales",
            reorderThreshold: 20
        )
        context.insert(item)
        try context.save()
        
        let predicate = #Predicate<InventoryItem> { $0.name == "Hay Bales" }
        var descriptor = FetchDescriptor(predicate: predicate)
        var fetched = try context.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched[0].name == "Hay Bales")
        #expect(fetched[0].quantity == 100)
        
        fetched[0].quantity = 50
        try context.save()
        descriptor = FetchDescriptor(predicate: predicate)
        fetched = try context.fetch(descriptor)
        #expect(fetched[0].quantity == 50)
        
        context.delete(fetched[0])
        try context.save()
        descriptor = FetchDescriptor(predicate: predicate)
        fetched = try context.fetch(descriptor)
        #expect(fetched.count == 0)
    }
    
    // MARK: - Expense Tests
    
    @Test("Expense: Create with defaults")
    func expenseCreateDefaults() {
        let expense = Expense()
        #expect(expense.amount == 0)
        #expect(expense.category == "other")
        #expect(expense.expenseDescription == nil)
        #expect(expense.notes == nil)
    }
    
    @Test("Expense: Create with custom values")
    func expenseCreateCustom() {
        let testDate = Date(timeIntervalSince1970: 0)
        let expense = Expense(
            amount: 250.50,
            date: testDate,
            category: "veterinary",
            expenseDescription: "Annual checkup",
            notes: "All animals healthy"
        )
        #expect(expense.amount == 250.50)
        #expect(expense.date == testDate)
        #expect(expense.category == "veterinary")
        #expect(expense.expenseDescription == "Annual checkup")
        #expect(expense.notes == "All animals healthy")
    }
    
    @Test("Expense: CRUD with ModelContainer")
    async func expenseCRUD() throws {
        let container = try Self.createModelContainer()
        let context = ModelContext(container)
        
        let expense = Expense(
            amount: 150.00,
            category: "feed",
            expenseDescription: "Monthly feed purchase"
        )
        context.insert(expense)
        try context.save()
        
        let predicate = #Predicate<Expense> { $0.category == "feed" }
        var descriptor = FetchDescriptor(predicate: predicate)
        var fetched = try context.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched[0].amount == 150.00)
        
        fetched[0].amount = 175.00
        try context.save()
        descriptor = FetchDescriptor(predicate: predicate)
        fetched = try context.fetch(descriptor)
        #expect(fetched[0].amount == 175.00)
        
        context.delete(fetched[0])
        try context.save()
        descriptor = FetchDescriptor(predicate: predicate)
        fetched = try context.fetch(descriptor)
        #expect(fetched.count == 0)
    }
    
    @Test("Expense: Filter by category")
    async func expenseFilterByCategory() throws {
        let container = try Self.createModelContainer()
        let context = ModelContext(container)
        
        let exp1 = Expense(amount: 100, category: "feed")
        let exp2 = Expense(amount: 200, category: "veterinary")
        let exp3 = Expense(amount: 150, category: "feed")
        
        context.insert(exp1)
        context.insert(exp2)
        context.insert(exp3)
        try context.save()
        
        let predicate = #Predicate<Expense> { $0.category == "feed" }
        let descriptor = FetchDescriptor(predicate: predicate)
        let fetched = try context.fetch(descriptor)
        
        #expect(fetched.count == 2)
        #expect(fetched.allSatisfy { $0.category == "feed" })
    }
    
    @Test("Expense: Filter by date range")
    async func expenseFilterByDateRange() throws {
        let container = try Self.createModelContainer()
        let context = ModelContext(container)
        
        let startDate = Date(timeIntervalSince1970: 1000)
        let midDate = Date(timeIntervalSince1970: 5000)
        let endDate = Date(timeIntervalSince1970: 10000)
        
        let exp1 = Expense(amount: 100, date: startDate)
        let exp2 = Expense(amount: 200, date: midDate)
        let exp3 = Expense(amount: 150, date: endDate)
        
        context.insert(exp1)
        context.insert(exp2)
        context.insert(exp3)
        try context.save()
        
        let predicate = #Predicate<Expense> { $0.date >= startDate && $0.date <= midDate }
        let descriptor = FetchDescriptor(predicate: predicate)
        let fetched = try context.fetch(descriptor)
        
        #expect(fetched.count == 2)
    }
    
    // MARK: - Category Constants Tests
    
    @Test("InventoryCategory constants are accessible")
    func inventoryCategoryConstants() {
        #expect(InventoryCategory.feed == "feed")
        #expect(InventoryCategory.medical == "medical")
        #expect(InventoryCategory.bedding == "bedding")
        #expect(InventoryCategory.fencing == "fencing")
        #expect(InventoryCategory.tools == "tools")
        #expect(InventoryCategory.other == "other")
    }
    
    @Test("InventoryUnit constants are accessible")
    func inventoryUnitConstants() {
        #expect(InventoryUnit.bales == "bales")
        #expect(InventoryUnit.bags == "bags")
        #expect(InventoryUnit.rolls == "rolls")
        #expect(InventoryUnit.boxes == "boxes")
        #expect(InventoryUnit.each == "each")
    }
    
    @Test("ExpenseCategory constants are accessible")
    func expenseCategoryConstants() {
        #expect(ExpenseCategory.feed == "feed")
        #expect(ExpenseCategory.veterinary == "veterinary")
        #expect(ExpenseCategory.supplies == "supplies")
        #expect(ExpenseCategory.facility == "facility")
        #expect(ExpenseCategory.other == "other")
    }
}
