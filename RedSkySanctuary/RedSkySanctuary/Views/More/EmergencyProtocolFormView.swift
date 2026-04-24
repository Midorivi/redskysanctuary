import SwiftUI
import SwiftData

struct EmergencyProtocolFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var animalType = AnimalTypeForEmergency.general
    @State private var situation = EmergencySituation.other
    @State private var customSituation = ""
    @State private var steps = ""
    @State private var notes = ""
    @State private var saveCount = 0

    private let animalTypeOptions: [(label: String, value: String)] = [
        ("Horse", AnimalTypeForEmergency.horse),
        ("Goat", AnimalTypeForEmergency.goat),
        ("Pig", AnimalTypeForEmergency.pig),
        ("Chicken", AnimalTypeForEmergency.chicken),
        ("Duck", AnimalTypeForEmergency.duck),
        ("General", AnimalTypeForEmergency.general),
    ]

    private let situationOptions: [(label: String, value: String)] = [
        ("Choking", EmergencySituation.choking),
        ("Colic", EmergencySituation.colic),
        ("Injury", EmergencySituation.injury),
        ("Poisoning", EmergencySituation.poisoning),
        ("Heat Stress", EmergencySituation.heatStress),
        ("Lameness", EmergencySituation.lameness),
        ("Respiratory", EmergencySituation.respiratory),
        ("Other", EmergencySituation.other),
    ]

    private var effectiveSituation: String {
        situation == EmergencySituation.other
            ? customSituation.trimmingCharacters(in: .whitespaces)
            : situation
    }

    private var canSave: Bool {
        !effectiveSituation.isEmpty &&
        !steps.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Animal Type", selection: $animalType) {
                        ForEach(animalTypeOptions, id: \.value) { option in
                            Text(option.label).tag(option.value)
                        }
                    }

                    Picker("Situation", selection: $situation) {
                        ForEach(situationOptions, id: \.value) { option in
                            Text(option.label).tag(option.value)
                        }
                    }

                    if situation == EmergencySituation.other {
                        FormField(
                            label: "Custom Situation",
                            placeholder: "Describe the situation",
                            text: $customSituation
                        )
                    }
                }

                Section {
                    FormField(
                        label: "Steps",
                        placeholder: "1. Check for breathing\n2. Call veterinarian\n3. Keep animal calm",
                        text: $steps,
                        isMultiline: true
                    )
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
            .navigationTitle("Add Protocol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .sensoryFeedback(.success, trigger: saveCount)
        }
    }

    private func save() {
        let proto = EmergencyProtocol(
            animalType: animalType,
            situation: effectiveSituation,
            steps: steps.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(proto)
        saveCount += 1
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: EmergencyProtocol.self,
        configurations: config
    )

    return EmergencyProtocolFormView()
        .modelContainer(container)
}
