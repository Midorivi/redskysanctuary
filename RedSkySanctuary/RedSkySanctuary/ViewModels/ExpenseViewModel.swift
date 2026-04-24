import Foundation
import Observation
import SwiftData

@MainActor @Observable
final class ExpenseViewModel {

    @discardableResult
    func addExpense(
        amount: Double,
        date: Date,
        category: String,
        description: String?,
        notes: String?,
        in context: ModelContext
    ) -> Expense? {
        guard amount > 0 else { return nil }

        let expense = Expense(
            amount: amount,
            date: date,
            category: category,
            expenseDescription: description?.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        context.insert(expense)
        try? context.save()
        return expense
    }

    func deleteExpense(_ expense: Expense, in context: ModelContext) {
        context.delete(expense)
        try? context.save()
    }

    func totalForDateRange(from expenses: [Expense], start: Date, end: Date) -> Double {
        expenses
            .filter { $0.date >= start && $0.date <= end }
            .reduce(0) { $0 + $1.amount }
    }

    func expensesByCategory(from expenses: [Expense], category: String) -> [Expense] {
        expenses.filter { $0.category == category }
    }
}
