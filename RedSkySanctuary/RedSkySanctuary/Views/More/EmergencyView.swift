import SwiftUI
import SwiftData

struct EmergencyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    @Query(sort: \EmergencyContact.name) private var contacts: [EmergencyContact]
    @Query(sort: [
        SortDescriptor(\EmergencyProtocol.animalType),
        SortDescriptor(\EmergencyProtocol.situation)
    ]) private var protocols: [EmergencyProtocol]

    @State private var showAddContact = false
    @State private var showAddProtocol = false
    @State private var deleteCount = 0

    private var sortedContacts: [EmergencyContact] {
        contacts.sorted { c1, c2 in
            if c1.isPrimary != c2.isPrimary { return c1.isPrimary }
            return c1.name.localizedCompare(c2.name) == .orderedAscending
        }
    }

    private var activeGroups: [ProtocolGroup] {
        Self.allGroups.filter { group in
            protocols.contains { $0.animalType == group.id }
        }
    }

    private static let allGroups: [ProtocolGroup] = [
        ProtocolGroup(id: AnimalTypeForEmergency.horse, label: "Horses", icon: "hare"),
        ProtocolGroup(id: AnimalTypeForEmergency.goat, label: "Goats", icon: "pawprint"),
        ProtocolGroup(id: AnimalTypeForEmergency.pig, label: "Pigs", icon: "pawprint.fill"),
        ProtocolGroup(id: AnimalTypeForEmergency.chicken, label: "Chickens", icon: "bird"),
        ProtocolGroup(id: AnimalTypeForEmergency.duck, label: "Ducks", icon: "bird.fill"),
        ProtocolGroup(id: AnimalTypeForEmergency.general, label: "General", icon: "cross.case"),
    ]

    var body: some View {
        List {
            contactsSection

            if protocols.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Emergency Protocols",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Add protocols for emergency procedures")
                    )
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Emergency Protocols")
                }
            } else {
                ForEach(activeGroups) { group in
                    protocolSection(for: group)
                }
            }
        }
        .navigationTitle("Emergency")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showAddContact = true
                    } label: {
                        Label("Add Contact", systemImage: "person.badge.plus")
                    }

                    Button {
                        showAddProtocol = true
                    } label: {
                        Label("Add Protocol", systemImage: "list.bullet.clipboard")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddContact) {
            EmergencyContactFormView()
        }
        .sheet(isPresented: $showAddProtocol) {
            EmergencyProtocolFormView()
        }
        .sensoryFeedback(.success, trigger: deleteCount)
    }

    // MARK: - Contacts Section

    @ViewBuilder
    private var contactsSection: some View {
        Section {
            if sortedContacts.isEmpty {
                ContentUnavailableView(
                    "No Emergency Contacts",
                    systemImage: "person.crop.circle.badge.exclamationmark",
                    description: Text("Add contacts for quick access during emergencies")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(sortedContacts) { contact in
                    contactRow(contact)
                }
                .onDelete(perform: deleteContacts)
            }
        } header: {
            Label("Emergency Contacts", systemImage: "phone.fill")
        }
    }

    private func contactRow(_ contact: EmergencyContact) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(contact.displayName)
                        .font(.headline)

                    if contact.isPrimary {
                        Text("PRIMARY")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.red)
                            .clipShape(Capsule())
                    }
                }

                Text(displayRole(contact.role))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())

                Text(contact.phone)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                callContact(contact)
            } label: {
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.green)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .listRowBackground(contact.isPrimary ? Color.red.opacity(0.08) : nil)
    }

    private func callContact(_ contact: EmergencyContact) {
        let cleaned = contact.phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        guard let url = URL(string: "tel://\(cleaned)") else { return }
        openURL(url)
    }

    // MARK: - Protocols Sections

    private func protocolSection(for group: ProtocolGroup) -> some View {
        let filtered = protocols.filter { $0.animalType == group.id }
        return Section {
            ForEach(filtered) { proto in
                protocolRow(proto)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(filtered[index])
                }
                deleteCount += 1
            }
        } header: {
            Label(group.label, systemImage: group.icon)
        }
    }

    private func protocolRow(_ proto: EmergencyProtocol) -> some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 8) {
                Text(proto.steps)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let notes = proto.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(.rect(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(.vertical, 4)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: situationIcon(for: proto.situation))
                    .foregroundStyle(situationColor(for: proto.situation))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 24)

                Text(formatSituation(proto.displaySituation))
                    .font(.body)
            }
        }
    }

    // MARK: - Delete

    private func deleteContacts(_ indexSet: IndexSet) {
        for index in indexSet {
            modelContext.delete(sortedContacts[index])
        }
        deleteCount += 1
    }

    // MARK: - Display Helpers

    private func displayRole(_ role: String) -> String {
        switch role {
        case ContactRole.veterinarian: "Veterinarian"
        case ContactRole.farrier: "Farrier"
        case ContactRole.poisonControl: "Poison Control"
        case ContactRole.animalControl: "Animal Control"
        case ContactRole.neighbor: "Neighbor"
        case ContactRole.other: "Other"
        default: role.capitalized
        }
    }

    private func formatSituation(_ situation: String) -> String {
        situation.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private func situationIcon(for situation: String) -> String {
        switch situation {
        case EmergencySituation.choking: "exclamationmark.triangle.fill"
        case EmergencySituation.colic: "waveform.path.ecg"
        case EmergencySituation.injury: "bandage"
        case EmergencySituation.poisoning: "exclamationmark.octagon.fill"
        case EmergencySituation.heatStress: "thermometer.sun.fill"
        case EmergencySituation.lameness: "figure.walk"
        case EmergencySituation.respiratory: "lungs.fill"
        default: "questionmark.circle"
        }
    }

    private func situationColor(for situation: String) -> Color {
        switch situation {
        case EmergencySituation.choking: .red
        case EmergencySituation.colic: .orange
        case EmergencySituation.injury: .red
        case EmergencySituation.poisoning: .purple
        case EmergencySituation.heatStress: .orange
        case EmergencySituation.lameness: .yellow
        case EmergencySituation.respiratory: .blue
        default: .secondary
        }
    }
}

// MARK: - Protocol Group

private struct ProtocolGroup: Identifiable {
    let id: String
    let label: String
    let icon: String
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: EmergencyContact.self, EmergencyProtocol.self,
        configurations: config
    )

    let context = container.mainContext

    context.insert(EmergencyContact(
        name: "Dr. Sarah Miller",
        role: ContactRole.veterinarian,
        phone: "(555) 234-5678",
        isPrimary: true
    ))
    context.insert(EmergencyContact(
        name: "County Animal Control",
        role: ContactRole.animalControl,
        phone: "(555) 911-0000"
    ))
    context.insert(EmergencyContact(
        name: "Mike Thompson",
        role: ContactRole.neighbor,
        phone: "(555) 876-5432"
    ))

    context.insert(EmergencyProtocol(
        animalType: AnimalTypeForEmergency.horse,
        situation: EmergencySituation.colic,
        steps: "1. Remove all feed and water\n2. Walk the horse slowly for 15 minutes\n3. Check for gut sounds on both sides\n4. Call veterinarian immediately\n5. Monitor vital signs every 10 minutes"
    ))
    context.insert(EmergencyProtocol(
        animalType: AnimalTypeForEmergency.horse,
        situation: EmergencySituation.injury,
        steps: "1. Assess the wound severity\n2. Apply pressure to stop bleeding\n3. Clean with saline solution\n4. Call veterinarian"
    ))
    context.insert(EmergencyProtocol(
        animalType: AnimalTypeForEmergency.general,
        situation: EmergencySituation.heatStress,
        steps: "1. Move animal to shade immediately\n2. Provide cool (not cold) water\n3. Wet the animal down gently\n4. Call veterinarian if symptoms persist",
        notes: "Most common in summer months. Watch for heavy panting and disorientation."
    ))

    return NavigationStack {
        EmergencyView()
    }
    .modelContainer(container)
}
