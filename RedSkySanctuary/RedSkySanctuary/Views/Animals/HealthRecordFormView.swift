import SwiftUI
import SwiftData

struct HealthRecordFormView: View {
    let animal: Animal

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var recordType = RecordType.checkup
    @State private var title = ""
    @State private var date = Date.now
    @State private var veterinarian = ""
    @State private var hasNextVisit = false
    @State private var nextVisitDate = Date.now
    @State private var notes = ""
    @State private var saveCount = 0

    private let viewModel = HealthViewModel()

    private let recordTypes: [(label: String, value: String)] = [
        ("Vaccination", RecordType.vaccination),
        ("Vet Visit", RecordType.vetVisit),
        ("Treatment", RecordType.treatment),
        ("Checkup", RecordType.checkup),
        ("Injury", RecordType.injury),
        ("Illness", RecordType.illness)
    ]

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Record Type", selection: $recordType) {
                        ForEach(recordTypes, id: \.value) { option in
                            Text(option.label).tag(option.value)
                        }
                    }

                    FormField(
                        label: "Title",
                        placeholder: "e.g. Annual vaccination",
                        text: $title
                    )

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section {
                    FormField(
                        label: "Veterinarian",
                        placeholder: "e.g. Dr. Smith",
                        text: $veterinarian
                    )

                    Toggle("Schedule Next Visit", isOn: $hasNextVisit)

                    if hasNextVisit {
                        DatePicker("Next Visit", selection: $nextVisitDate, displayedComponents: .date)
                    }
                }

                Section {
                    FormField(
                        label: "Notes",
                        placeholder: "Additional details...",
                        text: $notes,
                        isMultiline: true
                    )
                }
            }
            .navigationTitle("Add Health Record")
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
        viewModel.addHealthRecord(
            to: animal,
            recordType: recordType,
            title: title.trimmingCharacters(in: .whitespaces),
            date: date,
            notes: notes.isEmpty ? nil : notes,
            veterinarian: veterinarian.isEmpty ? nil : veterinarian.trimmingCharacters(in: .whitespaces),
            nextVisitDate: hasNextVisit ? nextVisitDate : nil,
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

    return HealthRecordFormView(animal: animal)
        .modelContainer(container)
}
