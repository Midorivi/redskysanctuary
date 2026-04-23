import SwiftData
import SwiftUI

struct DailyChecklistView: View {
    @Environment(\.modelContext) private var modelContext

    let instance: TaskInstance
    @State private var viewModel: TasksViewModel
    @State private var quickTaskTitle = ""
    @State private var completionCelebrationCount = 0

    init(instance: TaskInstance, viewModel: TasksViewModel = TasksViewModel()) {
        self.instance = instance
        _viewModel = State(initialValue: viewModel)
    }

    private var progress: (completed: Int, total: Int) {
        viewModel.completionProgress(for: instance)
    }

    private var sortedItems: [TaskInstanceItem] {
        viewModel.sortedItems(for: instance)
    }

    private var isFullyCompleted: Bool {
        progress.total > 0 && progress.completed == progress.total
    }

    private var title: String {
        if instance.isAdHoc {
            return instance.items?.first?.title ?? "One-Off Task"
        }

        return instance.template?.displayName ?? "Checklist"
    }

    var body: some View {
        SanctuaryCard {
            VStack(alignment: .leading, spacing: 16) {
                header
                progressSection

                ForEach(sortedItems) { item in
                    checklistRow(for: item)
                }

                addQuickTaskRow
            }
        }
        .sensoryFeedback(.success, trigger: completionCelebrationCount)
        .onChange(of: progress.completed) { _, newValue in
            if progress.total > 0 && newValue == progress.total {
                completionCelebrationCount += 1
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(instance.displayDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if instance.isAdHoc {
                Text("One-Off")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(progress.completed)/\(progress.total) done")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()

                Spacer()

                if isFullyCompleted {
                    Label("Complete", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                }
            }

            ProgressView(value: Double(progress.completed), total: Double(max(progress.total, 1)))
                .tint(isFullyCompleted ? .green : .blue)
        }
    }

    private func checklistRow(for item: TaskInstanceItem) -> some View {
        Button {
            viewModel.toggleItem(item)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .strikethrough(item.isCompleted, color: .secondary)

                    if item.isCompleted {
                        Text(completionSubtitle(for: item))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Not completed yet")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private var addQuickTaskRow: some View {
        HStack(spacing: 12) {
            TextField("Add quick task for this day", text: $quickTaskTitle)
                .textFieldStyle(.roundedBorder)

            Button {
                _ = viewModel.addAdHocTask(title: quickTaskTitle, to: instance.date, in: modelContext)
                quickTaskTitle = ""
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
            }
            .disabled(quickTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func completionSubtitle(for item: TaskInstanceItem) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        let user = item.completedBy ?? "Sanctuary Team"
        if let completedAt = item.completedAt {
            return "Completed by \(user) at \(formatter.string(from: completedAt))"
        }

        return "Completed by \(user)"
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

    let template = TaskTemplate(name: "Morning Barn", isRecurring: true, recurrencePattern: RecurrencePattern.daily)
    let instance = TaskInstance(date: Calendar.current.startOfDay(for: .now), isAdHoc: false)
    instance.template = template
    let items = [
        TaskInstanceItem(title: "Feed horses", isCompleted: true, completedBy: "Avery", completedAt: .now, sortOrder: 0),
        TaskInstanceItem(title: "Refresh water", sortOrder: 1),
        TaskInstanceItem(title: "Sweep aisle", sortOrder: 2)
    ]
    instance.items = items
    items.forEach { $0.instance = instance }
    container.mainContext.insert(instance)

    return DailyChecklistView(instance: instance)
        .padding()
        .modelContainer(container)
}
