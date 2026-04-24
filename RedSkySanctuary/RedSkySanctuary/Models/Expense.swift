import SwiftData
import Foundation

@Model
final class Expense {
    var id: UUID = UUID()
    var amount: Double = 0
    var date: Date = Date.now
    var category: String = "other"
    var expenseDescription: String? = nil
    var notes: String? = nil
    
    init(
        amount: Double = 0,
        date: Date = .now,
        category: String = "other",
        expenseDescription: String? = nil,
        notes: String? = nil
    ) {
        self.amount = amount
        self.date = date
        self.category = category
        self.expenseDescription = expenseDescription
        self.notes = notes
    }
}

struct ExpenseCategory {
    static let feed = "feed"
    static let veterinary = "veterinary"
    static let supplies = "supplies"
    static let facility = "facility"
    static let other = "other"
}
