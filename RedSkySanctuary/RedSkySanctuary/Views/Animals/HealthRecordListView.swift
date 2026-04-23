import SwiftUI
import SwiftData

struct HealthRecordListView: View {
    let animal: Animal

    @Environment(\.modelContext) private var modelContext
    @State private var selectedFilter: String? = nil
    @State private var showAddRecord = false
    @State private var deleteCount = 0

    private let viewModel = HealthViewModel()

    private let filterOptions: [(label: String, value: String?)] = [
        ("All", nil),
        ("Vaccinations", RecordType.vaccination),
        ("Vet Visits", RecordType.vetVisit),
        ("Treatments", RecordType.treatment),
        ("Checkups", RecordType.checkup)
    ]

    private var records: [HealthRecord] {
        viewModel.filteredRecords(for: animal, by: selectedFilter)
    }

    var body: some View {
        List {
            Section {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(filterOptions, id: \.label) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            if records.isEmpty {
                ContentUnavailableView(
                    "No Records",
                    systemImage: "heart.text.clipboard",
                    description: Text("Health records will appear here")
                )
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(records) { record in
                        recordRow(record)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteHealthRecord(records[index], in: modelContext)
                        }
                        deleteCount += 1
                    }
                }
            }
        }
        .navigationTitle("Health Records")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddRecord = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddRecord) {
            HealthRecordFormView(animal: animal)
        }
        .sensoryFeedback(.success, trigger: deleteCount)
    }

    private func recordRow(_ record: HealthRecord) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName(for: record.recordType))
                .foregroundStyle(iconColor(for: record.recordType))
                .symbolRenderingMode(.hierarchical)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.title.isEmpty ? record.recordType.replacingOccurrences(of: "_", with: " ").capitalized : record.title)
                    .font(.body)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Text(record.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let vet = record.veterinarian, !vet.isEmpty {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text(vet)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Text(record.recordType.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(.tertiarySystemBackground))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }

    private func iconName(for type: String) -> String {
        switch type {
        case RecordType.vaccination: "syringe"
        case RecordType.vetVisit: "stethoscope"
        case RecordType.treatment: "cross.case"
        case RecordType.checkup: "heart.text.clipboard"
        case RecordType.injury: "bandage"
        case RecordType.illness: "pills"
        default: "heart.text.clipboard"
        }
    }

    private func iconColor(for type: String) -> Color {
        switch type {
        case RecordType.vaccination: .blue
        case RecordType.vetVisit: .purple
        case RecordType.treatment: .orange
        case RecordType.checkup: .green
        case RecordType.injury: .red
        case RecordType.illness: .yellow
        default: .secondary
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Animal.self, configurations: config)

    let animal = Animal(name: "Maple", animalType: AnimalType.horse)
    container.mainContext.insert(animal)

    let r1 = HealthRecord(
        date: Calendar.current.date(byAdding: .day, value: -7, to: .now)!,
        recordType: RecordType.vaccination,
        title: "Rabies Vaccine",
        veterinarian: "Dr. Smith",
        animal: animal
    )
    let r2 = HealthRecord(
        date: Calendar.current.date(byAdding: .day, value: -30, to: .now)!,
        recordType: RecordType.vetVisit,
        title: "Annual Checkup",
        veterinarian: "Dr. Thompson",
        animal: animal
    )
    container.mainContext.insert(r1)
    container.mainContext.insert(r2)

    return NavigationStack {
        HealthRecordListView(animal: animal)
    }
    .modelContainer(container)
}
