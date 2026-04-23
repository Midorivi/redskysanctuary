import SwiftUI
import SwiftData

struct HealthSignFormView: View {
    let animal: Animal

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var symptom = ""
    @State private var severity = Severity.mild
    @State private var date = Date.now
    @State private var notes = ""
    @State private var saveCount = 0

    private let viewModel = HealthViewModel()

    private let severityOptions: [(label: String, value: String)] = [
        ("Mild", Severity.mild),
        ("Moderate", Severity.moderate),
        ("Severe", Severity.severe)
    ]

    private var canSave: Bool {
        !symptom.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FormField(
                        label: "Symptom",
                        placeholder: "e.g. Limping, loss of appetite",
                        text: $symptom
                    )

                    Picker("Severity", selection: $severity) {
                        ForEach(severityOptions, id: \.value) { option in
                            Text(option.label).tag(option.value)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Date Observed", selection: $date, displayedComponents: .date)
                }

                Section {
                    FormField(
                        label: "Notes",
                        placeholder: "Additional observations...",
                        text: $notes,
                        isMultiline: true
                    )
                }
            }
            .navigationTitle("Log Health Sign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
            .sensoryFeedback(.success, trigger: saveCount)
        }
    }

    private func save() {
        viewModel.addHealthSign(
            to: animal,
            symptom: symptom.trimmingCharacters(in: .whitespaces),
            severity: severity,
            date: date,
            notes: notes.isEmpty ? nil : notes,
            in: modelContext
        )
        saveCount += 1
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Animal.self, configurations: config)
    let animal = Animal(name: "Maple", animalType: AnimalType.horse)
    container.mainContext.insert(animal)

    return HealthSignFormView(animal: animal)
        .modelContainer(container)
}
