import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    @State private var viewModel = ExpenseViewModel()
    @State private var selectedPeriod = 0
    @State private var selectedCategory = "all"
    @State private var showingAddSheet = false

    private let categories: [(String, String, String)] = [
        ("all", "All", "square.grid.2x2.fill"),
        (ExpenseCategory.feed, "Feed", "leaf.fill"),
        (ExpenseCategory.veterinary, "Veterinary", "cross.case.fill"),
        (ExpenseCategory.supplies, "Supplies", "shippingbox.fill"),
        (ExpenseCategory.facility, "Facility", "house.fill"),
        (ExpenseCategory.other, "Other", "ellipsis.circle.fill")
    ]

    private var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date.now
        switch selectedPeriod {
        case 0:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return (start, now)
        case 1:
            let start = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return (start, now)
        default:
            return (Date.distantPast, Date.distantFuture)
        }
    }

    private var filteredExpenses: [Expense] {
        let range = dateRange
        var filtered = allExpenses.filter { $0.date >= range.start && $0.date <= range.end }
        if selectedCategory != "all" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        return filtered
    }

    private var totalForPeriod: Double {
        let range = dateRange
        let source = selectedCategory == "all"
            ? allExpenses
            : viewModel.expensesByCategory(from: allExpenses, category: selectedCategory)
        return viewModel.totalForDateRange(from: source, start: range.start, end: range.end)
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            totalHeader

            periodPicker

            categoryPills

            if filteredExpenses.isEmpty {
                ContentUnavailableView(
                    "No Expenses",
                    systemImage: "dollarsign.circle",
                    description: Text("Expenses for this period will appear here")
                )
            } else {
                expensesList
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Expenses")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
                .sensoryFeedback(.impact, trigger: showingAddSheet)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            ExpenseFormView(viewModel: viewModel)
        }
    }

    private var totalHeader: some View {
        VStack(spacing: 4) {
            Text("Total")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(Self.currencyFormatter.string(from: NSNumber(value: totalForPeriod)) ?? "$0.00")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundStyle(.primary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.spring(.snappy), value: totalForPeriod)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            Text("This Month").tag(0)
            Text("This Year").tag(1)
            Text("All Time").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .sensoryFeedback(.selection, trigger: selectedPeriod)
    }

    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.0) { key, label, icon in
                    CategoryFilterPill(
                        label: label,
                        iconName: icon,
                        isSelected: selectedCategory == key
                    ) {
                        withAnimation(.spring(.snappy)) {
                            selectedCategory = key
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .sensoryFeedback(.selection, trigger: selectedCategory)
    }

    private var expensesList: some View {
        List {
            ForEach(filteredExpenses) { expense in
                ExpenseRow(expense: expense)
                    .listRowBackground(Color(.systemGray6))
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            .onDelete { offsets in
                for index in offsets {
                    let expense = filteredExpenses[index]
                    viewModel.deleteExpense(expense, in: modelContext)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

private struct CategoryFilterPill: View {
    let label: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.caption)
                Text(label)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct ExpenseRow: View {
    let expense: Expense

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter
    }()

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForCategory(expense.category))
                .font(.title3)
                .foregroundStyle(colorForCategory(expense.category))
                .symbolRenderingMode(.hierarchical)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.expenseDescription ?? expense.category.capitalized)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(Self.dateFormatter.string(from: expense.date))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(Self.currencyFormatter.string(from: NSNumber(value: expense.amount)) ?? "$0.00")
                .font(.system(.body, design: .rounded).bold())
                .foregroundStyle(.primary)
                .monospacedDigit()
        }
        .padding(.vertical, 8)
    }

    private func iconForCategory(_ category: String) -> String {
        switch category {
        case ExpenseCategory.feed: return "leaf.fill"
        case ExpenseCategory.veterinary: return "cross.case.fill"
        case ExpenseCategory.supplies: return "shippingbox.fill"
        case ExpenseCategory.facility: return "house.fill"
        default: return "ellipsis.circle.fill"
        }
    }

    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case ExpenseCategory.feed: return .green
        case ExpenseCategory.veterinary: return .red
        case ExpenseCategory.supplies: return .blue
        case ExpenseCategory.facility: return .orange
        default: return .secondary
        }
    }
}

#Preview {
    NavigationStack {
        ExpenseListView()
    }
    .modelContainer(for: Expense.self, inMemory: true)
}
