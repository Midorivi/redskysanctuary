import SwiftData
import SwiftUI

private let sharedModelContainer = CloudKitManager.makeContainer()

@main
struct RedSkySanctuaryApp: App {
    @State private var cloudKitManager: CloudKitManager

    init() {
        let manager = CloudKitManager()
        manager.configureSyncMonitoring()
        _cloudKitManager = State(initialValue: manager)
    }

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(cloudKitManager)
                .fullScreenCover(isPresented: showOnboarding) {
                    OnboardingView()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private var showOnboarding: Binding<Bool> {
        Binding(
            get: { !hasCompletedOnboarding },
            set: { newValue in hasCompletedOnboarding = !newValue }
        )
    }
}
