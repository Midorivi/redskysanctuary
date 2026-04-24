import SwiftUI
import SwiftData

struct InventoryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var viewModel: InventoryViewModel
    var editingItem: InventoryItem?

    @State private var name = ""
    @State private var category = InventoryCategory.feed
    @State private var quantityText = ""
    @State private var unit = InventoryUnit.bales
    @State private var thresholdText = ""
    @State private var notes = ""
    @State private var saveTrigger = 0

    private var isEditing: Bool { editingItem != nil }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(quantityText) != nil
    }

    private let categoryOptions = [
        (InventoryCategory.feed, "Feed"),
        (InventoryCategory.medical, "Medical"),
        (InventoryCategory.bedding, "Bedding"),
        (InventoryCategory.fencing, "Fencing"),
        (InventoryCategory.tools, "Tools"),
        (InventoryCategory.other, "Other")
    ]

    private let unitOptions = [
        (InventoryUnit.bales, "Bales"),
        (InventoryUnit.bags, "Bags"),
        (InventoryUnit.rolls, "Rolls"),
        (InventoryUnit.boxes, "Boxes"),
        (InventoryUnit.each, "Each")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    nameSection
                    categorySection
                    quantitySection
                    thresholdSection
                    notesSection
                }
                .padding(16)
            }
            .background(Color(.systemBackground))
            .navigationTitle(isEditing ? "Edit Item" : "Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                        .sensoryFeedback(.success, trigger: saveTrigger)
                }
            }
            .onAppear { populateForEditing() }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var nameSection: some View {
        FormField(
            label: "Item Name",
            placeholder: "e.g. Timothy Hay",
            text: $name
        )
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Category")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Category", selection: $category) {
                ForEach(categoryOptions, id: \.0) { value, label in
                    Text(label).tag(value)
                }
            }
            .pickerStyle(.menu)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 8, style: .continuous))
        }
    }

    private var quantitySection: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Quantity")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("0", text: $quantityText)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 8, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Unit")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Unit", selection: $unit) {
                    ForEach(unitOptions, id: \.0) { value, label in
                        Text(label).tag(value)
                    }
                }
                .pickerStyle(.menu)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private var thresholdSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Reorder Threshold")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("Optional — alert when stock is low", text: $thresholdText)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 8, style: .continuous))

            Text("You'll see a low stock alert when quantity drops below this number.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var notesSection: some View {
        FormField(
            label: "Notes",
            placeholder: "Storage location, supplier, etc.",
            text: $notes,
            isMultiline: true
        )
    }

    private func populateForEditing() {
        guard let item = editingItem else { return }
        name = item.name
        category = item.category
        quantityText = item.quantity.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", item.quantity)
            : String(format: "%.1f", item.quantity)
        unit = item.unit ?? InventoryUnit.each
        if let threshold = item.reorderThreshold {
            thresholdText = threshold.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", threshold)
                : String(format: "%.1f", threshold)
        }
        notes = item.notes ?? ""
    }

    private func save() {
        guard let quantity = Double(quantityText) else { return }
        let threshold = Double(thresholdText)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let item = editingItem {
            item.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            item.category = category
            item.quantity = max(quantity, 0)
            item.unit = unit
            item.reorderThreshold = threshold
            item.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            try? modelContext.save()
        } else {
            viewModel.createItem(
                name: name,
                category: category,
                quantity: quantity,
                unit: unit,
                reorderThreshold: threshold,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
                in: modelContext
            )
        }

        saveTrigger += 1
        dismiss()
    }
}

#Preview("Add") {
    InventoryFormView(viewModel: InventoryViewModel())
        .modelContainer(for: InventoryItem.self, inMemory: true)
}

#Preview("Edit") {
    let item = InventoryItem(
        name: "Timothy Hay",
        category: InventoryCategory.feed,
        quantity: 12,
        unit: InventoryUnit.bales,
        reorderThreshold: 5,
        notes: "Stored in barn loft"
    )
    InventoryFormView(viewModel: InventoryViewModel(), editingItem: item)
        .modelContainer(for: InventoryItem.self, inMemory: true)
}
