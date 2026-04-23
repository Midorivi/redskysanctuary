import SwiftUI
import SwiftData

struct HealthSignListView: View {
    let animal: Animal

    @Environment(\.modelContext) private var modelContext
    @State private var showAddSign = false
    @State private var resolveCount = 0
    @State private var deleteCount = 0

    private let viewModel = HealthViewModel()

    private var activeSigns: [HealthSign] {
        (animal.healthSigns ?? [])
            .filter { !$0.isResolved }
            .sorted { $0.date > $1.date }
    }

    private var resolvedSigns: [HealthSign] {
        (animal.healthSigns ?? [])
            .filter { $0.isResolved }
            .sorted { ($0.resolvedDate ?? $0.date) > ($1.resolvedDate ?? $1.date) }
    }

    var body: some View {
        List {
            if activeSigns.isEmpty && resolvedSigns.isEmpty {
                ContentUnavailableView(
                    "No Health Signs",
                    systemImage: "checkmark.seal",
                    description: Text("Logged health signs will appear here")
                )
                .listRowBackground(Color.clear)
            }

            if !activeSigns.isEmpty {
                Section("Active") {
                    ForEach(activeSigns) { sign in
                        activeSignRow(sign)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteHealthSign(activeSigns[index], in: modelContext)
                        }
                        deleteCount += 1
                    }
                }
            }

            if !resolvedSigns.isEmpty {
                Section("Resolved") {
                    ForEach(resolvedSigns) { sign in
                        resolvedSignRow(sign)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteHealthSign(resolvedSigns[index], in: modelContext)
                        }
                        deleteCount += 1
                    }
                }
            }
        }
        .navigationTitle("Health Signs")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSign = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSign) {
            HealthSignFormView(animal: animal)
        }
        .sensoryFeedback(.impact, trigger: resolveCount)
        .sensoryFeedback(.success, trigger: deleteCount)
    }

    private func activeSignRow(_ sign: HealthSign) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(sign.symptom)
                    .font(.body)
                    .foregroundStyle(.primary)

                Text("Since \(sign.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            severityBadge(sign.severity)

            Button {
                viewModel.resolveHealthSign(sign)
                resolveCount += 1
            } label: {
                Image(systemName: "checkmark.circle")
                    .font(.title3)
                    .foregroundStyle(.green)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    private func resolvedSignRow(_ sign: HealthSign) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(sign.symptom)
                    .font(.body)
                    .foregroundStyle(.secondary)

                if let resolvedDate = sign.resolvedDate {
                    Text("Resolved \(resolvedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            severityBadge(sign.severity)
        }
        .padding(.vertical, 4)
    }

    private func severityBadge(_ severity: String) -> some View {
        Text(severity.capitalized)
            .font(.caption.weight(.medium))
            .foregroundStyle(severityColor(severity))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(severityColor(severity).opacity(0.12))
            .clipShape(Capsule())
    }

    private func severityColor(_ severity: String) -> Color {
        switch severity {
        case Severity.mild: .green
        case Severity.moderate: .yellow
        case Severity.severe: .red
        default: .gray
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Animal.self, configurations: config)

    let animal = Animal(name: "Maple", animalType: AnimalType.horse)
    container.mainContext.insert(animal)

    let s1 = HealthSign(
        symptom: "Slight limp on left foreleg",
        severity: Severity.moderate,
        animal: animal
    )
    let s2 = HealthSign(
        symptom: "Reduced appetite",
        severity: Severity.mild,
        isResolved: true,
        resolvedDate: Calendar.current.date(byAdding: .day, value: -3, to: .now),
        animal: animal
    )
    let s3 = HealthSign(
        symptom: "Swelling on right hock",
        severity: Severity.severe,
        animal: animal
    )
    container.mainContext.insert(s1)
    container.mainContext.insert(s2)
    container.mainContext.insert(s3)

    return NavigationStack {
        HealthSignListView(animal: animal)
    }
    .modelContainer(container)
}
