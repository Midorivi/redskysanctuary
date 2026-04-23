import SwiftData
import SwiftUI

struct TaskTemplateFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: TasksViewModel
    @State private var templateName = ""
    @State private var isRecurring = true
    @State private var recurrencePattern = RecurrencePattern.daily
    @State private var itemTitles = ["", ""]
    @State private var saveCount = 0

    private let onSave: () -> Void

    init(viewModel: TasksViewModel = TasksViewModel(), onSave: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: viewModel)
        self.onSave = onSave
    }

    private var canSave: Bool {
        !templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        itemTitles.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Template") {
                    TextField("Template name", text: $templateName)

                    Toggle("Recurring template", isOn: $isRecurring.animation(.spring(.snappy)))

                    if isRecurring {
                        Picker("Pattern", selection: $recurrencePattern) {
                            Text("Daily").tag(RecurrencePattern.daily)
                            Text("Weekly").tag(RecurrencePattern.weekly)
                            Text("Monthly").tag(RecurrencePattern.monthly)
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Section {
                    ForEach(itemTitles.indices, id: \.self) { index in
                        HStack(spacing: 12) {
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(.tertiary)

                            TextField("Checklist item", text: binding(for: index))

                            Button(role: .destructive) {
                                removeItem(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                            }
                            .disabled(itemTitles.count == 1)
                        }
                    }
                    .onMove(perform: moveItems)

                    Button {
                        itemTitles.append("")
                    } label: {
                        Label("Add Item", systemImage: "plus.circle.fill")
                    }
                } header: {
                    HStack {
                        Text("Checklist Items")
                        Spacer()
                        EditButton()
                    }
                } footer: {
                    Text("Reorder the checklist so each generated daily item keeps a stable sort order.")
                }
            }
            .navigationTitle("Add Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let template = viewModel.createTemplate(
                            name: templateName,
                            items: itemTitles,
                            isRecurring: isRecurring,
                            pattern: isRecurring ? recurrencePattern : nil,
                            in: modelContext
                        )

                        guard template != nil else { return }
                        saveCount += 1
                        onSave()
                        dismiss()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
            .sensoryFeedback(.success, trigger: saveCount)
        }
    }

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { itemTitles[index] },
            set: { itemTitles[index] = $0 }
        )
    }

    private func removeItem(at index: Int) {
        guard itemTitles.count > 1 else { return }
        itemTitles.remove(at: index)
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        itemTitles.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TaskTemplate.self,
        TaskTemplateItem.self,
        TaskInstance.self,
        TaskInstanceItem.self,
        configurations: config
    )

    return TaskTemplateFormView()
        .modelContainer(container)
}
