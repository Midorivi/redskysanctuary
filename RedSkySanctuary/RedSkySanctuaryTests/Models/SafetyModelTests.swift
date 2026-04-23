import Testing
import SwiftData
@testable import RedSkySanctuary

@Suite("Safety Model Tests")
struct SafetyModelTests {
    
    // MARK: - Helper: Create in-memory ModelContainer
    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: EmergencyContact.self, EmergencyProtocol.self, configurations: config)
    }
    
    // MARK: - EmergencyContact Tests
    
    @Test("Create EmergencyContact with default values")
    func testCreateEmergencyContactWithDefaults() throws {
        let contact = EmergencyContact()
        
        #expect(contact.id != nil)
        #expect(contact.name == "")
        #expect(contact.role == "")
        #expect(contact.phone == "")
        #expect(contact.email == nil)
        #expect(contact.notes == nil)
        #expect(contact.isPrimary == false)
    }
    
    @Test("Create EmergencyContact with custom values")
    func testCreateEmergencyContactWithCustomValues() throws {
        let contact = EmergencyContact(
            name: "Dr. Smith",
            role: "veterinarian",
            phone: "555-1234",
            email: "dr.smith@clinic.com",
            notes: "Available 24/7",
            isPrimary: true
        )
        
        #expect(contact.name == "Dr. Smith")
        #expect(contact.role == "veterinarian")
        #expect(contact.phone == "555-1234")
        #expect(contact.email == "dr.smith@clinic.com")
        #expect(contact.notes == "Available 24/7")
        #expect(contact.isPrimary == true)
    }
    
    @Test("Update EmergencyContact properties")
    func testUpdateEmergencyContact() throws {
        var contact = EmergencyContact(name: "John", role: "neighbor")
        contact.name = "John Doe"
        contact.phone = "555-9999"
        contact.isPrimary = true
        
        #expect(contact.name == "John Doe")
        #expect(contact.phone == "555-9999")
        #expect(contact.isPrimary == true)
    }
    
    @Test("EmergencyContact displayName with name")
    func testEmergencyContactDisplayNameWithName() throws {
        let contact = EmergencyContact(name: "Dr. Smith", role: "veterinarian")
        #expect(contact.displayName == "Dr. Smith")
    }
    
    @Test("EmergencyContact displayName without name")
    func testEmergencyContactDisplayNameWithoutName() throws {
        let contact = EmergencyContact()
        #expect(contact.displayName == "Unnamed Contact")
    }
    
    @Test("Filter primary EmergencyContact")
    func testFilterPrimaryContact() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let contact1 = EmergencyContact(name: "Dr. Smith", role: "veterinarian", isPrimary: true)
        let contact2 = EmergencyContact(name: "John", role: "neighbor", isPrimary: false)
        let contact3 = EmergencyContact(name: "Jane", role: "farrier", isPrimary: false)
        
        context.insert(contact1)
        context.insert(contact2)
        context.insert(contact3)
        try context.save()
        
        var fetchDescriptor = FetchDescriptor<EmergencyContact>(
            predicate: #Predicate { $0.isPrimary == true }
        )
        let primaryContacts = try context.fetch(fetchDescriptor)
        
        #expect(primaryContacts.count == 1)
        #expect(primaryContacts.first?.name == "Dr. Smith")
    }
    
    @Test("Filter EmergencyContact by role")
    func testFilterContactByRole() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let contact1 = EmergencyContact(name: "Dr. Smith", role: "veterinarian")
        let contact2 = EmergencyContact(name: "John", role: "neighbor")
        let contact3 = EmergencyContact(name: "Jane", role: "veterinarian")
        
        context.insert(contact1)
        context.insert(contact2)
        context.insert(contact3)
        try context.save()
        
        var fetchDescriptor = FetchDescriptor<EmergencyContact>(
            predicate: #Predicate { $0.role == "veterinarian" }
        )
        let vets = try context.fetch(fetchDescriptor)
        
        #expect(vets.count == 2)
        #expect(vets.allSatisfy { $0.role == "veterinarian" })
    }
    
    // MARK: - EmergencyProtocol Tests
    
    @Test("Create EmergencyProtocol with default values")
    func testCreateEmergencyProtocolWithDefaults() throws {
        let protocol_ = EmergencyProtocol()
        
        #expect(protocol_.id != nil)
        #expect(protocol_.animalType == "general")
        #expect(protocol_.situation == "")
        #expect(protocol_.steps == "")
        #expect(protocol_.notes == nil)
    }
    
    @Test("Create EmergencyProtocol with custom values")
    func testCreateEmergencyProtocolWithCustomValues() throws {
        let steps = "1. Call vet\n2. Keep calm\n3. Monitor breathing"
        let protocol_ = EmergencyProtocol(
            animalType: "horse",
            situation: "choking",
            steps: steps,
            notes: "Rare but serious"
        )
        
        #expect(protocol_.animalType == "horse")
        #expect(protocol_.situation == "choking")
        #expect(protocol_.steps == steps)
        #expect(protocol_.notes == "Rare but serious")
    }
    
    @Test("Update EmergencyProtocol properties")
    func testUpdateEmergencyProtocol() throws {
        var protocol_ = EmergencyProtocol(animalType: "horse", situation: "colic")
        protocol_.steps = "1. Call vet immediately\n2. Walk the horse"
        protocol_.notes = "Common in horses"
        
        #expect(protocol_.steps == "1. Call vet immediately\n2. Walk the horse")
        #expect(protocol_.notes == "Common in horses")
    }
    
    @Test("EmergencyProtocol displaySituation with situation")
    func testEmergencyProtocolDisplaySituationWithSituation() throws {
        let protocol_ = EmergencyProtocol(animalType: "horse", situation: "colic")
        #expect(protocol_.displaySituation == "colic")
    }
    
    @Test("EmergencyProtocol displaySituation without situation")
    func testEmergencyProtocolDisplaySituationWithoutSituation() throws {
        let protocol_ = EmergencyProtocol()
        #expect(protocol_.displaySituation == "Unknown Situation")
    }
    
    @Test("Filter EmergencyProtocol by animalType")
    func testFilterProtocolByAnimalType() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let protocol1 = EmergencyProtocol(animalType: "horse", situation: "colic")
        let protocol2 = EmergencyProtocol(animalType: "goat", situation: "injury")
        let protocol3 = EmergencyProtocol(animalType: "horse", situation: "choking")
        let protocol4 = EmergencyProtocol(animalType: "general", situation: "poisoning")
        
        context.insert(protocol1)
        context.insert(protocol2)
        context.insert(protocol3)
        context.insert(protocol4)
        try context.save()
        
        var fetchDescriptor = FetchDescriptor<EmergencyProtocol>(
            predicate: #Predicate { $0.animalType == "horse" }
        )
        let horseProtocols = try context.fetch(fetchDescriptor)
        
        #expect(horseProtocols.count == 2)
        #expect(horseProtocols.allSatisfy { $0.animalType == "horse" })
    }
    
    @Test("Filter EmergencyProtocol by situation")
    func testFilterProtocolBySituation() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let protocol1 = EmergencyProtocol(animalType: "horse", situation: "colic")
        let protocol2 = EmergencyProtocol(animalType: "goat", situation: "injury")
        let protocol3 = EmergencyProtocol(animalType: "pig", situation: "colic")
        
        context.insert(protocol1)
        context.insert(protocol2)
        context.insert(protocol3)
        try context.save()
        
        var fetchDescriptor = FetchDescriptor<EmergencyProtocol>(
            predicate: #Predicate { $0.situation == "colic" }
        )
        let colicProtocols = try context.fetch(fetchDescriptor)
        
        #expect(colicProtocols.count == 2)
        #expect(colicProtocols.allSatisfy { $0.situation == "colic" })
    }
    
    // MARK: - Constant Tests
    
    @Test("ContactRole constants are defined")
    func testContactRoleConstants() throws {
        #expect(ContactRole.veterinarian == "veterinarian")
        #expect(ContactRole.farrier == "farrier")
        #expect(ContactRole.poisonControl == "poison_control")
        #expect(ContactRole.animalControl == "animal_control")
        #expect(ContactRole.neighbor == "neighbor")
        #expect(ContactRole.other == "other")
    }
    
    @Test("EmergencySituation constants are defined")
    func testEmergencySituationConstants() throws {
        #expect(EmergencySituation.choking == "choking")
        #expect(EmergencySituation.colic == "colic")
        #expect(EmergencySituation.injury == "injury")
        #expect(EmergencySituation.poisoning == "poisoning")
        #expect(EmergencySituation.heatStress == "heat_stress")
        #expect(EmergencySituation.lameness == "lameness")
        #expect(EmergencySituation.respiratory == "respiratory")
        #expect(EmergencySituation.other == "other")
    }
    
    @Test("AnimalTypeForEmergency constants are defined")
    func testAnimalTypeForEmergencyConstants() throws {
        #expect(AnimalTypeForEmergency.horse == "horse")
        #expect(AnimalTypeForEmergency.goat == "goat")
        #expect(AnimalTypeForEmergency.pig == "pig")
        #expect(AnimalTypeForEmergency.chicken == "chicken")
        #expect(AnimalTypeForEmergency.duck == "duck")
        #expect(AnimalTypeForEmergency.general == "general")
    }
}
