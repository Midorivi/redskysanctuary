import Testing
import SwiftData
@testable import RedSkySanctuary

@Suite("AnimalFormViewModel Tests")
struct AnimalFormViewModelTests {

    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Animal.self, AnimalPhoto.self,
            configurations: config
        )
    }

    @Test("canSave returns false when name is empty")
    func canSaveEmptyName() {
        let vm = AnimalFormViewModel()
        vm.name = ""
        vm.animalType = AnimalType.horse
        #expect(vm.canSave == false)
    }

    @Test("canSave returns false when name is only whitespace")
    func canSaveWhitespaceName() {
        let vm = AnimalFormViewModel()
        vm.name = "   "
        vm.animalType = AnimalType.goat
        #expect(vm.canSave == false)
    }

    @Test("canSave returns false when animalType is empty")
    func canSaveEmptyType() {
        let vm = AnimalFormViewModel()
        vm.name = "Maple"
        vm.animalType = ""
        #expect(vm.canSave == false)
    }

    @Test("canSave returns false when other type selected with empty custom field")
    func canSaveOtherTypeEmpty() {
        let vm = AnimalFormViewModel()
        vm.name = "Maple"
        vm.animalType = "other"
        vm.customAnimalType = ""
        #expect(vm.canSave == false)
    }

    @Test("canSave returns true with valid name and preset type")
    func canSaveValidData() {
        let vm = AnimalFormViewModel()
        vm.name = "Maple"
        vm.animalType = AnimalType.horse
        #expect(vm.canSave == true)
    }

    @Test("canSave returns true with valid name and custom other type")
    func canSaveValidOtherType() {
        let vm = AnimalFormViewModel()
        vm.name = "Rex"
        vm.animalType = "other"
        vm.customAnimalType = "Llama"
        #expect(vm.canSave == true)
    }

    @Test("save creates new animal in context")
    func saveCreatesAnimal() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)

        let vm = AnimalFormViewModel()
        vm.name = "Clover"
        vm.animalType = AnimalType.goat
        vm.breed = "Nigerian Dwarf"
        vm.hasBirthday = true
        vm.birthday = Date(timeIntervalSince1970: 0)
        vm.feedingInstructions = "Hay and grain"
        vm.notes = "Friendly"

        vm.save(in: context)
        try context.save()

        let animals = try context.fetch(FetchDescriptor<Animal>())
        #expect(animals.count == 1)
        #expect(animals.first?.name == "Clover")
        #expect(animals.first?.animalType == AnimalType.goat)
        #expect(animals.first?.breed == "Nigerian Dwarf")
        #expect(animals.first?.birthday != nil)
        #expect(animals.first?.feedingInstructions == "Hay and grain")
        #expect(animals.first?.notes == "Friendly")
    }

    @Test("edit mode pre-populates fields from existing animal")
    func editModePrePopulates() {
        let animal = Animal(
            name: "Rosie",
            animalType: AnimalType.pig,
            breed: "Kunekune",
            birthday: Date(timeIntervalSince1970: 1_000_000),
            status: AnimalStatus.adopted,
            feedingInstructions: "Pellets twice daily",
            notes: "Loves belly rubs"
        )

        let vm = AnimalFormViewModel(animal: animal)
        #expect(vm.isEditMode == true)
        #expect(vm.name == "Rosie")
        #expect(vm.animalType == AnimalType.pig)
        #expect(vm.breed == "Kunekune")
        #expect(vm.hasBirthday == true)
        #expect(vm.status == AnimalStatus.adopted)
        #expect(vm.feedingInstructions == "Pellets twice daily")
        #expect(vm.notes == "Loves belly rubs")
    }

    @Test("edit mode uses 'other' for non-preset animal types")
    func editModeOtherType() {
        let animal = Animal(name: "Larry", animalType: "llama")
        let vm = AnimalFormViewModel(animal: animal)

        #expect(vm.animalType == "other")
        #expect(vm.customAnimalType == "llama")
        #expect(vm.resolvedAnimalType == "llama")
    }

    @Test("save without birthday sets nil")
    func saveNoBirthday() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)

        let vm = AnimalFormViewModel()
        vm.name = "Sunny"
        vm.animalType = AnimalType.chicken
        vm.hasBirthday = false

        vm.save(in: context)
        try context.save()

        let animals = try context.fetch(FetchDescriptor<Animal>())
        #expect(animals.first?.birthday == nil)
    }

    @Test("save trims whitespace from name and breed")
    func saveTrimming() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)

        let vm = AnimalFormViewModel()
        vm.name = "  Daisy  "
        vm.animalType = AnimalType.duck
        vm.breed = "  Pekin  "

        vm.save(in: context)
        try context.save()

        let animals = try context.fetch(FetchDescriptor<Animal>())
        #expect(animals.first?.name == "Daisy")
        #expect(animals.first?.breed == "Pekin")
    }
}
