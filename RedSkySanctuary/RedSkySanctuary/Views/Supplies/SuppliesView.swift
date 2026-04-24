import SwiftUI
import SwiftData

struct SuppliesView: View {
    @Query(sort: \InventoryItem.name) private var allItems: [InventoryItem]
    @Query private var allExpenses: [Expense]

    private var lowStockCount: Int {
        allItems.filter(\.isLowStock).count
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter
    }()

    private var thisMonthTotal: Double {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: Date.now))!
        return allExpenses
            .filter { $0.date >= start && $0.date <= Date.now }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryCards

                NavigationLink {
                    InventoryListView()
                } label: {
                    SanctuaryRow(
                        iconName: "shippingbox.fill",
                        iconColor: .blue,
                        title: "Inventory",
                        subtitle: "\(allItems.count) items tracked"
                    ) { Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary) }
                }
                .padding(.horizontal, 16)

                NavigationLink {
                    ExpenseListView()
                } label: {
                    SanctuaryRow(
                        iconName: "dollarsign.circle.fill",
                        iconColor: .green,
                        title: "Expenses",
                        subtitle: "\(Self.currencyFormatter.string(from: NSNumber(value: thisMonthTotal)) ?? "$0") this month"
                    ) { Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary) }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Supplies")
        .navigationBarTitleDisplayMode(.large)
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total Items",
                value: "\(allItems.count)",
                iconName: "shippingbox.fill",
                iconColor: .blue
            )

            StatCard(
                title: "Low Stock",
                value: "\(lowStockCount)",
                iconName: "exclamationmark.triangle.fill",
                iconColor: lowStockCount > 0 ? .red : .green
            )
        }
        .padding(.horizontal, 16)
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let iconName: String
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                .symbolRenderingMode(.hierarchical)

            Text(value)
                .font(.system(.title, design: .rounded).bold())
                .foregroundStyle(.primary)
                .monospacedDigit()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        SuppliesView()
    }
    .modelContainer(for: [InventoryItem.self, Expense.self], inMemory: true)
}
