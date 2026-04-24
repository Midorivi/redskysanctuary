import Foundation
import Observation

struct SearchResult {
    let title: String
    let subtitle: String
    let type: String
    let iconName: String
}

struct SearchResultGroup {
    let category: String
    let results: [SearchResult]
}

@Observable
final class SearchViewModel {
    var results: [SearchResultGroup] = []
    var recentSearches: [String] = []

    private let recentSearchesKey = "SearchViewModel.recentSearches"

    init() {
        loadRecentSearches()
    }

    func search(
        query: String,
        animals: [Animal],
        records: [HealthRecord],
        inventory: [InventoryItem],
        reminders: [Reminder],
        contacts: [EmergencyContact]
    ) {
        results = []

        let animalResults = searchAnimals(query, in: animals)
        let healthResults = searchHealthRecords(query, in: records)
        let inventoryResults = searchInventory(query, in: inventory)
        let reminderResults = searchReminders(query, in: reminders)
        let contactResults = searchContacts(query, in: contacts)

        if !animalResults.isEmpty {
            results.append(SearchResultGroup(category: "Animals", results: animalResults))
        }
        if !healthResults.isEmpty {
            results.append(SearchResultGroup(category: "Health Records", results: healthResults))
        }
        if !inventoryResults.isEmpty {
            results.append(SearchResultGroup(category: "Inventory", results: inventoryResults))
        }
        if !reminderResults.isEmpty {
            results.append(SearchResultGroup(category: "Reminders", results: reminderResults))
        }
        if !contactResults.isEmpty {
            results.append(SearchResultGroup(category: "Emergency Contacts", results: contactResults))
        }
    }

    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        recentSearches.removeAll { $0 == trimmed }
        recentSearches.insert(trimmed, at: 0)

        if recentSearches.count > 5 {
            recentSearches = Array(recentSearches.prefix(5))
        }

        saveRecentSearches()
    }

    private func searchAnimals(_ query: String, in animals: [Animal]) -> [SearchResult] {
        animals.compactMap { animal in
            if animal.name.localizedCaseInsensitiveContains(query) ||
               animal.animalType.localizedCaseInsensitiveContains(query) ||
               (animal.breed?.localizedCaseInsensitiveContains(query) ?? false) {
                return SearchResult(
                    title: animal.displayName,
                    subtitle: animal.animalType.capitalized,
                    type: "animal",
                    iconName: iconForAnimalType(animal.animalType)
                )
            }
            return nil
        }
    }

    private func searchHealthRecords(_ query: String, in records: [HealthRecord]) -> [SearchResult] {
        records.compactMap { record in
            if record.title.localizedCaseInsensitiveContains(query) ||
               record.recordType.localizedCaseInsensitiveContains(query) ||
               (record.notes?.localizedCaseInsensitiveContains(query) ?? false) ||
               (record.veterinarian?.localizedCaseInsensitiveContains(query) ?? false) {
                return SearchResult(
                    title: record.title,
                    subtitle: record.recordType.capitalized,
                    type: "health",
                    iconName: "heart.fill"
                )
            }
            return nil
        }
    }

    private func searchInventory(_ query: String, in items: [InventoryItem]) -> [SearchResult] {
        items.compactMap { item in
            if item.name.localizedCaseInsensitiveContains(query) ||
               item.category.localizedCaseInsensitiveContains(query) ||
               (item.notes?.localizedCaseInsensitiveContains(query) ?? false) {
                return SearchResult(
                    title: item.name,
                    subtitle: item.category.capitalized,
                    type: "inventory",
                    iconName: "box.fill"
                )
            }
            return nil
        }
    }

    private func searchReminders(_ query: String, in reminders: [Reminder]) -> [SearchResult] {
        reminders.compactMap { reminder in
            if reminder.title.localizedCaseInsensitiveContains(query) ||
               (reminder.notes?.localizedCaseInsensitiveContains(query) ?? false) {
                return SearchResult(
                    title: reminder.title,
                    subtitle: reminder.isCompleted ? "Completed" : "Pending",
                    type: "reminder",
                    iconName: "bell.fill"
                )
            }
            return nil
        }
    }

    private func searchContacts(_ query: String, in contacts: [EmergencyContact]) -> [SearchResult] {
        contacts.compactMap { contact in
            if contact.name.localizedCaseInsensitiveContains(query) ||
               contact.role.localizedCaseInsensitiveContains(query) ||
               contact.phone.localizedCaseInsensitiveContains(query) ||
               (contact.email?.localizedCaseInsensitiveContains(query) ?? false) {
                return SearchResult(
                    title: contact.displayName,
                    subtitle: contact.role.capitalized,
                    type: "contact",
                    iconName: "phone.fill"
                )
            }
            return nil
        }
    }

    private func iconForAnimalType(_ type: String) -> String {
        switch type.lowercased() {
        case "horse": return "horse.fill"
        case "goat": return "goat.fill"
        case "pig": return "pig.fill"
        case "chicken": return "bird.fill"
        case "duck": return "bird.fill"
        default: return "pawprint.fill"
        }
    }

    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    private func loadRecentSearches() {
        if let saved = UserDefaults.standard.stringArray(forKey: recentSearchesKey) {
            recentSearches = saved
        }
    }
}
