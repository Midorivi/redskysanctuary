import SwiftUI

struct SettingsView: View {
    @AppStorage("notifyReminders") private var notifyReminders = true
    @AppStorage("notifyTasks") private var notifyTasks = true
    @AppStorage("notifyMaintenance") private var notifyMaintenance = true
    @AppStorage("notifyVetVisits") private var notifyVetVisits = true

    @State private var showClearConfirmation = false
    @State private var showExportSheet = false
    @State private var clearCount = 0

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            notificationsSection
            appearanceSection
            dataSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert("Clear All Data", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear Everything", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all animals, records, tasks, and reminders. This cannot be undone.")
        }
        .sheet(isPresented: $showExportSheet) {
            ShareSheet(activityItems: [generateExportPlaceholder()])
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $notifyReminders) {
                settingsRow(icon: "bell.badge.fill", color: .purple, title: "Reminders")
            }
            Toggle(isOn: $notifyTasks) {
                settingsRow(icon: "checklist", color: .blue, title: "Tasks")
            }
            Toggle(isOn: $notifyMaintenance) {
                settingsRow(icon: "wrench.and.screwdriver.fill", color: .orange, title: "Maintenance")
            }
            Toggle(isOn: $notifyVetVisits) {
                settingsRow(icon: "stethoscope", color: .green, title: "Vet Visits")
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Choose which categories send push notifications.")
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            HStack(spacing: 12) {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Theme")
                        .font(.body)
                    Text("Follows system light/dark mode")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var dataSection: some View {
        Section {
            Button {
                showExportSheet = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 28)

                    Text("Export Data")
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 4)
            }
            .sensoryFeedback(.impact, trigger: showExportSheet)

            Button(role: .destructive) {
                showClearConfirmation = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 28)

                    Text("Clear All Data")
                        .font(.body)
                }
                .padding(.vertical, 4)
            }
            .sensoryFeedback(.warning, trigger: clearCount)
        } header: {
            Text("Data")
        } footer: {
            Text("Export creates a JSON snapshot. Clear removes all local and synced data.")
        }
    }

    private func settingsRow(icon: String, color: Color, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 28)
            Text(title)
                .font(.body)
        }
    }

    private func generateExportPlaceholder() -> URL {
        let placeholder = ["export": "Red Sky Sanctuary data export placeholder", "version": "1.0"]
        let data = (try? JSONSerialization.data(withJSONObject: placeholder, options: .prettyPrinted)) ?? Data()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("RedSkySanctuary-Export.json")
        try? data.write(to: url)
        return url
    }

    private func clearAllData() {
        do {
            try modelContext.delete(model: Animal.self)
            try modelContext.delete(model: HealthRecord.self)
            try modelContext.delete(model: TaskInstance.self)
            try modelContext.delete(model: TaskTemplate.self)
            try modelContext.delete(model: Reminder.self)
            try modelContext.delete(model: MaintenanceTask.self)
            try modelContext.delete(model: InventoryItem.self)
            try modelContext.delete(model: Expense.self)
            try modelContext.delete(model: EmergencyContact.self)
            try modelContext.delete(model: EmergencyProtocol.self)
            try modelContext.save()
            clearCount += 1
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
