import SwiftUI
import SwiftData

struct RemindersListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reminder.date) private var reminders: [Reminder]
    @State private var viewModel = RemindersViewModel()
    @State private var showForm = false
    @State private var completionCount = 0

    private var upcoming: [Reminder] {
        viewModel.upcomingReminders(from: reminders)
    }

    private var recurring: [Reminder] {
        viewModel.recurringReminders(from: reminders)
    }

    private var completed: [Reminder] {
        viewModel.completedReminders(from: reminders)
    }

    var body: some View {
        List {
            upcomingSection
            recurringSection
            completedSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showForm = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .overlay {
            if reminders.isEmpty {
                ContentUnavailableView(
                    "No Reminders",
                    systemImage: "bell.slash",
                    description: Text("Tap + to create your first reminder.")
                )
            }
        }
        .sheet(isPresented: $showForm) {
            ReminderFormView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sensoryFeedback(.success, trigger: completionCount)
    }

    private var upcomingSection: some View {
        Section {
            if upcoming.isEmpty {
                ContentUnavailableView(
                    "No Upcoming Reminders",
                    systemImage: "clock",
                    description: Text("Tap + to create a reminder.")
                )
            } else {
                ForEach(upcoming) { reminder in
                    reminderRow(reminder)
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.completeReminder(reminder)
                                completionCount += 1
                            } label: {
                                Label("Complete", systemImage: "checkmark.circle.fill")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteReminder(reminder, in: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                }
            }
        } header: {
            Label("Upcoming", systemImage: "clock.fill")
        }
    }

    private var recurringSection: some View {
        Section {
            if recurring.isEmpty {
                ContentUnavailableView(
                    "No Recurring Reminders",
                    systemImage: "repeat",
                    description: Text("Create a recurring reminder to track repeating tasks.")
                )
            } else {
                ForEach(recurring) { reminder in
                    reminderRow(reminder)
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.completeReminder(reminder)
                                completionCount += 1
                            } label: {
                                Label("Complete", systemImage: "checkmark.circle.fill")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteReminder(reminder, in: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                }
            }
        } header: {
            Label("Recurring", systemImage: "repeat")
        }
    }

    private var completedSection: some View {
        Section {
            if completed.isEmpty {
                ContentUnavailableView(
                    "No Completed Reminders",
                    systemImage: "checkmark.circle",
                    description: Text("Swipe right on a reminder to mark it done.")
                )
            } else {
                ForEach(completed) { reminder in
                    completedRow(reminder)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteReminder(reminder, in: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                }
            }
        } header: {
            Label("Completed", systemImage: "checkmark.circle.fill")
        }
    }

    private func reminderRow(_ reminder: Reminder) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: reminder.isRecurring ? "repeat.circle.fill" : "bell.fill")
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(reminder.isRecurring ? .purple : .orange)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)

                Text(reminder.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let animal = reminder.relatedAnimal {
                    Label(animal.displayName, systemImage: "pawprint.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if reminder.isRecurring {
                Text(reminder.recurrencePattern?.capitalized ?? "")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.surface)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }

    private func completedRow(_ reminder: Reminder) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.green)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                    .strikethrough()
                    .foregroundStyle(.secondary)

                Text(reminder.date, format: .dateTime.month(.abbreviated).day())
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Reminder.self, Animal.self, AnimalPhoto.self, HealthRecord.self, HealthSign.self,
        configurations: config
    )

    let horse = Animal(name: "Rosie", animalType: AnimalType.horse)
    container.mainContext.insert(horse)

    let reminder1 = Reminder(
        title: "Muzzle horses every spring",
        date: Calendar.current.date(byAdding: .day, value: 3, to: .now)!,
        isRecurring: true,
        recurrencePattern: ReminderRecurrence.yearly,
        relatedAnimal: horse
    )
    let reminder2 = Reminder(
        title: "Schedule vet checkup",
        date: Calendar.current.date(byAdding: .day, value: 7, to: .now)!
    )
    let reminder3 = Reminder(
        title: "Order hay delivery",
        date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
        isCompleted: true
    )
    container.mainContext.insert(reminder1)
    container.mainContext.insert(reminder2)
    container.mainContext.insert(reminder3)

    return NavigationStack {
        RemindersListView()
    }
    .modelContainer(container)
}
