import SwiftData
import SwiftUI

private let sharedModelContainer: ModelContainer = {
    let schema = Schema([])

    do {
        return try ModelContainer(for: schema, configurations: [ModelConfiguration()])
    } catch {
        fatalError("Failed to initialize ModelContainer: \(error)")
    }
}()

@main
struct RedSkySanctuaryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
