import Testing
import SwiftData
@testable import RedSkySanctuary

@MainActor
@Suite("HealthViewModel Tests")
struct HealthViewModelTests {

    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Animal.self, HealthRecord.self, HealthSign.self,
            configurations: config
        )
    }

    private func createAnimal(in context: ModelContext) -> Animal {
        let animal = Animal(name: "Maple", animalType: AnimalType.horse)
        context.insert(animal)
        return animal
    }

    // MARK: - Health Record Tests

    @Test("addHealthRecord inserts a record linked to the animal")
    func addHealthRecord() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let animal = createAnimal(in: context)
        let vm = HealthViewModel()

        vm.addHealthRecord(
            to: animal,
            recordType: RecordType.vaccination,
            title: "Rabies Vaccine",
            veterinarian: "Dr. Smith",
            in: context
        )
        try context.save()

        let records = try context.fetch(FetchDescriptor<HealthRecord>())
        #expect(records.count == 1)
        #expect(records.first?.title == "Rabies Vaccine")
        #expect(records.first?.recordType == RecordType.vaccination)
        #expect(records.first?.veterinarian == "Dr. Smith")
        #expect(records.first?.animal?.id == animal.id)
    }

    @Test("deleteHealthRecord removes the record from context")
    func deleteHealthRecord() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let animal = createAnimal(in: context)
        let vm = HealthViewModel()

        vm.addHealthRecord(
            to: animal,
            recordType: RecordType.checkup,
            title: "Annual Checkup",
            in: context
        )
        try context.save()

        let records = try context.fetch(FetchDescriptor<HealthRecord>())
        #expect(records.count == 1)

        vm.deleteHealthRecord(records.first!, in: context)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<HealthRecord>())
        #expect(remaining.count == 0)
    }

    // MARK: - Health Sign Tests

    @Test("addHealthSign inserts a sign linked to the animal")
    func addHealthSign() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let animal = createAnimal(in: context)
        let vm = HealthViewModel()

        vm.addHealthSign(
            to: animal,
            symptom: "Limping",
            severity: Severity.moderate,
            in: context
        )
        try context.save()

        let signs = try context.fetch(FetchDescriptor<HealthSign>())
        #expect(signs.count == 1)
        #expect(signs.first?.symptom == "Limping")
        #expect(signs.first?.severity == Severity.moderate)
        #expect(signs.first?.isResolved == false)
        #expect(signs.first?.animal?.id == animal.id)
    }

    @Test("resolveHealthSign sets isResolved and resolvedDate")
    func resolveHealthSign() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let animal = createAnimal(in: context)
        let vm = HealthViewModel()

        vm.addHealthSign(
            to: animal,
            symptom: "Coughing",
            severity: Severity.mild,
            in: context
        )
        try context.save()

        let signs = try context.fetch(FetchDescriptor<HealthSign>())
        let sign = signs.first!
        #expect(sign.isResolved == false)
        #expect(sign.resolvedDate == nil)

        vm.resolveHealthSign(sign)

        #expect(sign.isResolved == true)
        #expect(sign.resolvedDate != nil)
    }

    @Test("filteredRecords returns only matching recordType")
    func filteredRecordsByType() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let animal = createAnimal(in: context)
        let vm = HealthViewModel()

        vm.addHealthRecord(
            to: animal,
            recordType: RecordType.vaccination,
            title: "Rabies",
            in: context
        )
        vm.addHealthRecord(
            to: animal,
            recordType: RecordType.checkup,
            title: "Annual",
            in: context
        )
        vm.addHealthRecord(
            to: animal,
            recordType: RecordType.vaccination,
            title: "Tetanus",
            in: context
        )
        try context.save()

        let vaccinations = vm.filteredRecords(for: animal, by: RecordType.vaccination)
        #expect(vaccinations.count == 2)
        #expect(vaccinations.allSatisfy { $0.recordType == RecordType.vaccination })

        let all = vm.filteredRecords(for: animal, by: nil)
        #expect(all.count == 3)
    }

    @Test("deleteHealthSign removes the sign from context")
    func deleteHealthSign() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let animal = createAnimal(in: context)
        let vm = HealthViewModel()

        vm.addHealthSign(
            to: animal,
            symptom: "Swelling",
            severity: Severity.severe,
            in: context
        )
        try context.save()

        let signs = try context.fetch(FetchDescriptor<HealthSign>())
        #expect(signs.count == 1)

        vm.deleteHealthSign(signs.first!, in: context)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<HealthSign>())
        #expect(remaining.count == 0)
    }
}
