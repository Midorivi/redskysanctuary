import SwiftUI
import SwiftData

struct MaintenanceListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MaintenanceTask.title) private var tasks: [MaintenanceTask]
    @State private var viewModel = MaintenanceViewModel()
    @State private var showForm = false

    private var propertyTasks: [MaintenanceTask] {
        tasks.filter { $0.category == MaintenanceCategory.property }
    }

    private var animalCareTasks: [MaintenanceTask] {
        tasks.filter { $0.category == MaintenanceCategory.animal_care }
    }

    private var overdueTasks: Set<UUID> {
        Set(viewModel.overdueTasks(from: tasks).map(\.id))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                taskSection(title: "Property", icon: "wrench.fill", tasks: propertyTasks)
                taskSection(title: "Animal Care", icon: "heart.fill", tasks: animalCareTasks)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color.appBackground)
        .navigationTitle("Maintenance")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: UUID.self) { taskID in
            if let task = tasks.first(where: { $0.id == taskID }) {
                MaintenanceDetailView(task: task, viewModel: viewModel)
            }
        }
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
        .sheet(isPresented: $showForm) {
            MaintenanceFormView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private func taskSection(title: String, icon: String, tasks: [MaintenanceTask]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .sectionHeader()

            if tasks.isEmpty {
                SanctuaryCard {
                    ContentUnavailableView(
                        "No \(title) Tasks",
                        systemImage: icon,
                        description: Text("Tap + to add a maintenance task.")
                    )
                }
            } else {
                ForEach(tasks) { task in
                    NavigationLink(value: task.id) {
                        maintenanceRow(task)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func maintenanceRow(_ task: MaintenanceTask) -> some View {
        SanctuaryCard {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: task.category == MaintenanceCategory.property ? "wrench.fill" : "heart.fill")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(task.category == MaintenanceCategory.property ? .blue : .pink)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)

                    if let dueDate = task.nextDueDate {
                        Text("Due: \(dueDate, format: .dateTime.month(.abbreviated).day())")
                            .font(.subheadline)
                            .foregroundStyle(overdueTasks.contains(task.id) ? .red : .secondary)
                    }

                    if let completed = task.lastCompletedDate {
                        Text("Last: \(completed, format: .dateTime.month(.abbreviated).day())")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                if task.isRecurring {
                    Image(systemName: "repeat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MaintenanceTask.self, configurations: config)

    let task1 = MaintenanceTask(
        title: "Fix barn door",
        category: MaintenanceCategory.property,
        isRecurring: false,
        nextDueDate: Calendar.current.date(byAdding: .day, value: -2, to: .now)
    )
    let task2 = MaintenanceTask(
        title: "Farrier visit",
        category: MaintenanceCategory.animal_care,
        isRecurring: true,
        recurrencePattern: RecurrencePattern.monthly,
        nextDueDate: Calendar.current.date(byAdding: .day, value: 5, to: .now)
    )
    container.mainContext.insert(task1)
    container.mainContext.insert(task2)

    return NavigationStack {
        MaintenanceListView()
    }
    .modelContainer(container)
}
