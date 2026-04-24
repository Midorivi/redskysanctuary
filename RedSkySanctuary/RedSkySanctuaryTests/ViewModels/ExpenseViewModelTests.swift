import Foundation
import SwiftData
import Testing

@testable import RedSkySanctuary

@MainActor
@Suite("ExpenseViewModel Tests")
struct ExpenseViewModelTests {

    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Expense.self,
            configurations: config
        )
    }

    @Test("addExpense persists a new expense with correct fields")
    func addExpensePersistsRecord() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let viewModel = ExpenseViewModel()

        let expense = viewModel.addExpense(
            amount: 149.99,
            date: Date.now,
            category: ExpenseCategory.veterinary,
            description: "  Annual checkup  ",
            notes: "For the horses",
            in: context
        )

        #expect(expense != nil)
        #expect(expense?.amount == 149.99)
        #expect(expense?.category == ExpenseCategory.veterinary)
        #expect(expense?.expenseDescription == "Annual checkup")
        #expect(expense?.notes == "For the horses")

        let fetched = try context.fetch(FetchDescriptor<Expense>())
        #expect(fetched.count == 1)
    }

    @Test("addExpense rejects zero or negative amounts")
    func addExpenseRejectsInvalidAmount() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let viewModel = ExpenseViewModel()

        let zero = viewModel.addExpense(
            amount: 0,
            date: .now,
            category: ExpenseCategory.feed,
            description: nil,
            notes: nil,
            in: context
        )
        #expect(zero == nil)

        let negative = viewModel.addExpense(
            amount: -10,
            date: .now,
            category: ExpenseCategory.feed,
            description: nil,
            notes: nil,
            in: context
        )
        #expect(negative == nil)

        let fetched = try context.fetch(FetchDescriptor<Expense>())
        #expect(fetched.count == 0)
    }

    @Test("deleteExpense removes the expense from the context")
    func deleteExpenseRemovesRecord() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let viewModel = ExpenseViewModel()

        let expense = Expense(
            amount: 50,
            date: .now,
            category: ExpenseCategory.supplies,
            expenseDescription: "Halters"
        )
        context.insert(expense)
        try context.save()

        let beforeDelete = try context.fetch(FetchDescriptor<Expense>())
        #expect(beforeDelete.count == 1)

        viewModel.deleteExpense(expense, in: context)

        let afterDelete = try context.fetch(FetchDescriptor<Expense>())
        #expect(afterDelete.count == 0)
    }

    @Test("totalForDateRange sums only expenses within the given date range")
    func totalForDateRangeFiltersCorrectly() {
        let viewModel = ExpenseViewModel()
        let calendar = Calendar.current

        let jan15 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let feb10 = calendar.date(from: DateComponents(year: 2025, month: 2, day: 10))!
        let mar05 = calendar.date(from: DateComponents(year: 2025, month: 3, day: 5))!

        let expenses = [
            Expense(amount: 100, date: jan15, category: ExpenseCategory.feed),
            Expense(amount: 200, date: feb10, category: ExpenseCategory.veterinary),
            Expense(amount: 300, date: mar05, category: ExpenseCategory.supplies)
        ]

        let rangeStart = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let rangeEnd = calendar.date(from: DateComponents(year: 2025, month: 2, day: 28))!

        let total = viewModel.totalForDateRange(from: expenses, start: rangeStart, end: rangeEnd)
        #expect(total == 300)
    }

    @Test("totalForDateRange returns zero when no expenses match")
    func totalForDateRangeReturnsZeroWhenEmpty() {
        let viewModel = ExpenseViewModel()
        let calendar = Calendar.current

        let jan15 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let expenses = [
            Expense(amount: 100, date: jan15, category: ExpenseCategory.feed)
        ]

        let rangeStart = calendar.date(from: DateComponents(year: 2025, month: 6, day: 1))!
        let rangeEnd = calendar.date(from: DateComponents(year: 2025, month: 6, day: 30))!

        let total = viewModel.totalForDateRange(from: expenses, start: rangeStart, end: rangeEnd)
        #expect(total == 0)

        let emptyTotal = viewModel.totalForDateRange(from: [], start: rangeStart, end: rangeEnd)
        #expect(emptyTotal == 0)
    }

    @Test("expensesByCategory returns only expenses matching the given category")
    func expensesByCategoryFilters() {
        let viewModel = ExpenseViewModel()

        let expenses = [
            Expense(amount: 80, date: .now, category: ExpenseCategory.feed),
            Expense(amount: 200, date: .now, category: ExpenseCategory.veterinary),
            Expense(amount: 45, date: .now, category: ExpenseCategory.feed),
            Expense(amount: 120, date: .now, category: ExpenseCategory.facility)
        ]

        let feedExpenses = viewModel.expensesByCategory(from: expenses, category: ExpenseCategory.feed)

        #expect(feedExpenses.count == 2)
        #expect(feedExpenses.allSatisfy { $0.category == ExpenseCategory.feed })
    }
}
