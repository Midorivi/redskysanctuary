import SwiftData
import Foundation

@Model
final class EmergencyContact {
    var id: UUID = UUID()
    var name: String = ""
    var role: String = ""
    var phone: String = ""
    var email: String? = nil
    var notes: String? = nil
    var isPrimary: Bool = false
    
    init(
        name: String = "",
        role: String = "",
        phone: String = "",
        email: String? = nil,
        notes: String? = nil,
        isPrimary: Bool = false
    ) {
        self.name = name
        self.role = role
        self.phone = phone
        self.email = email
        self.notes = notes
        self.isPrimary = isPrimary
    }
    
    var displayName: String {
        name.isEmpty ? "Unnamed Contact" : name
    }
}

struct ContactRole {
    static let veterinarian = "veterinarian"
    static let farrier = "farrier"
    static let poisonControl = "poison_control"
    static let animalControl = "animal_control"
    static let neighbor = "neighbor"
    static let other = "other"
}
