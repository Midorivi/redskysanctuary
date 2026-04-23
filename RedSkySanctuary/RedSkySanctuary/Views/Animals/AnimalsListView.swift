import SwiftUI
import SwiftData

struct AnimalsListView: View {
    @Query(sort: \Animal.name) private var animals: [Animal]
    @State private var searchText = ""
    @State private var selectedFilter = "All"

    private let filters = ["All", "Horses", "Goats", "Pigs", "Poultry", "Other"]

    private let filterToTypes: [String: [String]] = [
        "Horses": [AnimalType.horse],
        "Goats": [AnimalType.goat],
        "Pigs": [AnimalType.pig],
        "Poultry": [AnimalType.chicken, AnimalType.duck]
    ]

    private var knownTypes: [String] {
        filterToTypes.values.flatMap { $0 }
    }

    private var filteredAnimals: [Animal] {
        animals.filter { animal in
            let matchesSearch = searchText.isEmpty ||
                animal.name.localizedCaseInsensitiveContains(searchText)

            let matchesType: Bool
            switch selectedFilter {
            case "All":
                matchesType = true
            case "Other":
                matchesType = !knownTypes.contains(animal.animalType)
            default:
                matchesType = filterToTypes[selectedFilter]?.contains(animal.animalType) ?? false
            }

            return matchesSearch && matchesType
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                filterBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                if filteredAnimals.isEmpty {
                    EmptyStateView(
                        title: "No Animals Found",
                        systemImage: "pawprint",
                        description: selectedFilter == "All" && searchText.isEmpty
                            ? "Tap + to add your first animal."
                            : "Try adjusting your search or filter."
                    )
                    .padding(.top, 40)
                } else {
                    ForEach(filteredAnimals) { animal in
                        NavigationLink {
                            AnimalDetailView(animal: animal)
                        } label: {
                            AnimalRowView(animal: animal)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)

                        if animal.id != filteredAnimals.last?.id {
                            Divider()
                                .padding(.leading, 78)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Animals")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search animals")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    AnimalFormView()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter)
                            .font(.subheadline)
                            .fontWeight(selectedFilter == filter ? .semibold : .regular)
                            .foregroundStyle(selectedFilter == filter ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter
                                    ? Color.blue
                                    : Color(.secondarySystemBackground)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.scale)
                }
            }
        }
        .animation(.spring(.snappy), value: selectedFilter)
        .sensoryFeedback(.selection, trigger: selectedFilter)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Animal.self, configurations: config)

    let animals = [
        Animal(name: "Maple", animalType: "horse", breed: "Quarter Horse",
               birthday: Calendar.current.date(byAdding: .year, value: -5, to: .now)),
        Animal(name: "Clover", animalType: "goat", breed: "Nigerian Dwarf",
               birthday: Calendar.current.date(byAdding: .year, value: -3, to: .now)),
        Animal(name: "Rosie", animalType: "pig", breed: "Kunekune",
               birthday: Calendar.current.date(byAdding: .year, value: -2, to: .now)),
        Animal(name: "Sunny", animalType: "chicken"),
        Animal(name: "Daisy", animalType: "duck")
    ]

    for animal in animals {
        container.mainContext.insert(animal)
    }

    return NavigationStack {
        AnimalsListView()
    }
    .modelContainer(container)
}
