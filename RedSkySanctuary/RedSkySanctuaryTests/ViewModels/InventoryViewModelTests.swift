import Foundation
import SwiftData
import Testing

@testable import RedSkySanctuary

@MainActor
@Suite("InventoryViewModel Tests")
struct InventoryViewModelTests {

    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: InventoryItem.self,
            configurations: config
        )
    }

    @Test("createItem persists a new inventory item with trimmed name")
    func createItemPersistsRecord() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let viewModel = InventoryViewModel()

        let item = viewModel.createItem(
            name: "  Timothy Hay  ",
            category: InventoryCategory.feed,
            quantity: 25,
            unit: InventoryUnit.bales,
            reorderThreshold: 10,
            notes: "Stored in barn loft",
            in: context
        )

        #expect(item != nil)
        #expect(item?.name == "Timothy Hay")
        #expect(item?.category == InventoryCategory.feed)
        #expect(item?.quantity == 25)
        #expect(item?.unit == InventoryUnit.bales)
        #expect(item?.reorderThreshold == 10)
        #expect(item?.lastRestocked != nil)

        let fetched = try context.fetch(FetchDescriptor<InventoryItem>())
        #expect(fetched.count == 1)
    }

    @Test("createItem rejects empty or whitespace-only names")
    func createItemRejectsEmptyName() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let viewModel = InventoryViewModel()

        let blank = viewModel.createItem(
            name: "   ",
            category: InventoryCategory.other,
            quantity: 5,
            unit: nil,
            reorderThreshold: nil,
            notes: nil,
            in: context
        )

        #expect(blank == nil)

        let fetched = try context.fetch(FetchDescriptor<InventoryItem>())
        #expect(fetched.count == 0)
    }

    @Test("updateQuantity changes quantity and clamps to zero minimum")
    func updateQuantityClampsToZero() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let viewModel = InventoryViewModel()

        let item = InventoryItem(
            name: "Bandages",
            category: InventoryCategory.medical,
            quantity: 10,
            unit: InventoryUnit.boxes,
            reorderThreshold: 5
        )
        context.insert(item)
        try context.save()

        viewModel.updateQuantity(item, newQuantity: 3)
        #expect(item.quantity == 3)

        viewModel.updateQuantity(item, newQuantity: -5)
        #expect(item.quantity == 0)
    }

    @Test("lowStockItems returns only items below their reorder threshold")
    func lowStockItemsFiltersCorrectly() {
        let viewModel = InventoryViewModel()

        let hay = InventoryItem(name: "Hay", category: InventoryCategory.feed, quantity: 5, reorderThreshold: 10)
        let grain = InventoryItem(name: "Grain", category: InventoryCategory.feed, quantity: 20, reorderThreshold: 10)
        let tape = InventoryItem(name: "Tape", category: InventoryCategory.fencing, quantity: 1, reorderThreshold: 3)
        let hammer = InventoryItem(name: "Hammer", category: InventoryCategory.tools, quantity: 2)

        let lowStock = viewModel.lowStockItems(from: [hay, grain, tape, hammer])

        #expect(lowStock.count == 2)
        #expect(lowStock.contains(where: { $0.name == "Hay" }))
        #expect(lowStock.contains(where: { $0.name == "Tape" }))
    }

    @Test("itemsByCategory returns only items matching the given category")
    func itemsByCategoryFilters() {
        let viewModel = InventoryViewModel()

        let hay = InventoryItem(name: "Hay", category: InventoryCategory.feed)
        let grain = InventoryItem(name: "Grain", category: InventoryCategory.feed)
        let bandage = InventoryItem(name: "Bandage", category: InventoryCategory.medical)

        let feedItems = viewModel.itemsByCategory(from: [hay, grain, bandage], category: InventoryCategory.feed)

        #expect(feedItems.count == 2)
        #expect(feedItems.allSatisfy { $0.category == InventoryCategory.feed })
    }

    @Test("deleteItem removes the item from the context")
    func deleteItemRemovesRecord() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let viewModel = InventoryViewModel()

        let item = InventoryItem(
            name: "Wire",
            category: InventoryCategory.fencing,
            quantity: 4,
            unit: InventoryUnit.rolls
        )
        context.insert(item)
        try context.save()

        let beforeDelete = try context.fetch(FetchDescriptor<InventoryItem>())
        #expect(beforeDelete.count == 1)

        viewModel.deleteItem(item, in: context)

        let afterDelete = try context.fetch(FetchDescriptor<InventoryItem>())
        #expect(afterDelete.count == 0)
    }

    @Test("updateQuantity sets lastRestocked when recovering from low stock")
    func updateQuantitySetsRestockedDate() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let viewModel = InventoryViewModel()

        let item = InventoryItem(
            name: "Shavings",
            category: InventoryCategory.bedding,
            quantity: 2,
            unit: InventoryUnit.bags,
            reorderThreshold: 5
        )
        item.lastRestocked = nil
        context.insert(item)
        try context.save()

        #expect(item.isLowStock == true)

        viewModel.updateQuantity(item, newQuantity: 10)

        #expect(item.isLowStock == false)
        #expect(item.lastRestocked != nil)
    }
}
