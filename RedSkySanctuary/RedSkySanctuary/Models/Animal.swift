import SwiftData
import Foundation

@Model
final class Animal {
    var id: UUID = UUID()
    var name: String = ""
    var animalType: String = ""
    var breed: String? = nil
    var birthday: Date? = nil
    var dateAdded: Date = .now
    var status: String = "active"
    var dateOfPassing: Date? = nil
    var feedingInstructions: String? = nil
    var notes: String? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \AnimalPhoto.animal)
    var photos: [AnimalPhoto]? = []
    
    @Relationship(inverse: \HealthRecord.animal)
    var healthRecords: [HealthRecord]? = []
    
    @Relationship(inverse: \HealthSign.animal)
    var healthSigns: [HealthSign]? = []
    
    @Relationship(inverse: \Reminder.relatedAnimal)
    var reminders: [Reminder]? = []
    
    init(
        name: String = "",
        animalType: String = "",
        breed: String? = nil,
        birthday: Date? = nil,
        status: String = "active",
        feedingInstructions: String? = nil,
        notes: String? = nil
    ) {
        self.name = name
        self.animalType = animalType
        self.breed = breed
        self.birthday = birthday
        self.status = status
        self.feedingInstructions = feedingInstructions
        self.notes = notes
    }
    
    var age: Int? {
        guard let birthday = birthday else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: birthday, to: .now)
        return components.year
    }
    
    var displayName: String {
        name.isEmpty ? "Unnamed Animal" : name
    }
}

struct AnimalType {
    static let horse = "horse"
    static let goat = "goat"
    static let pig = "pig"
    static let chicken = "chicken"
    static let duck = "duck"
}

struct AnimalStatus {
    static let active = "active"
    static let deceased = "deceased"
    static let adopted = "adopted"
    static let transferred = "transferred"
}
