import SwiftUI

struct MaintenanceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let task: MaintenanceTask
    var viewModel: MaintenanceViewModel

    @State private var completeCount = 0

    private var isOverdue: Bool {
        guard let dueDate = task.nextDueDate else { return false }
        return dueDate < .now
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                headerSection
                detailsSection
                recurrenceSection
                datesSection
                completeButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color.appBackground)
        .navigationTitle(task.title)
        .navigationBarTitleDisplayMode(.large)
        .sensoryFeedback(.success, trigger: completeCount)
    }

    private var headerSection: some View {
        SanctuaryCard {
            HStack(spacing: 12) {
                Image(systemName: task.category == MaintenanceCategory.property ? "wrench.fill" : "heart.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(task.category == MaintenanceCategory.property ? .blue : .pink)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(.title3, design: .rounded).bold())

                    Text(task.category == MaintenanceCategory.property ? "Property" : "Animal Care")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.surface)
                        .clipShape(Capsule())
                }

                Spacer()
            }

            if isOverdue {
                Label("Overdue", systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                    .padding(.top, 4)
            }
        }
    }

    private var detailsSection: some View {
        Group {
            if let notes = task.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .sectionHeader()

                    SanctuaryCard {
                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Schedule")
                .sectionHeader()

            SanctuaryCard {
                HStack(spacing: 12) {
                    Image(systemName: task.isRecurring ? "repeat" : "1.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.isRecurring ? "Recurring" : "One-time")
                            .font(.headline)

                        if task.isRecurring, let pattern = task.recurrencePattern {
                            Text(pattern.capitalized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
            }
        }
    }

    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dates")
                .sectionHeader()

            SanctuaryCard {
                VStack(spacing: 12) {
                    if let dueDate = task.nextDueDate {
                        HStack {
                            Label("Next Due", systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(dueDate, format: .dateTime.month(.abbreviated).day().year())
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(isOverdue ? .red : .primary)
                        }
                    }

                    if let completed = task.lastCompletedDate {
                        Divider()
                        HStack {
                            Label("Last Completed", systemImage: "checkmark.circle")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(completed, format: .dateTime.month(.abbreviated).day().year())
                                .font(.subheadline.weight(.semibold))
                        }
                    }

                    if let completedBy = task.completedBy {
                        Divider()
                        HStack {
                            Label("Completed By", systemImage: "person")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(completedBy)
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                }
            }
        }
    }

    private var completeButton: some View {
        Button {
            viewModel.markComplete(task)
            completeCount += 1
        } label: {
            Label("Mark Complete", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.green)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.scale)
    }
}

#Preview {
    let task = MaintenanceTask(
        title: "Fix barn door",
        category: MaintenanceCategory.property,
        notes: "The hinge on the east barn door needs replacement. Check with hardware store for correct size.",
        isRecurring: true,
        recurrencePattern: RecurrencePattern.weekly,
        nextDueDate: Calendar.current.date(byAdding: .day, value: -1, to: .now),
        lastCompletedDate: Calendar.current.date(byAdding: .day, value: -8, to: .now),
        completedBy: "Avery"
    )

    return NavigationStack {
        MaintenanceDetailView(task: task, viewModel: MaintenanceViewModel())
    }
}
