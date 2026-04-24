import Foundation
import SwiftData
import Testing

@testable import RedSkySanctuary

@Suite("SearchViewModel Tests")
struct SearchViewModelTests {

    private let viewModel = SearchViewModel()

    // MARK: - Multi-model search

    @Test("search returns results grouped by type")
    func searchReturnsGroupedResults() {
        let animal = Animal(name: "Bella", animalType: "horse")
        let record = HealthRecord(title: "Vaccination", recordType: "vaccination")
        let inventory = InventoryItem(name: "Horse Feed", category: "feed")
        let reminder = Reminder(title: "Farrier appointment")
        let contact = EmergencyContact(name: "Dr. Smith", role: "veterinarian")

        viewModel.search(
            query: "appointment",
            animals: [animal],
            records: [record],
            inventory: [inventory],
            reminders: [reminder],
            contacts: [contact]
        )

        #expect(viewModel.results.count == 1)
        #expect(viewModel.results[0].category == "Reminders")
        #expect(viewModel.results[0].results.count == 1)
        #expect(viewModel.results[0].results[0].title == "Farrier appointment")
    }

    @Test("search is case-insensitive")
    func searchIsCaseInsensitive() {
        let animal = Animal(name: "Bella", animalType: "horse")
        let inventory = InventoryItem(name: "Horse Feed", category: "feed")

        viewModel.search(
            query: "HORSE",
            animals: [animal],
            records: [],
            inventory: [inventory],
            reminders: [],
            contacts: []
        )

        #expect(viewModel.results.count == 2)
        let animalGroup = viewModel.results.first { $0.category == "Animals" }
        let inventoryGroup = viewModel.results.first { $0.category == "Inventory" }
        #expect(animalGroup?.results.count == 1)
        #expect(inventoryGroup?.results.count == 1)
    }

    @Test("search returns empty results for no matches")
    func searchEmptyQuery() {
        let animal = Animal(name: "Bella", animalType: "horse")

        viewModel.search(
            query: "xyz123notfound",
            animals: [animal],
            records: [],
            inventory: [],
            reminders: [],
            contacts: []
        )

        #expect(viewModel.results.isEmpty)
    }

    @Test("search matches across multiple fields")
    func searchMatchesMultipleFields() {
        let animal1 = Animal(name: "Bella", animalType: "horse")
        let animal2 = Animal(name: "Daisy", animalType: "goat", breed: "Bella breed")

        viewModel.search(
            query: "bella",
            animals: [animal1, animal2],
            records: [],
            inventory: [],
            reminders: [],
            contacts: []
        )

        let animalGroup = viewModel.results.first { $0.category == "Animals" }
        #expect(animalGroup?.results.count == 2)
    }

    // MARK: - Recent searches

    @Test("addRecentSearch stores query in recent searches")
    func addRecentSearchStoresQuery() {
        viewModel.addRecentSearch("Bella")
        viewModel.addRecentSearch("Vaccination")

        #expect(viewModel.recentSearches.count == 2)
        #expect(viewModel.recentSearches[0] == "Vaccination")
        #expect(viewModel.recentSearches[1] == "Bella")
    }

    @Test("addRecentSearch keeps only last 5 searches")
    func addRecentSearchLimitsFiveItems() {
        for i in 1...6 {
            viewModel.addRecentSearch("Search \(i)")
        }

        #expect(viewModel.recentSearches.count == 5)
        #expect(viewModel.recentSearches[0] == "Search 6")
        #expect(viewModel.recentSearches[4] == "Search 2")
    }

    @Test("addRecentSearch deduplicates and moves to front")
    func addRecentSearchDeduplicates() {
        viewModel.addRecentSearch("Bella")
        viewModel.addRecentSearch("Daisy")
        viewModel.addRecentSearch("Bella")

        #expect(viewModel.recentSearches.count == 2)
        #expect(viewModel.recentSearches[0] == "Bella")
        #expect(viewModel.recentSearches[1] == "Daisy")
    }
}
