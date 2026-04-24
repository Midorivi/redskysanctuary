import SwiftUI
import SwiftData

struct InventoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InventoryItem.name) private var allItems: [InventoryItem]
    @State private var viewModel = InventoryViewModel()
    @State private var selectedCategory = "all"
    @State private var showingAddSheet = false
    @State private var editingItem: InventoryItem?

    private let categories = [
        ("all", "All"),
        (InventoryCategory.feed, "Feed"),
        (InventoryCategory.medical, "Medical"),
        (InventoryCategory.bedding, "Bedding"),
        (InventoryCategory.fencing, "Fencing"),
        (InventoryCategory.tools, "Tools"),
        (InventoryCategory.other, "Other")
    ]

    private var filteredItems: [InventoryItem] {
        if selectedCategory == "all" {
            return allItems
        }
        return viewModel.itemsByCategory(from: allItems, category: selectedCategory)
    }

    private var groupedItems: [(String, [InventoryItem])] {
        let grouped = Dictionary(grouping: filteredItems) { $0.category }
        return grouped
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value.sorted { $0.name < $1.name }) }
    }

    var body: some View {
        VStack(spacing: 0) {
            categoryPills

            if filteredItems.isEmpty {
                ContentUnavailableView(
                    "No Items",
                    systemImage: "shippingbox",
                    description: Text("Add supplies to track your inventory")
                )
            } else {
                itemsList
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Inventory")
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
            InventoryFormView(viewModel: viewModel)
        }
        .sheet(item: $editingItem) { item in
            InventoryFormView(viewModel: viewModel, editingItem: item)
        }
    }

    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.0) { key, label in
                    CategoryPill(
                        label: label,
                        isSelected: selectedCategory == key,
                        count: pillCount(for: key)
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

    private func pillCount(for key: String) -> Int {
        if key == "all" { return allItems.count }
        return viewModel.itemsByCategory(from: allItems, category: key).count
    }

    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                let lowStock = viewModel.lowStockItems(from: allItems)
                if !lowStock.isEmpty && selectedCategory == "all" {
                    lowStockSection(lowStock)
                }

                ForEach(groupedItems, id: \.0) { category, items in
                    categorySection(category: category, items: items)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
    }

    private func lowStockSection(_ items: [InventoryItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("Low Stock")
                    .font(.system(.subheadline, design: .rounded).bold())
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }
            .foregroundStyle(.red)
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Divider().padding(.leading, 44)
                    }
                    InventoryRow(item: item, isLowStock: true) {
                        editingItem = item
                    } onIncrement: {
                        viewModel.updateQuantity(item, newQuantity: item.quantity + 1)
                    } onDecrement: {
                        viewModel.updateQuantity(item, newQuantity: item.quantity - 1)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.red.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func categorySection(category: String, items: [InventoryItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.capitalized)
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Divider().padding(.leading, 44)
                    }
                    InventoryRow(item: item, isLowStock: item.isLowStock) {
                        editingItem = item
                    } onIncrement: {
                        viewModel.updateQuantity(item, newQuantity: item.quantity + 1)
                    } onDecrement: {
                        viewModel.updateQuantity(item, newQuantity: item.quantity - 1)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 12, style: .continuous))
        }
    }
}

private struct CategoryPill: View {
    let label: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline.weight(.medium))
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            isSelected
                                ? Color.white.opacity(0.2)
                                : Color(.systemGray4)
                        )
                        .clipShape(Capsule())
                }
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

private struct InventoryRow: View {
    let item: InventoryItem
    let isLowStock: Bool
    let onTap: () -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    @State private var incrementTrigger = 0
    @State private var decrementTrigger = 0

    private var quantityLabel: String {
        let qty = item.quantity.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", item.quantity)
            : String(format: "%.1f", item.quantity)
        if let unit = item.unit {
            return "\(qty) \(unit)"
        }
        return qty
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onTap) {
                HStack(spacing: 10) {
                    ZStack {
                        Image(systemName: iconForCategory(item.category))
                            .font(.title3)
                            .foregroundStyle(colorForCategory(item.category))
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: 28)

                        if isLowStock {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 10, y: -10)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text(quantityLabel)
                            .font(.subheadline)
                            .foregroundStyle(isLowStock ? .red : .secondary)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 0) {
                Button {
                    decrementTrigger += 1
                    onDecrement()
                } label: {
                    Image(systemName: "minus")
                        .font(.caption.weight(.bold))
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .disabled(item.quantity <= 0)
                .sensoryFeedback(.impact(flexibility: .soft), trigger: decrementTrigger)

                Divider()
                    .frame(height: 16)

                Button {
                    incrementTrigger += 1
                    onIncrement()
                } label: {
                    Image(systemName: "plus")
                        .font(.caption.weight(.bold))
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: incrementTrigger)
            }
            .foregroundStyle(.blue)
            .background(Color(.systemGray5))
            .clipShape(.rect(cornerRadius: 8, style: .continuous))
        }
        .padding(.vertical, 6)
    }

    private func iconForCategory(_ category: String) -> String {
        switch category {
        case InventoryCategory.feed: return "leaf.fill"
        case InventoryCategory.medical: return "cross.case.fill"
        case InventoryCategory.bedding: return "bed.double.fill"
        case InventoryCategory.fencing: return "fence"
        case InventoryCategory.tools: return "wrench.and.screwdriver.fill"
        default: return "shippingbox.fill"
        }
    }

    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case InventoryCategory.feed: return .green
        case InventoryCategory.medical: return .red
        case InventoryCategory.bedding: return .purple
        case InventoryCategory.fencing: return .orange
        case InventoryCategory.tools: return .blue
        default: return .secondary
        }
    }
}

#Preview {
    NavigationStack {
        InventoryListView()
    }
    .modelContainer(for: InventoryItem.self, inMemory: true)
}
