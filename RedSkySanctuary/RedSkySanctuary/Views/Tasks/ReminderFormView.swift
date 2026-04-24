import SwiftUI
import SwiftData

struct ReminderFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Animal.name) private var animals: [Animal]

    var viewModel: RemindersViewModel

    @State private var title = ""
    @State private var notes = ""
    @State private var date = Date.now
    @State private var isRecurring = false
    @State private var recurrencePattern = ReminderRecurrence.weekly
    @State private var hasEndDate = false
    @State private var recurrenceEndDate = Calendar.current.date(byAdding: .year, value: 1, to: .now)!
    @State private var selectedAnimalID: UUID?
    @State private var saveCount = 0

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var selectedAnimal: Animal? {
        guard let id = selectedAnimalID else { return nil }
        return animals.first { $0.id == id }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("e.g., Muzzle horses every spring", text: $title)
                }

                Section("Details") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)

                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Recurrence") {
                    Toggle("Recurring Reminder", isOn: $isRecurring)

                    if isRecurring {
                        Picker("Pattern", selection: $recurrencePattern) {
                            Text("Daily").tag(ReminderRecurrence.daily)
                            Text("Weekly").tag(ReminderRecurrence.weekly)
                            Text("Monthly").tag(ReminderRecurrence.monthly)
                            Text("Yearly").tag(ReminderRecurrence.yearly)
                        }

                        Toggle("End Date", isOn: $hasEndDate)

                        if hasEndDate {
                            DatePicker("Ends On", selection: $recurrenceEndDate, displayedComponents: .date)
                        }
                    }
                }

                Section("Link to Animal") {
                    Picker("Animal", selection: $selectedAnimalID) {
                        Text("None").tag(nil as UUID?)
                        ForEach(animals) { animal in
                            Text(animal.displayName).tag(animal.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createReminder(
                            title: title,
                            notes: notes.isEmpty ? nil : notes,
                            date: date,
                            isRecurring: isRecurring,
                            recurrencePattern: isRecurring ? recurrencePattern : nil,
                            recurrenceEndDate: (isRecurring && hasEndDate) ? recurrenceEndDate : nil,
                            relatedAnimal: selectedAnimal,
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Reminder.self, Animal.self, AnimalPhoto.self, HealthRecord.self, HealthSign.self,
        configurations: config
    )

    let horse = Animal(name: "Rosie", animalType: AnimalType.horse)
    let goat = Animal(name: "Biscuit", animalType: AnimalType.goat)
    container.mainContext.insert(horse)
    container.mainContext.insert(goat)

    return ReminderFormView(viewModel: RemindersViewModel())
        .modelContainer(container)
}
