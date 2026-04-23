import SwiftData
import Foundation

@Model
final class EmergencyProtocol {
    var id: UUID = UUID()
    var animalType: String = "general"
    var situation: String = ""
    var steps: String = ""
    var notes: String? = nil
    
    init(
        animalType: String = "general",
        situation: String = "",
        steps: String = "",
        notes: String? = nil
    ) {
        self.animalType = animalType
        self.situation = situation
        self.steps = steps
        self.notes = notes
    }
    
    var displaySituation: String {
        situation.isEmpty ? "Unknown Situation" : situation
    }
}

struct EmergencySituation {
    static let choking = "choking"
    static let colic = "colic"
    static let injury = "injury"
    static let poisoning = "poisoning"
    static let heatStress = "heat_stress"
    static let lameness = "lameness"
    static let respiratory = "respiratory"
    static let other = "other"
}

struct AnimalTypeForEmergency {
    static let horse = "horse"
    static let goat = "goat"
    static let pig = "pig"
    static let chicken = "chicken"
    static let duck = "duck"
    static let general = "general"
}
