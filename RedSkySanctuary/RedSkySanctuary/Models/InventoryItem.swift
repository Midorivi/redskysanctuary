import SwiftData
import Foundation

@Model
final class InventoryItem {
    var id: UUID = UUID()
    var name: String = ""
    var category: String = "other"
    var quantity: Double = 0
    var unit: String? = nil
    var reorderThreshold: Double? = nil
    var notes: String? = nil
    var lastRestocked: Date? = nil
    
    init(
        name: String = "",
        category: String = "other",
        quantity: Double = 0,
        unit: String? = nil,
        reorderThreshold: Double? = nil,
        notes: String? = nil,
        lastRestocked: Date? = nil
    ) {
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.reorderThreshold = reorderThreshold
        self.notes = notes
        self.lastRestocked = lastRestocked
    }
    
    var isLowStock: Bool {
        guard let threshold = reorderThreshold else { return false }
        return quantity < threshold
    }
}

struct InventoryCategory {
    static let feed = "feed"
    static let medical = "medical"
    static let bedding = "bedding"
    static let fencing = "fencing"
    static let tools = "tools"
    static let other = "other"
}

struct InventoryUnit {
    static let bales = "bales"
    static let bags = "bags"
    static let rolls = "rolls"
    static let boxes = "boxes"
    static let each = "each"
}
