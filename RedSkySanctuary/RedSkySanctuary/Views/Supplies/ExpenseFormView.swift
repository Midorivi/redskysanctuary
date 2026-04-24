import SwiftUI
import SwiftData

struct ExpenseFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var viewModel: ExpenseViewModel

    @State private var amountText = ""
    @State private var date = Date.now
    @State private var category = ExpenseCategory.feed
    @State private var descriptionText = ""
    @State private var notes = ""
    @State private var saveTrigger = 0

    private var isValid: Bool {
        guard let amount = Double(amountText), amount > 0 else { return false }
        return true
    }

    private let categoryOptions: [(String, String, String)] = [
        (ExpenseCategory.feed, "Feed", "leaf.fill"),
        (ExpenseCategory.veterinary, "Veterinary", "cross.case.fill"),
        (ExpenseCategory.supplies, "Supplies", "shippingbox.fill"),
        (ExpenseCategory.facility, "Facility", "house.fill"),
        (ExpenseCategory.other, "Other", "ellipsis.circle.fill")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    amountSection
                    dateSection
                    categorySection
                    quickCategoryPresets
                    descriptionSection
                    notesSection
                }
                .padding(16)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Add Expense")
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
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Amount")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Text("$")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.system(.title2, design: .rounded).bold())
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 8, style: .continuous))
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Date")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 8, style: .continuous))
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Category")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Category", selection: $category) {
                ForEach(categoryOptions, id: \.0) { value, label, _ in
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

    private var quickCategoryPresets: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categoryOptions, id: \.0) { value, label, icon in
                    Button {
                        withAnimation(.spring(.snappy)) {
                            category = value
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: icon)
                                .font(.caption)
                            Text(label)
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(category == value ? Color.blue : Color(.systemGray6))
                        .foregroundStyle(category == value ? .white : .primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: category)
    }

    private var descriptionSection: some View {
        FormField(
            label: "Description",
            placeholder: "e.g. Monthly hay delivery",
            text: $descriptionText
        )
    }

    private var notesSection: some View {
        FormField(
            label: "Notes",
            placeholder: "Additional details",
            text: $notes,
            isMultiline: true
        )
    }

    private func save() {
        guard let amount = Double(amountText) else { return }
        let trimmedDesc = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        viewModel.addExpense(
            amount: amount,
            date: date,
            category: category,
            description: trimmedDesc.isEmpty ? nil : trimmedDesc,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            in: modelContext
        )

        saveTrigger += 1
        dismiss()
    }
}

#Preview {
    ExpenseFormView(viewModel: ExpenseViewModel())
        .modelContainer(for: Expense.self, inMemory: true)
}
