import SwiftUI

struct MaintenanceFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var viewModel: MaintenanceViewModel

    @State private var title = ""
    @State private var category = MaintenanceCategory.property
    @State private var notes = ""
    @State private var isRecurring = false
    @State private var recurrencePattern = RecurrencePattern.weekly
    @State private var nextDueDate = Date.now
    @State private var saveCount = 0

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task Title", text: $title)

                    Picker("Category", selection: $category) {
                        Text("Property").tag(MaintenanceCategory.property)
                        Text("Animal Care").tag(MaintenanceCategory.animal_care)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Details") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)

                    DatePicker("Next Due Date", selection: $nextDueDate, displayedComponents: .date)
                }

                Section("Recurrence") {
                    Toggle("Recurring Task", isOn: $isRecurring)

                    if isRecurring {
                        Picker("Pattern", selection: $recurrencePattern) {
                            Text("Daily").tag(RecurrencePattern.daily)
                            Text("Weekly").tag(RecurrencePattern.weekly)
                            Text("Monthly").tag(RecurrencePattern.monthly)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createTask(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            category: category,
                            notes: notes.isEmpty ? nil : notes,
                            isRecurring: isRecurring,
                            recurrencePattern: isRecurring ? recurrencePattern : nil,
                            nextDueDate: nextDueDate,
                            in: modelContext
                        )
                        saveCount += 1
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .sensoryFeedback(.success, trigger: saveCount)
        }
    }
}

#Preview {
    MaintenanceFormView(viewModel: MaintenanceViewModel())
}
