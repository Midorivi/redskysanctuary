import SwiftData
import SwiftUI

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \TaskTemplate.createdAt) private var templates: [TaskTemplate]
    @Query(sort: \TaskInstance.date) private var instances: [TaskInstance]

    @State private var viewModel = TasksViewModel()
    @State private var showTemplateForm = false
    @State private var showAdHocPrompt = false
    @State private var adHocTitle = ""

    private var today: Date {
        Calendar.current.startOfDay(for: .now)
    }

    private var recurringTemplates: [TaskTemplate] {
        templates
            .filter(\.isRecurring)
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    private var todaysInstances: [TaskInstance] {
        instances
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .sorted(by: sortInstances)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                headerActions
                    .padding(.horizontal, 16)

                maintenanceSection
                    .padding(.horizontal, 16)

                remindersSection
                    .padding(.horizontal, 16)

                todaysChecklistSection
                    .padding(.horizontal, 16)

                templatesSection
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .background(Color.appBackground)
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showTemplateForm) {
            TaskTemplateFormView(viewModel: viewModel) {
                showTemplateForm = false
                ensureTodayInstances()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .alert("Add One-Off Task", isPresented: $showAdHocPrompt) {
            TextField("Task title", text: $adHocTitle)
            Button("Cancel", role: .cancel) {
                adHocTitle = ""
            }
            Button("Add") {
                _ = viewModel.addAdHocTask(title: adHocTitle, to: today, in: modelContext)
                adHocTitle = ""
            }
            .disabled(adHocTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text("Create a one-off task for today.")
        }
        .task {
            ensureTodayInstances()
        }
    }

    private var headerActions: some View {
        HStack(spacing: 12) {
            actionButton(title: "Add Template", systemImage: "plus.square.on.square") {
                showTemplateForm = true
            }

            actionButton(title: "Add One-Off Task", systemImage: "plus.circle.fill") {
                showAdHocPrompt = true
            }
        }
    }

    private var maintenanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Maintenance")
                .sectionHeader()

            NavigationLink {
                MaintenanceListView()
            } label: {
                SanctuaryCard {
                    HStack(spacing: 12) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Maintenance Scheduler")
                                .font(.headline)
                            Text("Property tasks & animal care routines")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminders")
                .sectionHeader()

            NavigationLink {
                RemindersListView()
            } label: {
                SanctuaryCard {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.badge.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.orange)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reminders")
                                .font(.headline)
                            Text("One-time & recurring reminders")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var todaysChecklistSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Checklist")
                .sectionHeader()

            if todaysInstances.isEmpty {
                SanctuaryCard {
                    ContentUnavailableView(
                        "Nothing scheduled yet",
                        systemImage: "checklist",
                        description: Text("Add a one-off task or create a recurring template to build today's checklist.")
                    )
                }
            } else {
                ForEach(todaysInstances) { instance in
                    DailyChecklistView(instance: instance, viewModel: viewModel)
                }
            }
        }
    }

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Templates")
                .sectionHeader()

            if recurringTemplates.isEmpty {
                SanctuaryCard {
                    Text("No recurring templates yet")
                        .font(.headline)
                    Text("Create a reusable checklist for chores you repeat every day, week, or month.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(recurringTemplates) { template in
                    SanctuaryCard {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "repeat.circle.fill")
                                .font(.title3)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.blue)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(template.displayName)
                                    .font(.headline)

                                Text(template.recurrencePattern?.capitalized ?? "One time")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\((template.templateItems ?? []).count) items")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.surface)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private func actionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.scale)
    }

    private func ensureTodayInstances() {
        viewModel.generateMissingInstances(for: today, templates: recurringTemplates, in: modelContext)
    }

    private func sortInstances(lhs: TaskInstance, rhs: TaskInstance) -> Bool {
        switch (lhs.isAdHoc, rhs.isAdHoc) {
        case (false, true):
            return true
        case (true, false):
            return false
        default:
            return instanceTitle(lhs).localizedCaseInsensitiveCompare(instanceTitle(rhs)) == .orderedAscending
        }
    }

    private func instanceTitle(_ instance: TaskInstance) -> String {
        if instance.isAdHoc {
            return instance.items?.first?.title ?? "One-Off Task"
        }

        return instance.template?.displayName ?? "Checklist"
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
    let templateItems = [
        TaskTemplateItem(title: "Feed horses", sortOrder: 0),
        TaskTemplateItem(title: "Refresh water", sortOrder: 1),
        TaskTemplateItem(title: "Sweep aisle", sortOrder: 2)
    ]
    template.templateItems = templateItems
    templateItems.forEach { $0.template = template }

    let instance = TaskInstance(date: Calendar.current.startOfDay(for: .now), isAdHoc: false)
    instance.template = template
    let items = [
        TaskInstanceItem(title: "Feed horses", isCompleted: true, completedBy: "Avery", completedAt: .now, sortOrder: 0),
        TaskInstanceItem(title: "Refresh water", sortOrder: 1),
        TaskInstanceItem(title: "Sweep aisle", sortOrder: 2)
    ]
    instance.items = items
    items.forEach { $0.instance = instance }

    container.mainContext.insert(template)
    container.mainContext.insert(instance)

    return NavigationStack {
        TasksView()
    }
    .modelContainer(container)
}
