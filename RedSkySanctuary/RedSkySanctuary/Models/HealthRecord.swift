import SwiftData
import Foundation

@Model
final class HealthRecord {
    var id: UUID = UUID()
    var date: Date = .now
    var recordType: String = ""
    var title: String = ""
    var notes: String? = nil
    var veterinarian: String? = nil
    var nextVisitDate: Date? = nil
    
    var animal: Animal?
    
    init(
        date: Date = .now,
        recordType: String = "",
        title: String = "",
        notes: String? = nil,
        veterinarian: String? = nil,
        nextVisitDate: Date? = nil,
        animal: Animal? = nil
    ) {
        self.date = date
        self.recordType = recordType
        self.title = title
        self.notes = notes
        self.veterinarian = veterinarian
        self.nextVisitDate = nextVisitDate
        self.animal = animal
    }
}

struct RecordType {
    static let vaccination = "vaccination"
    static let vetVisit = "vet_visit"
    static let treatment = "treatment"
    static let checkup = "checkup"
    static let injury = "injury"
    static let illness = "illness"
}
