import SwiftData
import Foundation

@Model
final class HealthSign {
    var id: UUID = UUID()
    var date: Date = .now
    var symptom: String = ""
    var severity: String = "mild"
    var notes: String? = nil
    var isResolved: Bool = false
    var resolvedDate: Date? = nil
    
    var animal: Animal?
    
    init(
        date: Date = .now,
        symptom: String = "",
        severity: String = "mild",
        notes: String? = nil,
        isResolved: Bool = false,
        resolvedDate: Date? = nil,
        animal: Animal? = nil
    ) {
        self.date = date
        self.symptom = symptom
        self.severity = severity
        self.notes = notes
        self.isResolved = isResolved
        self.resolvedDate = resolvedDate
        self.animal = animal
    }
}

struct Severity {
    static let mild = "mild"
    static let moderate = "moderate"
    static let severe = "severe"
}
