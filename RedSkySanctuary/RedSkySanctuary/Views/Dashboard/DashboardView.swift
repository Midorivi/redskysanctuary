import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var allInstances: [TaskInstance]
    @Query(sort: \Reminder.date) private var reminders: [Reminder]
    @Query private var healthRecords: [HealthRecord]
    @Query private var maintenanceTasks: [MaintenanceTask]
    @Query private var healthSigns: [HealthSign]
    @Query private var inventoryItems: [InventoryItem]
    @Query(filter: #Predicate<Animal> { $0.status == "active" }, sort: \Animal.name)
    private var activeAnimals: [Animal]

    @State private var viewModel = DashboardViewModel()
    @State private var showAddAnimal = false
    @State private var showLogHealth = false
    @State private var showAddExpense = false
    @State private var showEmergency = false
    @State private var quickActionTrigger = 0

    private var todaysInstances: [TaskInstance] {
        let calendar = Calendar.current
        return allInstances.filter { calendar.isDateInToday($0.date) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                welcomeHeader
                todaysTasksSection
                upcomingSection
                attentionSection
                quickActionsRow
                animalCountCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CloudSyncStatusIndicator()
            }
        }
        .sheet(isPresented: $showAddAnimal) {
            NavigationStack { AnimalFormView() }
        }
        .sheet(isPresented: $showLogHealth) {
            NavigationStack { AnimalsListView() }
        }
        .sheet(isPresented: $showAddExpense) {
            NavigationStack { ExpenseFormView(viewModel: ExpenseViewModel()) }
        }
        .sheet(isPresented: $showEmergency) {
            NavigationStack { EmergencyView() }
        }
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Red Sky Sanctuary")
                .font(.system(.title3, design: .rounded).bold())
                .foregroundStyle(.primary)

            Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    // MARK: - Today's Tasks

    private var todaysTasksSection: some View {
        let instances = todaysInstances
        let progress = viewModel.todaysTaskProgress(instances: instances)

        return NavigationLink {
            TasksView()
        } label: {
            GroupBox {
                if instances.isEmpty {
                    Text("No tasks scheduled for today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("\(progress.completed) of \(progress.total) completed")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(progress.completed)/\(progress.total)")
                                .font(.subheadline.bold())
                                .monospacedDigit()
                                .foregroundStyle(progress.completed == progress.total && progress.total > 0 ? .green : .blue)
                        }

                        ProgressView(value: progress.total > 0 ? Double(progress.completed) / Double(progress.total) : 0)
                            .tint(progress.completed == progress.total && progress.total > 0 ? .green : .blue)

                        ForEach(Array(instances.enumerated()), id: \.offset) { _, instance in
                            taskInstanceRow(instance)
                        }
                    }
                }
            } label: {
                Label("Today's Tasks", systemImage: "checklist")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }

    private func taskInstanceRow(_ instance: TaskInstance) -> some View {
        let items = instance.items ?? []
        let completed = items.filter(\.isCompleted).count
        let total = items.count
        let name = instance.isAdHoc ? "Ad Hoc" : (instance.template?.displayName ?? "Task")

        return HStack(spacing: 8) {
            Image(systemName: completed == total && total > 0 ? "checkmark.circle.fill" : "circle")
                .font(.subheadline)
                .foregroundStyle(completed == total && total > 0 ? .green : .secondary)

            Text(name)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            Text("\(completed)/\(total)")
                .font(.caption.bold())
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Upcoming Events

    private var upcomingSection: some View {
        let events = viewModel.upcomingEvents(
            reminders: reminders,
            records: healthRecords,
            tasks: maintenanceTasks
        )

        return GroupBox {
            if events.isEmpty {
                Text("No upcoming events")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(events.enumerated()), id: \.offset) { _, event in
                        upcomingEventRow(title: event.title, date: event.date, type: event.type)
                    }
                }
            }
        } label: {
            Label("Upcoming", systemImage: "calendar")
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }

    private func upcomingEventRow(title: String, date: Date, type: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: eventIcon(for: type))
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(eventColor(for: type))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Text(date, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Attention Needed

    private var attentionSection: some View {
        let items = viewModel.attentionItems(
            signs: healthSigns,
            tasks: maintenanceTasks,
            inventory: inventoryItems
        )

        return GroupBox {
            if items.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("All clear — nothing needs attention")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        attentionRow(title: item.title, type: item.type, severity: item.severity)
                    }
                }
            }
        } label: {
            HStack {
                Label("Attention Needed", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)

                if !items.isEmpty {
                    Spacer()
                    Text("\(items.count)")
                        .font(.caption.bold())
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.red, in: Capsule())
                }
            }
        }
    }

    private func attentionRow(title: String, type: String, severity: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: attentionIcon(for: type))
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(severityColor(for: severity))
                .frame(width: 28)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            Text(severity.capitalized)
                .font(.caption2.bold())
                .foregroundStyle(severityColor(for: severity))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(severityColor(for: severity).opacity(0.15), in: Capsule())
        }
    }

    // MARK: - Quick Actions

    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            quickActionButton(icon: "plus.circle.fill", label: "Add Animal", color: .blue) {
                showAddAnimal = true
            }
            quickActionButton(icon: "heart.text.clipboard", label: "Log Health", color: .green) {
                showLogHealth = true
            }
            quickActionButton(icon: "dollarsign.circle.fill", label: "Add Expense", color: .orange) {
                showAddExpense = true
            }
            quickActionButton(icon: "light.beacon.max", label: "Emergency", color: .red) {
                showEmergency = true
            }
        }
        .sensoryFeedback(.impact, trigger: quickActionTrigger)
    }

    private func quickActionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            quickActionTrigger += 1
            action()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(color)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 12, style: .continuous))

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Animal Count

    private var animalCountCard: some View {
        let counts = viewModel.animalCountByType(animals: activeAnimals)

        return GroupBox {
            if counts.isEmpty {
                Text("No animals in sanctuary yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: 16) {
                    ForEach(Array(counts.enumerated()), id: \.offset) { _, entry in
                        HStack(spacing: 4) {
                            Text(emoji(for: entry.type))
                                .font(.title3)
                            Text("\(entry.count)")
                                .font(.title3.bold())
                                .monospacedDigit()
                                .foregroundStyle(.primary)
                        }
                    }
                    Spacer()
                    Text("\(activeAnimals.count) total")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        } label: {
            Label("Animals", systemImage: "pawprint.fill")
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Helpers

    private func eventIcon(for type: String) -> String {
        switch type {
        case "reminder": "bell.fill"
        case "vet_visit": "cross.case.fill"
        case "maintenance": "wrench.and.screwdriver.fill"
        default: "calendar"
        }
    }

    private func eventColor(for type: String) -> Color {
        switch type {
        case "reminder": .blue
        case "vet_visit": .purple
        case "maintenance": .orange
        default: .secondary
        }
    }

    private func attentionIcon(for type: String) -> String {
        switch type {
        case "health": "heart.text.clipboard"
        case "maintenance": "wrench.and.screwdriver.fill"
        case "inventory": "shippingbox.fill"
        default: "exclamationmark.triangle.fill"
        }
    }

    private func severityColor(for severity: String) -> Color {
        switch severity {
        case Severity.severe, "overdue": .red
        case Severity.moderate: .orange
        case Severity.mild, "low": .yellow
        default: .secondary
        }
    }

    private func emoji(for type: String) -> String {
        switch type {
        case AnimalType.horse: "🐴"
        case AnimalType.goat: "🐐"
        case AnimalType.pig: "🐷"
        case AnimalType.chicken: "🐔"
        case AnimalType.duck: "🦆"
        default: "🐾"
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(previewDashboardContainer)
}

private let previewDashboardContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Animal.self, AnimalPhoto.self,
        HealthRecord.self, HealthSign.self,
        Reminder.self,
        TaskInstance.self, TaskInstanceItem.self,
        TaskTemplate.self, TaskTemplateItem.self,
        MaintenanceTask.self, InventoryItem.self,
        Expense.self,
        EmergencyContact.self, EmergencyProtocol.self,
        configurations: config
    )
    return container
}()
