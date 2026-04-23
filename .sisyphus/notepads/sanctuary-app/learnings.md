# Learnings — Red Sky Sanctuary iOS App

## Conventions
- SwiftUI + SwiftData + CloudKit, iPhone only, iOS 18+, Swift 6
- TDD with Swift Testing framework (import Testing, @Test, @Suite, #expect)
- All SwiftData properties optional or defaulted (CloudKit compatibility)
- All @Relationship optional with explicit inverses
- String constants, NOT Swift enums for extensible types
- Apple system colors, NOT hardcoded hex values
- @Attribute(.externalStorage) for all image Data
- Each checklist item = individual SwiftData record (CloudKit LWW safety)
- In-memory ModelContainer for tests (no disk persistence)
- Rork Max design language: rounded fonts, spring(.snappy) animations, sensoryFeedback, hierarchical SF Symbols
- Task 1 scaffold includes a hand-authored `.xcodeproj` with explicit app/test targets, plus a shared `RedSkySanctuary.xcscheme` so Xcode and `xcodebuild -scheme RedSkySanctuary` have a persisted scheme on macOS.
- With no SwiftData models yet, the app bootstrap uses `Schema([])` + `.modelContainer(sharedModelContainer)` as a temporary zero-model container placeholder to be replaced in Wave 2.
- Linux verification here cannot run `sourcekit-lsp`, `swift`, or `xcodebuild`; structural verification was limited to file existence and project/config inspection, so first macOS pass should open the project in Xcode 16 and confirm the placeholder SwiftData container API compiles as expected.
