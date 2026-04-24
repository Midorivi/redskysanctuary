import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var animals: [Animal]
    @Query private var healthRecords: [HealthRecord]
    @Query private var inventoryItems: [InventoryItem]
    @Query private var reminders: [Reminder]
    @Query private var emergencyContacts: [EmergencyContact]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                if searchText.isEmpty && viewModel.recentSearches.isEmpty {
                    emptyStateView
                } else if searchText.isEmpty {
                    recentSearchesView
                } else if viewModel.results.isEmpty {
                    noResultsView
                } else {
                    resultsView
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Animals, supplies, symptoms...")
            .onChange(of: searchText) { oldValue, newValue in
                performSearch(newValue)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Search Sanctuary Data")
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundStyle(.primary)

                Text("Try searching for an animal name, supply item, or symptom")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var recentSearchesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Searches")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                VStack(spacing: 8) {
                    ForEach(viewModel.recentSearches, id: \.self) { search in
                        Button(action: { searchText = search }) {
                            HStack(spacing: 12) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)

                                Text(search)
                                    .font(.body)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(systemName: "arrow.up.left")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(.rect(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var resultsView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(viewModel.results, id: \.category) { group in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(group.category)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 16)

                        VStack(spacing: 8) {
                            ForEach(group.results, id: \.title) { result in
                                resultRow(result)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }

    private func resultRow(_ result: SearchResult) -> some View {
        HStack(spacing: 12) {
            Image(systemName: result.iconName)
                .font(.title3)
                .foregroundStyle(.blue)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Text(result.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.addRecentSearch(searchText)
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("No Results")
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundStyle(.primary)

                Text("Try a different search term")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func performSearch(_ query: String) {
        viewModel.search(
            query: query,
            animals: animals,
            records: healthRecords,
            inventory: inventoryItems,
            reminders: reminders,
            contacts: emergencyContacts
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Animal.self, HealthRecord.self, InventoryItem.self, Reminder.self, EmergencyContact.self, configurations: config)

    let animal = Animal(name: "Bella", animalType: "horse", breed: "Thoroughbred")
    let record = HealthRecord(recordType: "vaccination", title: "Vaccination", notes: "Annual checkup")
    let inventory = InventoryItem(name: "Horse Feed", category: "feed", quantity: 50)
    let reminder = Reminder(title: "Farrier appointment", notes: "Schedule next visit")
    let contact = EmergencyContact(name: "Dr. Smith", role: "veterinarian", phone: "555-0123")

    container.mainContext.insert(animal)
    container.mainContext.insert(record)
    container.mainContext.insert(inventory)
    container.mainContext.insert(reminder)
    container.mainContext.insert(contact)

    NavigationStack {
        SearchView()
    }
    .modelContainer(container)
}
