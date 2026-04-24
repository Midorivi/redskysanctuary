import SwiftUI
import SwiftData

struct EmergencyContactFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var role = ContactRole.veterinarian
    @State private var phone = ""
    @State private var email = ""
    @State private var notes = ""
    @State private var isPrimary = false
    @State private var saveCount = 0

    private let roleOptions: [(label: String, value: String)] = [
        ("Veterinarian", ContactRole.veterinarian),
        ("Farrier", ContactRole.farrier),
        ("Poison Control", ContactRole.poisonControl),
        ("Animal Control", ContactRole.animalControl),
        ("Neighbor", ContactRole.neighbor),
        ("Other", ContactRole.other),
    ]

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FormField(
                        label: "Name",
                        placeholder: "e.g. Dr. Smith",
                        text: $name
                    )

                    Picker("Role", selection: $role) {
                        ForEach(roleOptions, id: \.value) { option in
                            Text(option.label).tag(option.value)
                        }
                    }

                    FormField(
                        label: "Phone",
                        placeholder: "e.g. (555) 123-4567",
                        text: $phone
                    )
                }

                Section {
                    FormField(
                        label: "Email",
                        placeholder: "e.g. dr.smith@clinic.com",
                        text: $email
                    )
                }

                Section {
                    FormField(
                        label: "Notes",
                        placeholder: "Additional details...",
                        text: $notes,
                        isMultiline: true
                    )

                    Toggle("Primary Contact", isOn: $isPrimary)
                }
            }
            .navigationTitle("Add Contact")
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
        let contact = EmergencyContact(
            name: name.trimmingCharacters(in: .whitespaces),
            role: role,
            phone: phone.trimmingCharacters(in: .whitespaces),
            email: email.isEmpty ? nil : email.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes,
            isPrimary: isPrimary
        )
        modelContext.insert(contact)
        saveCount += 1
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: EmergencyContact.self,
        configurations: config
    )

    return EmergencyContactFormView()
        .modelContainer(container)
}
