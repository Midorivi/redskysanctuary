import Testing
@testable import RedSkySanctuary

@Suite("Red Sky Sanctuary Tests")
struct RedSkySanctuaryTests {
    @Test("App entry point and models are accessible")
    func coreTypesExist() {
        let animal = Animal()
        #expect(animal.name == "")
        #expect(animal.status == AnimalStatus.active)
        #expect(animal.displayName == "Unnamed Animal")
    }
}
