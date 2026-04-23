import Testing
import SwiftData
@testable import RedSkySanctuary

@Suite("Health Model Tests")
struct HealthModelTests {
    
    // MARK: - Helper: Create in-memory ModelContainer
    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Animal.self, AnimalPhoto.self, HealthRecord.self, HealthSign.self,
            configurations: config
        )
    }
    
    // MARK: - HealthRecord Tests
    
    @Test("Create HealthRecord with default values")
    func testCreateHealthRecordWithDefaults() throws {
        let record = HealthRecord()
        
        #expect(record.id != nil)
        #expect(record.date != nil)
        #expect(record.recordType == "")
        #expect(record.title == "")
        #expect(record.notes == nil)
        #expect(record.veterinarian == nil)
        #expect(record.nextVisitDate == nil)
        #expect(record.animal == nil)
    }
    
    @Test("Create HealthRecord with custom values")
    func testCreateHealthRecordWithCustomValues() throws {
        let animal = Animal(name: "Bessie", animalType: "horse")
        let visitDate = Date()
        let nextVisit = Calendar.current.date(byAdding: .month, value: 1, to: visitDate)!
        
        let record = HealthRecord(
            date: visitDate,
            recordType: "vet_visit",
            title: "Annual Checkup",
            notes: "All vitals normal",
            veterinarian: "Dr. Smith",
            nextVisitDate: nextVisit,
            animal: animal
        )
        
        #expect(record.date == visitDate)
        #expect(record.recordType == "vet_visit")
        #expect(record.title == "Annual Checkup")
        #expect(record.notes == "All vitals normal")
        #expect(record.veterinarian == "Dr. Smith")
        #expect(record.nextVisitDate == nextVisit)
        #expect(record.animal?.name == "Bessie")
    }
    
    @Test("Update HealthRecord properties")
    func testUpdateHealthRecord() throws {
        var record = HealthRecord(recordType: "vaccination", title: "Rabies Shot")
        
        record.title = "Updated Title"
        record.veterinarian = "Dr. Jones"
        
        #expect(record.title == "Updated Title")
        #expect(record.veterinarian == "Dr. Jones")
        #expect(record.recordType == "vaccination")
    }
    
    @Test("Filter HealthRecords by type")
    func testFilterHealthRecordsByType() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let animal = Animal(name: "Daisy", animalType: "goat")
        let vaccinationRecord = HealthRecord(
            recordType: "vaccination",
            title: "Vaccination 1",
            animal: animal
        )
        let vetVisitRecord = HealthRecord(
            recordType: "vet_visit",
            title: "Vet Visit 1",
            animal: animal
        )
        let treatmentRecord = HealthRecord(
            recordType: "treatment",
            title: "Treatment 1",
            animal: animal
        )
        
        context.insert(animal)
        context.insert(vaccinationRecord)
        context.insert(vetVisitRecord)
        context.insert(treatmentRecord)
        try context.save()
        
        // Fetch all records
        var fetchDescriptor = FetchDescriptor<HealthRecord>()
        var allRecords = try context.fetch(fetchDescriptor)
        #expect(allRecords.count == 3)
        
        // Fetch only vaccination records
        var predicate = #Predicate<HealthRecord> { $0.recordType == "vaccination" }
        fetchDescriptor = FetchDescriptor<HealthRecord>(predicate: predicate)
        var vaccinationRecords = try context.fetch(fetchDescriptor)
        #expect(vaccinationRecords.count == 1)
        #expect(vaccinationRecords.first?.title == "Vaccination 1")
    }
    
    // MARK: - HealthSign Tests
    
    @Test("Create HealthSign with default values")
    func testCreateHealthSignWithDefaults() throws {
        let sign = HealthSign()
        
        #expect(sign.id != nil)
        #expect(sign.date != nil)
        #expect(sign.symptom == "")
        #expect(sign.severity == "mild")
        #expect(sign.notes == nil)
        #expect(sign.isResolved == false)
        #expect(sign.resolvedDate == nil)
        #expect(sign.animal == nil)
    }
    
    @Test("Create HealthSign with custom values")
    func testCreateHealthSignWithCustomValues() throws {
        let animal = Animal(name: "Clucky", animalType: "chicken")
        let signDate = Date()
        
        let sign = HealthSign(
            date: signDate,
            symptom: "Limping",
            severity: "moderate",
            notes: "Left leg swollen",
            isResolved: false,
            animal: animal
        )
        
        #expect(sign.date == signDate)
        #expect(sign.symptom == "Limping")
        #expect(sign.severity == "moderate")
        #expect(sign.notes == "Left leg swollen")
        #expect(sign.isResolved == false)
        #expect(sign.animal?.name == "Clucky")
    }
    
    @Test("Resolve a HealthSign")
    func testResolveHealthSign() throws {
        var sign = HealthSign(
            symptom: "Coughing",
            severity: "mild",
            isResolved: false
        )
        
        #expect(sign.isResolved == false)
        #expect(sign.resolvedDate == nil)
        
        sign.isResolved = true
        sign.resolvedDate = .now
        
        #expect(sign.isResolved == true)
        #expect(sign.resolvedDate != nil)
    }
    
    @Test("Filter HealthSigns by severity")
    func testFilterHealthSignsBySeverity() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let animal = Animal(name: "Bella", animalType: "duck")
        let mildSign = HealthSign(symptom: "Mild symptom", severity: "mild", animal: animal)
        let moderateSign = HealthSign(symptom: "Moderate symptom", severity: "moderate", animal: animal)
        let severeSign = HealthSign(symptom: "Severe symptom", severity: "severe", animal: animal)
        
        context.insert(animal)
        context.insert(mildSign)
        context.insert(moderateSign)
        context.insert(severeSign)
        try context.save()
        
        // Fetch all signs
        var fetchDescriptor = FetchDescriptor<HealthSign>()
        var allSigns = try context.fetch(fetchDescriptor)
        #expect(allSigns.count == 3)
        
        // Fetch only severe signs
        var predicate = #Predicate<HealthSign> { $0.severity == "severe" }
        fetchDescriptor = FetchDescriptor<HealthSign>(predicate: predicate)
        var severeSigns = try context.fetch(fetchDescriptor)
        #expect(severeSigns.count == 1)
        #expect(severeSigns.first?.symptom == "Severe symptom")
    }
    
    @Test("Filter unresolved HealthSigns")
    func testFilterUnresolvedHealthSigns() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let animal = Animal(name: "Spot", animalType: "pig")
        let unresolvedSign = HealthSign(symptom: "Unresolved", isResolved: false, animal: animal)
        let resolvedSign = HealthSign(
            symptom: "Resolved",
            isResolved: true,
            resolvedDate: .now,
            animal: animal
        )
        
        context.insert(animal)
        context.insert(unresolvedSign)
        context.insert(resolvedSign)
        try context.save()
        
        // Fetch only unresolved signs
        let predicate = #Predicate<HealthSign> { $0.isResolved == false }
        let fetchDescriptor = FetchDescriptor<HealthSign>(predicate: predicate)
        let unresolvedSigns = try context.fetch(fetchDescriptor)
        
        #expect(unresolvedSigns.count == 1)
        #expect(unresolvedSigns.first?.symptom == "Unresolved")
    }
    
    // MARK: - Relationship Tests
    
    @Test("HealthRecord linked to Animal")
    func testHealthRecordLinkedToAnimal() throws {
        let animal = Animal(name: "Bessie", animalType: "horse")
        let record = HealthRecord(
            recordType: "vaccination",
            title: "Tetanus Shot",
            animal: animal
        )
        
        #expect(record.animal?.name == "Bessie")
        #expect(record.animal?.animalType == "horse")
    }
    
    @Test("HealthSign linked to Animal")
    func testHealthSignLinkedToAnimal() throws {
        let animal = Animal(name: "Daisy", animalType: "goat")
        let sign = HealthSign(
            symptom: "Sneezing",
            severity: "mild",
            animal: animal
        )
        
        #expect(sign.animal?.name == "Daisy")
        #expect(sign.animal?.animalType == "goat")
    }
    
    // MARK: - Constants Tests
    
    @Test("RecordType constants are defined")
    func testRecordTypeConstants() throws {
        #expect(RecordType.vaccination == "vaccination")
        #expect(RecordType.vetVisit == "vet_visit")
        #expect(RecordType.treatment == "treatment")
        #expect(RecordType.checkup == "checkup")
        #expect(RecordType.injury == "injury")
        #expect(RecordType.illness == "illness")
    }
    
    @Test("Severity constants are defined")
    func testSeverityConstants() throws {
        #expect(Severity.mild == "mild")
        #expect(Severity.moderate == "moderate")
        #expect(Severity.severe == "severe")
    }
}
