import Testing

@Suite("Red Sky Sanctuary Tests")
struct RedSkySanctuaryTests {
    @Test("Project scaffolding is available")
    func projectScaffoldingExists() {
        #expect(true)
    }
}
