import Foundation
import Observation
import SwiftData

@Observable
final class InventoryViewModel {

    @discardableResult
    func createItem(
        name: String,
        category: String,
        quantity: Double,
        unit: String?,
        reorderThreshold: Double?,
        notes: String?,
        in context: ModelContext
    ) -> InventoryItem? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }

        let item = InventoryItem(
            name: trimmedName,
            category: category,
            quantity: max(quantity, 0),
            unit: unit,
            reorderThreshold: reorderThreshold,
            notes: notes?.trimmingCharacters(in: .whitespacesAndNewlines),
            lastRestocked: Date.now
        )

        context.insert(item)
        try? context.save()
        return item
    }

    func updateQuantity(_ item: InventoryItem, newQuantity: Double) {
        let clamped = max(newQuantity, 0)
        let wasLow = item.isLowStock
        item.quantity = clamped

        if wasLow && !item.isLowStock {
            item.lastRestocked = .now
        }

        try? item.modelContext?.save()
    }

    func deleteItem(_ item: InventoryItem, in context: ModelContext) {
        context.delete(item)
        try? context.save()
    }

    func lowStockItems(from items: [InventoryItem]) -> [InventoryItem] {
        items.filter(\.isLowStock)
    }

    func itemsByCategory(from items: [InventoryItem], category: String) -> [InventoryItem] {
        items.filter { $0.category == category }
    }
}
