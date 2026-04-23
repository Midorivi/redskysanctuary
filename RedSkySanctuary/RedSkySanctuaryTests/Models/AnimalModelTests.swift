import Testing
import SwiftData
@testable import RedSkySanctuary

@Suite("Animal Model Tests")
struct AnimalModelTests {
    
    // MARK: - Helper: Create in-memory ModelContainer
    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Animal.self, AnimalPhoto.self, configurations: config)
    }
    
    // MARK: - Test: Create animal with defaults
    @Test("Create animal with default values")
    func testCreateAnimalWithDefaults() throws {
        let animal = Animal()
        
        #expect(animal.id != nil)
        #expect(animal.name == "")
        #expect(animal.animalType == "")
        #expect(animal.breed == nil)
        #expect(animal.birthday == nil)
        #expect(animal.dateAdded != nil)
        #expect(animal.status == "active")
        #expect(animal.dateOfPassing == nil)
        #expect(animal.feedingInstructions == nil)
        #expect(animal.notes == nil)
        #expect(animal.photos == nil || animal.photos?.isEmpty ?? true)
    }
    
    // MARK: - Test: Create animal with custom values
    @Test("Create animal with custom values")
    func testCreateAnimalWithCustomValues() throws {
        let birthday = Date(timeIntervalSince1970: 0)
        let animal = Animal(
            name: "Bessie",
            animalType: "horse",
            breed: "Thoroughbred",
            birthday: birthday,
            status: "active",
            feedingInstructions: "Hay twice daily",
            notes: "Friendly and calm"
        )
        
        #expect(animal.name == "Bessie")
        #expect(animal.animalType == "horse")
        #expect(animal.breed == "Thoroughbred")
        #expect(animal.birthday == birthday)
        #expect(animal.status == "active")
        #expect(animal.feedingInstructions == "Hay twice daily")
        #expect(animal.notes == "Friendly and calm")
    }
    
    // MARK: - Test: Update animal name and type
    @Test("Update animal name and type")
    func testUpdateAnimalNameAndType() throws {
        var animal = Animal()
        animal.name = "Daisy"
        animal.animalType = "goat"
        
        #expect(animal.name == "Daisy")
        #expect(animal.animalType == "goat")
    }
    
    // MARK: - Test: Animal status transition
    @Test("Animal status transition from active to deceased")
    func testAnimalStatusTransition() throws {
        var animal = Animal(name: "Old Friend", animalType: "horse", status: "active")
        #expect(animal.status == "active")
        #expect(animal.dateOfPassing == nil)
        
        animal.status = "deceased"
        animal.dateOfPassing = .now
        
        #expect(animal.status == "deceased")
        #expect(animal.dateOfPassing != nil)
    }
    
    // MARK: - Test: Age computed property
    @Test("Age computed property calculates years from birthday")
    func testAgeComputedProperty() throws {
        let calendar = Calendar.current
        let today = Date()
        
        // Create a birthday 5 years ago
        let fiveYearsAgo = calendar.date(byAdding: .year, value: -5, to: today)!
        let animal = Animal(name: "Youngster", animalType: "pig", birthday: fiveYearsAgo)
        
        #expect(animal.age == 5)
    }
    
    // MARK: - Test: Age computed property with no birthday
    @Test("Age computed property returns nil when no birthday")
    func testAgeComputedPropertyNoBirthday() throws {
        let animal = Animal(name: "Unknown", animalType: "chicken")
        #expect(animal.age == nil)
    }
    
    // MARK: - Test: Display name computed property
    @Test("Display name returns name when set")
    func testDisplayNameWithName() throws {
        let animal = Animal(name: "Clucky", animalType: "chicken")
        #expect(animal.displayName == "Clucky")
    }
    
    // MARK: - Test: Display name computed property with empty name
    @Test("Display name returns 'Unnamed Animal' when name is empty")
    func testDisplayNameWithoutName() throws {
        let animal = Animal()
        #expect(animal.displayName == "Unnamed Animal")
    }
    
    // MARK: - Test: Create AnimalPhoto and link to animal
    @Test("Create AnimalPhoto and link to animal")
    func testCreateAnimalPhotoAndLink() throws {
        let animal = Animal(name: "Bella", animalType: "duck")
        let photo = AnimalPhoto(animal: animal, caption: "Bella swimming", isPrimary: true)
        
        #expect(photo.id != nil)
        #expect(photo.animal?.name == "Bella")
        #expect(photo.caption == "Bella swimming")
        #expect(photo.isPrimary == true)
        #expect(photo.dateAdded != nil)
    }
    
    // MARK: - Test: AnimalPhoto with external storage
    @Test("AnimalPhoto stores image data with external storage")
    func testAnimalPhotoExternalStorage() throws {
        let imageData = "fake image data".data(using: .utf8)!
        let thumbnailData = "fake thumbnail".data(using: .utf8)!
        
        let photo = AnimalPhoto(
            imageData: imageData,
            thumbnailData: thumbnailData,
            caption: "Test photo"
        )
        
        #expect(photo.imageData == imageData)
        #expect(photo.thumbnailData == thumbnailData)
        #expect(photo.caption == "Test photo")
    }
    
    // MARK: - Test: Cascade delete (deleting animal deletes photos)
    @Test("Cascade delete: deleting animal deletes photos")
    func testCascadeDeletePhotos() throws {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let animal = Animal(name: "Temporary", animalType: "horse")
        let photo1 = AnimalPhoto(animal: animal, caption: "Photo 1")
        let photo2 = AnimalPhoto(animal: animal, caption: "Photo 2")
        
        animal.photos = [photo1, photo2]
        
        context.insert(animal)
        try context.save()
        
        // Verify photos exist
        var fetchDescriptor = FetchDescriptor<AnimalPhoto>()
        var photos = try context.fetch(fetchDescriptor)
        #expect(photos.count == 2)
        
        // Delete animal
        context.delete(animal)
        try context.save()
        
        // Verify photos are deleted (cascade)
        fetchDescriptor = FetchDescriptor<AnimalPhoto>()
        photos = try context.fetch(fetchDescriptor)
        #expect(photos.count == 0)
    }
    
    // MARK: - Test: Animal type constants
    @Test("Animal type constants are defined")
    func testAnimalTypeConstants() throws {
        #expect(AnimalType.horse == "horse")
        #expect(AnimalType.goat == "goat")
        #expect(AnimalType.pig == "pig")
        #expect(AnimalType.chicken == "chicken")
        #expect(AnimalType.duck == "duck")
    }
    
    // MARK: - Test: Animal status constants
    @Test("Animal status constants are defined")
    func testAnimalStatusConstants() throws {
        #expect(AnimalStatus.active == "active")
        #expect(AnimalStatus.deceased == "deceased")
        #expect(AnimalStatus.adopted == "adopted")
        #expect(AnimalStatus.transferred == "transferred")
    }
}
