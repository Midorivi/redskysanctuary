# Red Sky Sanctuary — iOS Farm Management App

## TL;DR

> **Quick Summary**: Build a full-featured iOS farm sanctuary management app in SwiftUI for Red Sky Sanctuary. Covers animal profiles, health records, daily task checklists, inventory, expenses, reminders, emergency protocols — all synced between two users via CloudKit.
> 
> **Deliverables**:
> - Complete SwiftUI iPhone app with 5-tab navigation
> - SwiftData persistence with CloudKit sync
> - TDD test suite (Swift Testing framework)
> - 12 feature areas: Animals, Health, Tasks, Maintenance, Reminders, Inventory, Expenses, Emergency, Dashboard, Search, Notifications, Settings
> 
> **Estimated Effort**: XL
> **Parallel Execution**: YES — 6 waves
> **Critical Path**: Task 1 → Tasks 2-9 → Tasks 10-15 → Tasks 16-20 → Tasks 21-24 → F1-F4

---

## Context

### Original Request
Build an iOS mobile app for Red Sky Sanctuary — an animal sanctuary named after the owner's first horses (Red and Sky), inspired by Medwyn's Valley from the Prydain Chronicles. Full farm management: animals, health records, vaccinations, feeding, inventory, maintenance, daily tasks, reminders, emergency protocols. Multi-tenant so both owner and fiancée can use it.

### Interview Summary
**Key Discussions**:
- **Sanctuary type**: Rescue/retirement — no breeding features. Focus on long-term health and comfort.
- **Animals**: Horses (Red & Sky), goats, chickens, ducks, one pig. Flexible type system for growth.
- **Connectivity**: WiFi near house, cell data further out. Offline-first needed.
- **Team**: 2 people (owner + fiancée). Simple multi-tenant via CloudKit sharing. Design for growth.
- **Feeding**: Reference/instructions only, not a daily feeding log.
- **Expenses**: Total tracking only (not per-animal). One-off expense logging. Categories for filtering.
- **Daily tasks**: Recurring templates (Morning/Evening Chores) + ad-hoc one-offs. Both users see completion.
- **Maintenance**: Property (fences, barn, mowing) AND animal care (farrier, deworming, hoofs).
- **Inventory**: Full supplies — feed, medical, bedding, fencing, tools. Track quantities + reorder thresholds.
- **Reminders**: Custom recurring/one-time for anything (e.g., "muzzle horse every spring").
- **Theme**: System adaptive (light/dark follows iPhone setting).
- **Device**: iPhone only.
- **Tests**: TDD with Swift Testing framework.

**Research Findings**:
- SwiftData is mature in 2026 and the right persistence choice.
- CloudKit sharing requires bridging to `NSPersistentCloudKitContainer` — no native SwiftData sharing API.
- Store photos with `@Attribute(.externalStorage)` — not inline in DB.
- Use Apple system colors for adaptive theme, NOT the hardcoded hex values from the mobile-design skill.
- Each daily task checkbox must be its own SwiftData record to prevent CloudKit last-write-wins conflicts.
- All model properties must be optional or defaulted for CloudKit compatibility.
- Use String (not enum) for extensible types like animal type and categories.
- Local notifications for reminders — work offline, no latency.

### Metis Review
**Identified Gaps** (addressed):
- **CloudKit sharing complexity**: Dedicated task for CloudKit spike — not assumed to "just work."
- **Concurrent editing conflicts**: Task checklist items stored as individual records, not array properties.
- **Schema permanence**: All models designed CloudKit-compatible from day one (optional props, no @Attribute(.unique), no .deny delete rules).
- **Color system conflict**: Plan directs use of Apple system colors instead of skill's hardcoded hex palette.
- **Animal death handling**: Added `status` field (active/deceased/adopted/transferred) and `dateOfPassing` to Animal model.
- **Expense categories**: Added categories despite "total only" — for useful filtering (feed, vet, supplies, facility, other).
- **Notification ownership**: Both users see all reminders — simplest for 2-person team.

---

## Work Objectives

### Core Objective
Build a production-quality iOS app that replaces memory-based tracking with a structured, synced, offline-first farm management system for Red Sky Sanctuary.

### Concrete Deliverables
- `RedSkySanctuary.xcodeproj` — Complete Xcode project
- 5-tab navigation: Dashboard, Animals, Tasks, Supplies, More
- 14+ SwiftData models with full CloudKit compatibility
- TDD test suite covering all models and view models
- CloudKit sharing between 2 users
- Local notification system for reminders and appointments
- System-adaptive theme (light/dark)

### Definition of Done
- [ ] App builds with zero warnings: `xcodebuild -scheme RedSkySanctuary build`
- [ ] All tests pass: `xcodebuild test -scheme RedSkySanctuary`
- [ ] App runs in iPhone simulator with all tabs functional
- [ ] CloudKit sync works between two simulator instances
- [ ] All CRUD operations work offline
- [ ] Notifications fire for scheduled reminders

### Must Have
- Animal profiles with photos, health records, feeding instructions
- Daily task checklists with recurring templates
- Custom reminders with local notifications
- Inventory tracking with reorder alerts
- Expense logging with categories
- Emergency contacts with one-tap calling
- CloudKit sync between 2 devices
- Offline-first (all features work without network)
- System-adaptive light/dark theme
- TDD test coverage on all models and view models

### Must NOT Have (Guardrails)
- `@Attribute(.unique)` anywhere — CloudKit incompatible
- `.deny` delete rules — CloudKit incompatible
- Hardcoded hex color values — use Apple system colors for adaptive theme
- Swift enums for extensible types — use String with constants
- ViewInspector or third-party test dependencies
- Roles, permissions, invitation UI — V1 uses equal access for both users
- Charts, PDF export, tax reporting
- Purchase orders, vendor management, price tracking
- Task priorities, dependencies, subtasks
- Weight tracking, medication withdrawal periods
- Breeding, gestation, pedigree features
- iPad layouts or iPad-specific UI
- RFID/tag scanner integration
- Any third-party packages unless explicitly approved
- `as any`, `@ts-ignore` equivalents (`as!` force casts without guard)
- Property renames after initial schema deployment

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** — ALL verification is agent-executed. No exceptions.

### Test Decision
- **Infrastructure exists**: NO (greenfield — will be created in Task 1)
- **Automated tests**: TDD (test-driven development)
- **Framework**: Swift Testing (`import Testing`, `@Test`, `@Suite`)
- **If TDD**: Each task follows RED (failing test) → GREEN (minimal impl) → REFACTOR
- **Test scope**: Models + ViewModels only. Views verified via simulator QA.
- **Test container**: In-memory `ModelContainer` held as suite property — no disk persistence in tests.

### QA Policy
Every task MUST include agent-executed QA scenarios.
Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{ext}`.

**QA is split by verifiability:**

- **Models / ViewModels (automated)**: TDD tests via `xcodebuild test` on macOS. These are the primary automated verification.
- **UI Structure (code inspection)**: Agent verifies views exist, contain expected SwiftUI modifiers/components, and have `#Preview` blocks via `grep`/`read` tools. This is structural verification, not visual.
- **Visual + Interactive QA (Final Wave only)**: F3 runs on a macOS agent with Xcode + Simulator access. It builds the app, launches in simulator via `xcrun simctl`, and uses XCTest UI tests or manual screen capture to verify visual correctness and interaction flows. Individual task QA does NOT require simulator interaction — that's centralized in F3.
- **CloudKit**: Verified structurally (entitlements, code patterns) during individual tasks. Full sync testing requires Apple Developer account and is deferred to F3.

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Scaffolding — must complete first):
└── Task 1: Xcode project + SwiftData + Swift Testing + folder structure [quick]

Wave 2 (Foundation — 8 parallel, after Wave 1):
├── Task 2: Adaptive design system + reusable UI components [visual-engineering]
├── Task 3: Animal data models + TDD (Animal, AnimalPhoto) [quick]
├── Task 4: Health data models + TDD (HealthRecord, HealthSign) [quick]
├── Task 5: Task data models + TDD (TaskTemplate, TaskTemplateItem, TaskInstance, TaskInstanceItem) [quick]
├── Task 6: Scheduling data models + TDD (Reminder, MaintenanceTask) [quick]
├── Task 7: Supplies data models + TDD (InventoryItem, Expense) [quick]
├── Task 8: Safety data models + TDD (EmergencyContact, EmergencyProtocol) [quick]
└── Task 9: Navigation shell — TabView + NavigationStack stubs for all tabs [quick]

Wave 3 (Core Feature Views — 6 parallel, after Wave 2):
├── Task 10: Animal list view + search/filter [visual-engineering]
├── Task 11: Animal profile/detail view (info, photos, feeding, health summary) [visual-engineering]
├── Task 12: Animal add/edit form (photo capture, type picker, all fields) [visual-engineering]
├── Task 13: Health record management (add vaccination, log vet visit, log symptoms) [visual-engineering]
├── Task 14: Daily task system (template builder + daily checklist + check-off) [deep]
├── Task 15: Maintenance scheduler (create, recurring, mark complete) [visual-engineering]

Wave 4 (Secondary Feature Views — 5 parallel, after Wave 3):
├── Task 16: Custom reminder system (create, edit, recurring, list) [visual-engineering]
├── Task 17: Inventory management (list, add/edit, categories, reorder alerts) [visual-engineering]
├── Task 18: Expense tracker (total view, add one-off, categories, date filter) [visual-engineering]
├── Task 19: Emergency system (contacts + protocols, one-tap call) [visual-engineering]
├── Task 20: Local notification integration (reminders, tasks, vet visits) [deep]

Wave 5 (Integration — 4 parallel, after Wave 4):
├── Task 21: Dashboard — today's overview (tasks, reminders, appointments, low stock) [visual-engineering]
├── Task 22: CloudKit sharing (spike + implementation, multi-user sync) [deep]
├── Task 23: Global search across all data types [quick]
└── Task 24: Settings + onboarding (notification prefs, about, data management) [visual-engineering]

Wave FINAL (After ALL tasks — 4 parallel reviews, then user okay):
├── F1: Plan compliance audit (oracle)
├── F2: Code quality review (unspecified-high)
├── F3: Real manual QA (unspecified-high)
└── F4: Scope fidelity check (deep)
→ Present results → Get explicit user okay
```

### Dependency Matrix

| Task | Depends On | Blocks | Wave |
|------|-----------|--------|------|
| 1 | — | 2-9 | 1 |
| 2 | 1 | 10-12, 14-19, 21, 24 | 2 |
| 3 | 1 | 10-13 | 2 |
| 4 | 1 | 13 | 2 |
| 5 | 1 | 14 | 2 |
| 6 | 1 | 15, 16, 20 | 2 |
| 7 | 1 | 17, 18 | 2 |
| 8 | 1 | 19 | 2 |
| 9 | 1 | 10-21, 23, 24 | 2 |
| 10 | 2, 3, 9 | 21, 23 | 3 |
| 11 | 2, 3, 9 | 21 | 3 |
| 12 | 2, 3, 9 | — | 3 |
| 13 | 2, 3, 4, 9 | 21 | 3 |
| 14 | 2, 5, 9 | 20, 21 | 3 |
| 15 | 2, 6, 9 | 20, 21 | 3 |
| 16 | 2, 6, 9 | 20, 21 | 4 |
| 17 | 2, 7, 9 | 21 | 4 |
| 18 | 2, 7, 9 | 21 | 4 |
| 19 | 2, 8, 9 | — | 4 |
| 20 | 6, 14, 15, 16 | 21 | 4 |
| 21 | 10-18, 20 | — | 5 |
| 22 | 3-8 | — | 5 |
| 23 | 3-8, 9 | — | 5 |
| 24 | 2, 9 | — | 5 |
| F1-F4 | 1-24 | — | FINAL |

### Agent Dispatch Summary

| Wave | Tasks | Dispatch |
|------|-------|----------|
| 1 | 1 | T1 → `quick` + `mobile-design` |
| 2 | 8 | T2 → `visual-engineering` + `mobile-design`, T3-T8 → `quick`, T9 → `quick` + `mobile-design` |
| 3 | 6 | T10-T12 → `visual-engineering` + `mobile-design`, T13 → `visual-engineering` + `mobile-design`, T14 → `deep`, T15 → `visual-engineering` + `mobile-design` |
| 4 | 5 | T16-T19 → `visual-engineering` + `mobile-design`, T20 → `deep` |
| 5 | 4 | T21 → `visual-engineering` + `mobile-design`, T22 → `deep`, T23 → `quick`, T24 → `visual-engineering` + `mobile-design` |
| FINAL | 4 | F1 → `oracle`, F2 → `unspecified-high`, F3 → `unspecified-high`, F4 → `deep` |

---

## TODOs

### Wave 1: Scaffolding

- [x] 1. Xcode Project Scaffolding + SwiftData + Swift Testing

  **What to do**:
  - Create a new Xcode project `RedSkySanctuary` targeting iOS 18+, Swift 6
  - Configure SwiftData `ModelContainer` in the app entry point
  - Set up Swift Testing target (`RedSkySanctuaryTests`)
  - Create folder structure:
    ```
    RedSkySanctuary/
      App/
        RedSkySanctuaryApp.swift
      Models/
      ViewModels/
      Views/
        Dashboard/
        Animals/
        Tasks/
        Supplies/
        More/
      Components/
      Utilities/
      Extensions/
    RedSkySanctuaryTests/
      Models/
      ViewModels/
    ```
  - Configure the `ModelContainer` with an empty model schema (models added in Wave 2)
  - Add a placeholder `ContentView` that shows "Red Sky Sanctuary" text
  - Verify project builds and test target runs (even with zero tests)

  **Must NOT do**:
  - Add any third-party SPM packages
  - Create an overly complex DI system — use `@Environment` and initializer injection
  - Add any data models yet (Wave 2 handles this)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: Project structure conventions and SwiftUI setup patterns

  **Parallelization**:
  - **Can Run In Parallel**: NO — this is the foundation everything depends on
  - **Parallel Group**: Wave 1 (solo)
  - **Blocks**: Tasks 2-9 (all Wave 2 tasks)
  - **Blocked By**: None (first task)

  **References**:
  - **Pattern References**:
    - `.claude/skills/mobile-design/SKILL.md:468-493` — File structure convention for new SwiftUI apps
    - `.claude/skills/mobile-design/SKILL.md:42-55` — Tech stack requirements (SwiftUI, @Observable, Swift 6, iOS 18+)
  - **External References**:
    - Apple SwiftData docs: ModelContainer configuration with CloudKit
    - Swift Testing framework: `import Testing`, `@Test`, `@Suite` syntax

  **Acceptance Criteria**:
  - [ ] `xcodebuild -scheme RedSkySanctuary build` → BUILD SUCCEEDED
  - [ ] `xcodebuild -scheme RedSkySanctuary -destination 'platform=iOS Simulator,name=iPhone 16' test` → TEST SUITE SUCCEEDED (0 tests, 0 failures)
  - [ ] All folders exist in the file structure above
  - [ ] `RedSkySanctuaryApp.swift` contains `@main` entry with `ModelContainer`

  **QA Scenarios**:

  ```
  Scenario: Project builds successfully
    Tool: Bash (xcodebuild)
    Preconditions: Xcode project created with all folders
    Steps:
      1. Run: xcodebuild -scheme RedSkySanctuary -destination 'platform=iOS Simulator,name=iPhone 16' build
      2. Assert: exit code is 0
      3. Assert: output contains "BUILD SUCCEEDED"
    Expected Result: Clean build with zero errors and zero warnings
    Failure Indicators: Any compiler error, missing file reference, or warning
    Evidence: .sisyphus/evidence/task-1-build.txt

  Scenario: Test target runs (empty)
    Tool: Bash (xcodebuild)
    Preconditions: Test target exists
    Steps:
      1. Run: xcodebuild -scheme RedSkySanctuary -destination 'platform=iOS Simulator,name=iPhone 16' test
      2. Assert: exit code is 0
      3. Assert: output contains "Test Suite" and "passed"
    Expected Result: Test suite runs with 0 tests, 0 failures
    Failure Indicators: Test target missing, build failure in test scheme
    Evidence: .sisyphus/evidence/task-1-test.txt
  ```

  **Commit**: YES
  - Message: `chore(project): scaffold Xcode project with SwiftData and Swift Testing`
  - Files: `RedSkySanctuary/**`
  - Pre-commit: `xcodebuild build`

---

### Wave 2: Foundation (8 parallel tasks after Task 1)

- [x] 2. Adaptive Design System + Reusable UI Components

  **What to do**:
  - Create `Color+Extensions.swift` using Apple's **system-adaptive colors** (NOT the hardcoded hex values from the mobile-design skill):
    ```swift
    extension Color {
      static let appBackground = Color(.systemBackground)
      static let surface = Color(.secondarySystemBackground)
      static let surfaceSecondary = Color(.tertiarySystemBackground)
      static let textPrimary = Color(.label)
      static let textSecondary = Color(.secondaryLabel)
      static let border = Color(.separator)
    }
    ```
  - Create `View+Extensions.swift` with common modifiers (card style, section header, etc.)
  - Create reusable components in `Components/`:
    - `SanctuaryCard.swift` — Standard card with continuous corner radius, system background
    - `SanctuaryRow.swift` — List row with icon, title, subtitle, chevron
    - `EmptyStateView.swift` — ContentUnavailableView wrapper for consistent empty states
    - `PhotoPickerView.swift` — Camera + photo library picker, returns compressed image data + thumbnail
    - `FormField.swift` — Styled text field / text editor for forms
  - Follow Rork Max design language: `.font(.system(.title3, design: .rounded).bold())` for headers, `.spring(.snappy)` animations, `.sensoryFeedback` on interactions, `.symbolRenderingMode(.hierarchical)` for icons
  - All components must render correctly in BOTH light and dark mode

  **Must NOT do**:
  - Use the hardcoded hex Color extension from the mobile-design skill (lines 73-88)
  - Add any third-party UI libraries
  - Over-abstract — keep components simple and focused

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: Design tokens, component patterns, animation conventions, Rork Max quality checklist

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 3-9)
  - **Blocks**: Tasks 10-19, 21, 24 (all UI feature tasks)
  - **Blocked By**: Task 1

  **References**:
  - **Pattern References**:
    - `.claude/skills/mobile-design/SKILL.md:69-101` — Color system (adapt to system colors, keep accent colors)
    - `.claude/skills/mobile-design/SKILL.md:106-130` — Typography scale and rules
    - `.claude/skills/mobile-design/SKILL.md:133-165` — Layout, corner radius, shadows
    - `.claude/skills/mobile-design/SKILL.md:244-258` — Card component pattern
    - `.claude/skills/mobile-design/SKILL.md:296-309` — Avatar/AsyncImage pattern
    - `.claude/skills/mobile-design/SKILL.md:333-367` — Animation patterns (snappy spring, scale button)
    - `.claude/skills/mobile-design/SKILL.md:369-383` — Haptic feedback patterns
    - `.claude/skills/mobile-design/SKILL.md:386-409` — Materials and vibrancy
    - `.claude/skills/mobile-design/SKILL.md:446-453` — Empty state pattern
  - **WHY**: The mobile-design skill defines the exact visual language. Components must match these patterns but swap hex colors for system-adaptive equivalents.

  **Acceptance Criteria**:
  - [ ] All 5 components created and contain `#Preview` blocks
  - [ ] Colors adapt correctly between light and dark mode in previews
  - [ ] `xcodebuild build` succeeds with zero warnings

  **QA Scenarios**:

  ```
  Scenario: Components render in light mode
    Tool: Bash (xcodebuild)
    Preconditions: All components created with #Preview blocks
    Steps:
      1. Build project: xcodebuild -scheme RedSkySanctuary build
      2. Assert: BUILD SUCCEEDED
      3. Verify each component file contains `#Preview` block
    Expected Result: All components compile and have preview blocks
    Failure Indicators: Missing #Preview, compilation errors
    Evidence: .sisyphus/evidence/task-2-build.txt

  Scenario: No hardcoded hex colors used
    Tool: Bash (grep)
    Preconditions: Color+Extensions.swift exists
    Steps:
      1. Search for hex color pattern in Color+Extensions.swift: grep -n 'hex:' RedSkySanctuary/Extensions/Color+Extensions.swift
      2. Assert: no matches found (exit code 1)
      3. Search for Color(.system in same file to confirm system colors used
      4. Assert: matches found
    Expected Result: Zero hardcoded hex values, system colors used throughout
    Failure Indicators: Any line containing 'hex:' or hardcoded color values
    Evidence: .sisyphus/evidence/task-2-colors.txt
  ```

  **Commit**: NO (groups with Wave 2 commit)

- [x] 3. Animal Data Models + TDD

  **What to do**:
  - TDD: Write tests FIRST, then implement models
  - Create `Animal.swift` SwiftData model:
    - `id`: UUID (default: UUID())
    - `name`: String (default: "")
    - `animalType`: String (default: "") — e.g., "horse", "goat", "pig", "chicken", "duck"
    - `breed`: String? (default: nil)
    - `birthday`: Date? (default: nil)
    - `dateAdded`: Date (default: .now)
    - `status`: String (default: "active") — "active", "deceased", "adopted", "transferred"
    - `dateOfPassing`: Date? (default: nil)
    - `feedingInstructions`: String? (default: nil)
    - `notes`: String? (default: nil)
    - `photos`: [AnimalPhoto] relationship (cascade delete)
    - `healthRecords`: [HealthRecord] relationship (cascade delete)
    - `healthSigns`: [HealthSign] relationship (cascade delete)
    - `reminders`: [Reminder] relationship (nullify delete)
  - Create `AnimalPhoto.swift` SwiftData model:
    - `id`: UUID (default: UUID())
    - `imageData`: Data? (@Attribute(.externalStorage)) — full resolution HEIC
    - `thumbnailData`: Data? (@Attribute(.externalStorage)) — 300px max thumbnail
    - `caption`: String? (default: nil)
    - `dateAdded`: Date (default: .now)
    - `isPrimary`: Bool (default: false)
    - `animal`: Animal? (inverse of photos)
  - All properties optional or defaulted for CloudKit compatibility
  - All relationships optional with explicit inverses
  - Write Swift Testing tests:
    - Animal CRUD (create, read, update, delete)
    - AnimalPhoto CRUD
    - Animal-Photo relationship (cascade delete)
    - Animal status transitions (active → deceased)
    - Computed properties (age from birthday, display name)
  - Use in-memory `ModelContainer` for all tests

  **Must NOT do**:
  - Use `@Attribute(.unique)` — CloudKit incompatible
  - Use `.deny` delete rules — CloudKit incompatible
  - Use Swift enums for `animalType` or `status` — use String constants
  - Store actual image bytes inline (must use `.externalStorage`)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
    - No skills needed — pure Swift data modeling

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 4-9)
  - **Blocks**: Tasks 10, 11, 12, 13 (animal UI tasks)
  - **Blocked By**: Task 1

  **References**:
  - **External References**:
    - Apple SwiftData docs: `@Model`, `@Attribute(.externalStorage)`, `@Relationship` with inverse
    - Swift Testing docs: `@Test`, `@Suite`, `#expect()` assertions
    - CloudKit + SwiftData compatibility: optional properties, no unique constraints
  - **WHY**: Models are the foundation. Getting CloudKit compatibility right here prevents painful migrations later.

  **Acceptance Criteria**:
  - [ ] `Animal.swift` and `AnimalPhoto.swift` created with all fields
  - [ ] Test file `AnimalModelTests.swift` exists with ≥5 test cases
  - [ ] `xcodebuild test` → all Animal tests pass
  - [ ] No `@Attribute(.unique)` or `.deny` in any model file

  **QA Scenarios**:

  ```
  Scenario: Animal model tests pass
    Tool: Bash (xcodebuild)
    Preconditions: Animal model + tests created
    Steps:
      1. Run: xcodebuild -scheme RedSkySanctuary -destination 'platform=iOS Simulator,name=iPhone 16' test
      2. Assert: exit code 0
      3. Assert: output shows AnimalModelTests with all tests passing
    Expected Result: ≥5 tests pass, 0 failures
    Failure Indicators: Test failures, compilation errors
    Evidence: .sisyphus/evidence/task-3-tests.txt

  Scenario: No CloudKit-incompatible attributes
    Tool: Bash (grep)
    Preconditions: Model files created
    Steps:
      1. Search: grep -rn '@Attribute(.unique)' RedSkySanctuary/Models/
      2. Assert: no matches (exit code 1)
      3. Search: grep -rn '.deny' RedSkySanctuary/Models/
      4. Assert: no matches (exit code 1)
    Expected Result: Zero forbidden attributes found
    Failure Indicators: Any match for unique or deny
    Evidence: .sisyphus/evidence/task-3-compat.txt
  ```

  **Commit**: NO (groups with Wave 2 commit)

- [x] 4. Health Data Models + TDD

  **What to do**:
  - TDD: Write tests FIRST, then implement models
  - Create `HealthRecord.swift` SwiftData model:
    - `id`: UUID (default: UUID())
    - `date`: Date (default: .now)
    - `recordType`: String (default: "") — "vaccination", "vet_visit", "treatment", "checkup", "injury", "illness"
    - `title`: String (default: "")
    - `notes`: String? (default: nil)
    - `veterinarian`: String? (default: nil)
    - `nextVisitDate`: Date? (default: nil)
    - `animal`: Animal? (inverse of healthRecords)
  - Create `HealthSign.swift` SwiftData model:
    - `id`: UUID (default: UUID())
    - `date`: Date (default: .now)
    - `symptom`: String (default: "")
    - `severity`: String (default: "mild") — "mild", "moderate", "severe"
    - `notes`: String? (default: nil)
    - `isResolved`: Bool (default: false)
    - `resolvedDate`: Date? (default: nil)
    - `animal`: Animal? (inverse of healthSigns)
  - All properties optional or defaulted for CloudKit
  - Write Swift Testing tests:
    - HealthRecord CRUD
    - HealthSign CRUD
    - Record-Animal relationship
    - Filtering records by type
    - Resolving a health sign (isResolved + resolvedDate)

  **Must NOT do**:
  - Use Swift enums for `recordType` or `severity` — use String constants
  - Use `@Attribute(.unique)` or `.deny` delete rules

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 3, 5-9)
  - **Blocks**: Task 13 (health record UI)
  - **Blocked By**: Task 1

  **References**:
  - **Pattern References**:
    - Task 3's model patterns — follow same CloudKit-safe conventions
  - **External References**:
    - Apple SwiftData: `@Relationship` with cascade vs nullify delete rules
    - Swift Testing: in-memory ModelContainer setup

  **Acceptance Criteria**:
  - [ ] `HealthRecord.swift` and `HealthSign.swift` created
  - [ ] Test file `HealthModelTests.swift` with ≥5 test cases
  - [ ] `xcodebuild test` → all health tests pass

  **QA Scenarios**:

  ```
  Scenario: Health model tests pass
    Tool: Bash (xcodebuild)
    Preconditions: Health models + tests created
    Steps:
      1. Run: xcodebuild -scheme RedSkySanctuary -destination 'platform=iOS Simulator,name=iPhone 16' test
      2. Assert: output shows HealthModelTests passing
    Expected Result: ≥5 tests pass, 0 failures
    Failure Indicators: Test failures
    Evidence: .sisyphus/evidence/task-4-tests.txt
  ```

  **Commit**: NO (groups with Wave 2 commit)

- [x] 5. Task Data Models + TDD

  **What to do**:
  - TDD: Write tests FIRST, then implement models
  - **CRITICAL**: Each checklist item MUST be its own SwiftData record (not array/property on parent). This prevents CloudKit last-write-wins conflicts when both users check off items simultaneously.
  - Create `TaskTemplate.swift`:
    - `id`: UUID (default: UUID())
    - `name`: String (default: "") — e.g., "Morning Chores", "Evening Chores"
    - `isRecurring`: Bool (default: true)
    - `recurrencePattern`: String? (default: "daily") — "daily", "weekly", "monthly"
    - `createdAt`: Date (default: .now)
    - `templateItems`: [TaskTemplateItem] relationship (cascade)
    - `instances`: [TaskInstance] relationship (cascade)
  - Create `TaskTemplateItem.swift`:
    - `id`: UUID (default: UUID())
    - `title`: String (default: "")
    - `sortOrder`: Int (default: 0)
    - `template`: TaskTemplate? (inverse of templateItems)
  - Create `TaskInstance.swift` (generated for a specific date):
    - `id`: UUID (default: UUID())
    - `date`: Date (default: .now)
    - `isAdHoc`: Bool (default: false) — true for one-off tasks not from template
    - `template`: TaskTemplate? (inverse of instances)
    - `items`: [TaskInstanceItem] relationship (cascade)
  - Create `TaskInstanceItem.swift` (INDIVIDUAL checkable item — own record for CloudKit safety):
    - `id`: UUID (default: UUID())
    - `title`: String (default: "")
    - `isCompleted`: Bool (default: false)
    - `completedBy`: String? (default: nil)
    - `completedAt`: Date? (default: nil)
    - `sortOrder`: Int (default: 0)
    - `instance`: TaskInstance? (inverse of items)
  - Write Swift Testing tests:
    - Template + TemplateItem CRUD
    - Instance generation from template
    - Individual item check-off (simulating concurrent updates)
    - Ad-hoc task instance creation
    - Filtering instances by date

  **Must NOT do**:
  - Store checklist items as an array property on TaskInstance — MUST be separate records
  - Use `@Attribute(.unique)` or `.deny` delete rules

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2-4, 6-9)
  - **Blocks**: Task 14 (daily task UI)
  - **Blocked By**: Task 1

  **References**:
  - **External References**:
    - CloudKit last-write-wins documentation — why individual records matter
    - SwiftData cascade delete rules
  - **WHY**: The individual-item-per-record pattern is the single most important architectural decision for multi-user safety. Getting this wrong causes silent data loss.

  **Acceptance Criteria**:
  - [ ] 4 model files created (TaskTemplate, TaskTemplateItem, TaskInstance, TaskInstanceItem)
  - [ ] Test file `TaskModelTests.swift` with ≥6 test cases
  - [ ] `xcodebuild test` → all task tests pass
  - [ ] TaskInstanceItem is its own `@Model` class (NOT a property on TaskInstance)

  **QA Scenarios**:

  ```
  Scenario: Task model tests pass
    Tool: Bash (xcodebuild)
    Preconditions: All 4 task models + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: TaskModelTests all pass
    Expected Result: ≥6 tests pass, 0 failures
    Failure Indicators: Test failures, items stored as array property
    Evidence: .sisyphus/evidence/task-5-tests.txt

  Scenario: Items are individual records (not array)
    Tool: Bash (grep)
    Preconditions: TaskInstance.swift exists
    Steps:
      1. Verify TaskInstanceItem.swift exists as separate file
      2. grep for '@Relationship' in TaskInstance.swift — should reference [TaskInstanceItem]
      3. grep for 'var items' in TaskInstance.swift — should be relationship, not [String] or [Data]
    Expected Result: TaskInstanceItem is a separate @Model with @Relationship link
    Failure Indicators: Items stored as array property instead of relationship
    Evidence: .sisyphus/evidence/task-5-structure.txt
  ```

  **Commit**: NO (groups with Wave 2 commit)

- [x] 6. Scheduling Data Models + TDD

  **What to do**:
  - TDD: Write tests FIRST, then implement models
  - Create `Reminder.swift`:
    - `id`: UUID (default: UUID())
    - `title`: String (default: "")
    - `notes`: String? (default: nil)
    - `date`: Date (default: .now)
    - `isRecurring`: Bool (default: false)
    - `recurrencePattern`: String? (default: nil) — "yearly", "monthly", "weekly", "daily"
    - `recurrenceEndDate`: Date? (default: nil)
    - `isCompleted`: Bool (default: false)
    - `notificationIdentifier`: String? (default: nil) — for local notification management
    - `relatedAnimal`: Animal? (inverse of reminders, nullify delete)
  - Create `MaintenanceTask.swift`:
    - `id`: UUID (default: UUID())
    - `title`: String (default: "")
    - `category`: String (default: "property") — "property", "animal_care"
    - `notes`: String? (default: nil)
    - `isRecurring`: Bool (default: false)
    - `recurrencePattern`: String? (default: nil)
    - `nextDueDate`: Date? (default: nil)
    - `lastCompletedDate`: Date? (default: nil)
    - `completedBy`: String? (default: nil)
  - Write Swift Testing tests:
    - Reminder CRUD + recurring logic
    - MaintenanceTask CRUD + completion
    - Reminder-Animal optional relationship
    - Due date calculations for recurring items

  **Must NOT do**:
  - Use enums for `recurrencePattern` or `category`
  - Use `@Attribute(.unique)` on notificationIdentifier

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2-5, 7-9)
  - **Blocks**: Tasks 15, 16, 20
  - **Blocked By**: Task 1

  **References**:
  - **Pattern References**:
    - Task 3 and 5 model conventions
  - **External References**:
    - `UNNotificationRequest` identifier patterns — store identifier for cancellation

  **Acceptance Criteria**:
  - [ ] `Reminder.swift` and `MaintenanceTask.swift` created
  - [ ] Test file `SchedulingModelTests.swift` with ≥5 test cases
  - [ ] `xcodebuild test` → all scheduling tests pass

  **QA Scenarios**:

  ```
  Scenario: Scheduling model tests pass
    Tool: Bash (xcodebuild)
    Preconditions: Scheduling models + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: SchedulingModelTests all pass
    Expected Result: ≥5 tests pass, 0 failures
    Evidence: .sisyphus/evidence/task-6-tests.txt
  ```

  **Commit**: NO (groups with Wave 2 commit)

- [x] 7. Supplies Data Models + TDD

  **What to do**:
  - TDD: Write tests FIRST, then implement models
  - Create `InventoryItem.swift`:
    - `id`: UUID (default: UUID())
    - `name`: String (default: "")
    - `category`: String (default: "other") — "feed", "medical", "bedding", "fencing", "tools", "other"
    - `quantity`: Double (default: 0)
    - `unit`: String? (default: nil) — "bales", "bags", "rolls", "boxes", "each"
    - `reorderThreshold`: Double? (default: nil) — alert when quantity drops below
    - `notes`: String? (default: nil)
    - `lastRestocked`: Date? (default: nil)
  - Create `Expense.swift`:
    - `id`: UUID (default: UUID())
    - `amount`: Double (default: 0)
    - `date`: Date (default: .now)
    - `category`: String (default: "other") — "feed", "veterinary", "supplies", "facility", "other"
    - `expenseDescription`: String? (default: nil) — avoid `description` (conflicts with CustomStringConvertible)
    - `notes`: String? (default: nil)
  - Write Swift Testing tests:
    - InventoryItem CRUD + quantity updates
    - Expense CRUD
    - Low stock detection (quantity < reorderThreshold)
    - Expense filtering by category and date range

  **Must NOT do**:
  - Use enums for `category` or `unit`
  - Track expenses per-animal — this is total-only

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2-6, 8-9)
  - **Blocks**: Tasks 17, 18
  - **Blocked By**: Task 1

  **References**:
  - **Pattern References**:
    - Task 3 model conventions (CloudKit-safe defaults)

  **Acceptance Criteria**:
  - [ ] `InventoryItem.swift` and `Expense.swift` created
  - [ ] Test file `SuppliesModelTests.swift` with ≥5 test cases
  - [ ] `xcodebuild test` → all supplies tests pass
  - [ ] Low stock computed property works: `item.isLowStock` returns true when quantity < reorderThreshold

  **QA Scenarios**:

  ```
  Scenario: Supplies model tests pass
    Tool: Bash (xcodebuild)
    Preconditions: Supplies models + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: SuppliesModelTests all pass
    Expected Result: ≥5 tests pass, 0 failures
    Evidence: .sisyphus/evidence/task-7-tests.txt
  ```

  **Commit**: NO (groups with Wave 2 commit)

- [x] 8. Safety Data Models + TDD

  **What to do**:
  - TDD: Write tests FIRST, then implement models
  - Create `EmergencyContact.swift`:
    - `id`: UUID (default: UUID())
    - `name`: String (default: "")
    - `role`: String (default: "") — "veterinarian", "farrier", "poison_control", "animal_control", "neighbor", "other"
    - `phone`: String (default: "")
    - `email`: String? (default: nil)
    - `notes`: String? (default: nil)
    - `isPrimary`: Bool (default: false)
  - Create `EmergencyProtocol.swift`:
    - `id`: UUID (default: UUID())
    - `animalType`: String (default: "general") — "horse", "goat", "pig", "chicken", "duck", "general"
    - `situation`: String (default: "") — "choking", "colic", "injury", "poisoning", "heat_stress", "lameness", "respiratory", "other"
    - `steps`: String (default: "") — ordered steps as text
    - `notes`: String? (default: nil)
  - Write Swift Testing tests:
    - EmergencyContact CRUD
    - EmergencyProtocol CRUD
    - Filtering protocols by animalType
    - Primary contact designation

  **Must NOT do**:
  - Use enums for `role`, `animalType`, or `situation`

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2-7, 9)
  - **Blocks**: Task 19
  - **Blocked By**: Task 1

  **References**:
  - **Pattern References**:
    - Task 3 model conventions

  **Acceptance Criteria**:
  - [ ] `EmergencyContact.swift` and `EmergencyProtocol.swift` created
  - [ ] Test file `SafetyModelTests.swift` with ≥4 test cases
  - [ ] `xcodebuild test` → all safety tests pass

  **QA Scenarios**:

  ```
  Scenario: Safety model tests pass
    Tool: Bash (xcodebuild)
    Preconditions: Safety models + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: SafetyModelTests all pass
    Expected Result: ≥4 tests pass, 0 failures
    Evidence: .sisyphus/evidence/task-8-tests.txt
  ```

  **Commit**: NO (groups with Wave 2 commit)

- [x] 9. Navigation Shell — TabView + NavigationStack Stubs

  **What to do**:
  - Create `ContentView.swift` with a 5-tab `TabView`:
    - **Dashboard** (house.fill) → `DashboardView()` stub
    - **Animals** (pawprint.fill) → `AnimalsListView()` stub
    - **Tasks** (checklist) → `TasksView()` stub
    - **Supplies** (shippingbox.fill) → `SuppliesView()` stub
    - **More** (ellipsis.circle.fill) → `MoreView()` stub
  - Each tab wraps content in `NavigationStack`
  - Create stub views for each tab (placeholder text + icon)
  - Apply design system: `.tint(.blue)`, `.toolbarBackground(.ultraThinMaterial, for: .tabBar)`
  - Ensure tab bar looks correct in both light and dark mode

  **Must NOT do**:
  - Implement any actual feature UI — just stubs
  - Add complex navigation — just NavigationStack shells

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: TabView patterns, NavigationStack conventions

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2-8)
  - **Blocks**: Tasks 10-21, 23, 24
  - **Blocked By**: Task 1

  **References**:
  - **Pattern References**:
    - `.claude/skills/mobile-design/SKILL.md:200-228` — TabView and NavigationStack patterns
    - `.claude/skills/mobile-design/SKILL.md:386-409` — Material backgrounds for toolbars

  **Acceptance Criteria**:
  - [ ] `ContentView.swift` has 5-tab TabView
  - [ ] Each tab has a stub view in its respective folder
  - [ ] App launches to Dashboard tab by default
  - [ ] `xcodebuild build` succeeds

  **QA Scenarios**:

  ```
  Scenario: App launches with tab navigation
    Tool: Bash (xcodebuild)
    Preconditions: ContentView + all stub views created
    Steps:
      1. Build: xcodebuild -scheme RedSkySanctuary build
      2. Assert: BUILD SUCCEEDED
      3. Verify ContentView.swift contains TabView with 5 Tab entries
    Expected Result: App compiles with all tabs defined
    Failure Indicators: Missing tab, build error
    Evidence: .sisyphus/evidence/task-9-build.txt
  ```

  **Commit**: YES (commit all Wave 2 tasks together)
  - Message: `feat(foundation): add data models, design system, and navigation shell`
  - Files: `RedSkySanctuary/Models/**`, `RedSkySanctuary/Components/**`, `RedSkySanctuary/Extensions/**`, `RedSkySanctuary/Views/**`
  - Pre-commit: `xcodebuild test`

---

### Wave 3: Core Feature Views (6 parallel after Wave 2)

- [x] 10. Animal List View + Search/Filter

  **What to do**:
  - Create `AnimalsListView.swift` replacing the stub:
    - Query all animals from SwiftData using `@Query`
    - Display as scrollable list of animal cards showing: thumbnail photo (or placeholder icon), name, type, breed, age
    - Searchable by name (`.searchable(text:)`)
    - Filterable by animal type (segmented picker or horizontal pill filters: All, Horses, Goats, Pigs, Poultry)
    - "Add Animal" button (plus icon) in toolbar → navigates to add form (Task 12)
    - Empty state using `ContentUnavailableView` when no animals exist
    - Navigation to animal detail (Task 11) on row tap
  - Create `AnimalRowView.swift` component:
    - Thumbnail (50x50 circle), name (headline), type + breed (subheadline), age (caption)
    - Chevron on right
  - Follow Rork Max patterns: spring animations on list, haptic on tap, hierarchical SF Symbols

  **Must NOT do**:
  - Implement the detail view (Task 11) or add form (Task 12) — just navigate to them
  - Add complex sorting beyond the type filter

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: List patterns, search, empty states, row components

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 11-15)
  - **Blocks**: Tasks 21, 23
  - **Blocked By**: Tasks 2, 3, 9

  **References**:
  - **Pattern References**:
    - `.claude/skills/mobile-design/SKILL.md:314-329` — List row with chevron pattern
    - `.claude/skills/mobile-design/SKILL.md:296-309` — Avatar/image pattern
    - `.claude/skills/mobile-design/SKILL.md:446-453` — Empty state
    - `.claude/skills/mobile-design/SKILL.md:455-464` — Search pattern
    - `.claude/skills/mobile-design/SKILL.md:430-441` — ScrollView + LazyVStack pattern
    - `RedSkySanctuary/Models/Animal.swift` — Animal model (from Task 3)
    - `RedSkySanctuary/Components/SanctuaryRow.swift` — Reusable row component (from Task 2)
    - `RedSkySanctuary/Components/EmptyStateView.swift` — Empty state wrapper (from Task 2)

  **Acceptance Criteria**:
  - [ ] `AnimalsListView.swift` displays animals from SwiftData
  - [ ] Search filters animals by name
  - [ ] Type filter shows/hides animals by type
  - [ ] Empty state shows when no animals
  - [ ] `xcodebuild build` succeeds

  **QA Scenarios**:

  ```
  Scenario: Animal list displays and search works
    Tool: Bash (xcodebuild + grep)
    Preconditions: AnimalsListView.swift created
    Steps:
      1. Build project: xcodebuild build
      2. Verify file contains @Query for Animal
      3. Verify file contains .searchable modifier
      4. Verify file contains ContentUnavailableView or EmptyStateView
    Expected Result: List view compiles with query, search, and empty state
    Failure Indicators: Missing query, missing search, build failure
    Evidence: .sisyphus/evidence/task-10-build.txt

  Scenario: Empty state code exists for zero-animal case
    Tool: Bash (grep)
    Preconditions: AnimalsListView.swift created
    Steps:
      1. grep -n 'ContentUnavailableView\|EmptyStateView' RedSkySanctuary/Views/Animals/AnimalsListView.swift
      2. Assert: at least one match found
      3. Verify empty state shows when animals array is empty (check conditional: `if animals.isEmpty` or `.overlay`)
    Expected Result: Empty state view is present and conditionally shown when no animals exist
    Failure Indicators: No empty state view, always shows list even when empty
    Evidence: .sisyphus/evidence/task-10-empty.txt
  ```

  **Commit**: NO (groups with Wave 3 commit)

- [x] 11. Animal Profile / Detail View

  **What to do**:
  - Create `AnimalDetailView.swift`:
    - Header: Large photo (or placeholder), name, type/breed, age, status badge
    - Photo gallery: Horizontal scroll of all photos with tap to view full-size
    - Info section: Birthday, date added, status, notes
    - Feeding instructions section: Display feedingInstructions text, edit button
    - Health summary section: Latest 3 health records, "View All" link → health list
    - Active health signs section: Unresolved signs with severity badges
    - Related reminders section: Upcoming reminders for this animal
    - Edit button in toolbar → navigates to edit form (Task 12)
    - Deceased/transferred animals show muted styling with status banner
  - Use GroupBox sections (Rork Max preferred card style)
  - Smooth transitions between sections
  - Handle animals with no photos gracefully (paw print placeholder icon)

  **Must NOT do**:
  - Implement inline editing — always navigate to edit form
  - Add health record creation here — that's Task 13
  - Show feeding as a daily log — just reference text

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: Detail view patterns, GroupBox cards, photo galleries

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 10, 12-15)
  - **Blocks**: Task 21
  - **Blocked By**: Tasks 2, 3, 9

  **References**:
  - **Pattern References**:
    - `.claude/skills/mobile-design/SKILL.md:260-276` — GroupBox card pattern
    - `.claude/skills/mobile-design/SKILL.md:296-309` — Avatar/AsyncImage pattern
    - `.claude/skills/mobile-design/SKILL.md:230-238` — Sheet presentation for full-size photos
    - `RedSkySanctuary/Models/Animal.swift` — Animal model fields
    - `RedSkySanctuary/Models/AnimalPhoto.swift` — Photo model
    - `RedSkySanctuary/Models/HealthRecord.swift` — Health records (from Task 4)
    - `RedSkySanctuary/Models/HealthSign.swift` — Health signs (from Task 4)
    - `RedSkySanctuary/Components/SanctuaryCard.swift` — Card component (from Task 2)

  **Acceptance Criteria**:
  - [ ] `AnimalDetailView.swift` shows all animal information in grouped sections
  - [ ] Photo gallery displays thumbnails with tap-to-expand
  - [ ] Animals with no photos show placeholder icon
  - [ ] Deceased animals show status banner
  - [ ] `xcodebuild build` succeeds

  **QA Scenarios**:

  ```
  Scenario: Detail view renders all sections
    Tool: Bash (xcodebuild + grep)
    Preconditions: AnimalDetailView.swift created
    Steps:
      1. Build: xcodebuild build
      2. Verify file contains GroupBox sections for: info, feeding, health, signs
      3. Verify file references Animal model properties (name, animalType, breed, birthday)
    Expected Result: Detail view compiles with all data sections
    Failure Indicators: Missing sections, build error
    Evidence: .sisyphus/evidence/task-11-build.txt
  ```

  **Commit**: NO (groups with Wave 3 commit)

- [x] 12. Animal Add/Edit Form with Photo Handling

  **What to do**:
  - Create `AnimalFormView.swift` (used for both add and edit):
    - Form fields: name (required), animalType (picker with common types + custom), breed, birthday (DatePicker), feedingInstructions (TextEditor), notes (TextEditor), status (picker — only shown in edit mode)
    - Photo section: "Add Photo" button → PhotoPickerView (from Task 2), display added photos as horizontal scroll, tap to remove, mark one as primary
    - Animal type picker: preset options (Horse, Goat, Pig, Chicken, Duck) + "Other" with custom text field
    - Save button: validates required fields (name, type), creates/updates SwiftData model
    - Cancel button: dismisses without saving
    - In edit mode: pre-populate all fields from existing animal
    - Photo handling: capture image → generate thumbnail (300px max) → store both as `@Attribute(.externalStorage)`
  - Create `AnimalFormViewModel` (TDD):
    - Validation logic (name required, type required)
    - Photo compression and thumbnail generation
    - Save/update logic
    - Tests for validation, photo processing, CRUD

  **Must NOT do**:
  - Allow saving without name or type
  - Store photos inline in SwiftData (must use externalStorage)
  - Add weight or breeding fields (out of scope)

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: Form patterns, photo picker, DatePicker conventions

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 10, 11, 13-15)
  - **Blocks**: None directly
  - **Blocked By**: Tasks 2, 3, 9

  **References**:
  - **Pattern References**:
    - `RedSkySanctuary/Components/PhotoPickerView.swift` — Photo picker component (from Task 2)
    - `RedSkySanctuary/Components/FormField.swift` — Styled form fields (from Task 2)
    - `RedSkySanctuary/Models/Animal.swift` — Animal model
    - `RedSkySanctuary/Models/AnimalPhoto.swift` — Photo model with externalStorage
  - **External References**:
    - PhotosUI framework: `PhotosPicker` for photo library access
    - UIImage compression: `.heicRepresentation()` for HEIC format
    - Image thumbnailing: `UIGraphicsImageRenderer` for 300px thumbnails

  **Acceptance Criteria**:
  - [ ] `AnimalFormView.swift` with add and edit modes
  - [ ] `AnimalFormViewModel.swift` with TDD tests
  - [ ] Validation prevents saving without name or type
  - [ ] Photos saved with `@Attribute(.externalStorage)` (thumbnail + full)
  - [ ] `xcodebuild test` → AnimalFormViewModelTests pass

  **QA Scenarios**:

  ```
  Scenario: Form validates required fields
    Tool: Bash (xcodebuild)
    Preconditions: AnimalFormViewModel + tests created
    Steps:
      1. Run tests: xcodebuild test
      2. Assert: test for "save with empty name fails" passes
      3. Assert: test for "save with valid data succeeds" passes
    Expected Result: Validation tests pass
    Evidence: .sisyphus/evidence/task-12-tests.txt

  Scenario: Form validation logic prevents empty name save
    Tool: Bash (grep + xcodebuild)
    Preconditions: AnimalFormViewModel.swift created
    Steps:
      1. Run: xcodebuild test — assert AnimalFormViewModelTests pass
      2. grep for validation logic in AnimalFormViewModel: 'name.isEmpty\|name.trimmingCharacters\|isValid\|canSave'
      3. Assert: validation check exists that prevents saving when name is empty
      4. grep for '.disabled' modifier in AnimalFormView: 'disabled.*canSave\|disabled.*isValid'
      5. Assert: Save button is conditionally disabled based on validation
    Expected Result: ViewModel has validation logic AND view disables save button when invalid
    Failure Indicators: No validation in ViewModel, save button always enabled
    Evidence: .sisyphus/evidence/task-12-validation.txt
  ```

  **Commit**: NO (groups with Wave 3 commit)

- [ ] 13. Health Record Management (Vaccinations, Vet Visits, Symptoms)

  **What to do**:
  - Create `HealthRecordListView.swift` (shown from animal detail):
    - List of all health records for an animal, sorted by date (newest first)
    - Grouped by type: vaccinations, vet visits, treatments, checkups
    - Each row shows: date, type icon, title, vet name (if applicable)
    - "Add Record" button → sheet with form
    - Filter by record type (segmented control)
  - Create `HealthRecordFormView.swift`:
    - Fields: recordType (picker), title, date (DatePicker), veterinarian, nextVisitDate, notes
    - Different field sets based on recordType (vaccination shows next due date, vet visit shows vet name)
  - Create `HealthSignListView.swift` (shown from animal detail):
    - List active (unresolved) signs at top, resolved below
    - Each row: symptom, severity badge (color-coded: green/yellow/red), date, resolve button
    - "Log Sign" button → form
  - Create `HealthSignFormView.swift`:
    - Fields: symptom, severity (picker: mild/moderate/severe), notes, date
  - Create `HealthViewModel` (TDD):
    - Add/edit/delete health records
    - Add/resolve health signs
    - Filter records by type
    - Tests for all CRUD + filtering + resolving signs

  **Must NOT do**:
  - Add medication withdrawal tracking (out of scope)
  - Add weight tracking fields (out of scope)
  - Link health records across animals

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: List patterns, form patterns, badge styling

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 10-12, 14-15)
  - **Blocks**: Task 21
  - **Blocked By**: Tasks 2, 3, 4, 9

  **References**:
  - **Pattern References**:
    - `RedSkySanctuary/Models/HealthRecord.swift` — Health record model (from Task 4)
    - `RedSkySanctuary/Models/HealthSign.swift` — Health sign model (from Task 4)
    - `RedSkySanctuary/Components/SanctuaryRow.swift` — Row component (from Task 2)
    - `.claude/skills/mobile-design/SKILL.md:230-238` — Sheet presentation

  **Acceptance Criteria**:
  - [ ] Health record list + form views created
  - [ ] Health sign list + form views created
  - [ ] `HealthViewModel.swift` with TDD tests (≥6 tests)
  - [ ] Severity badges show correct colors (mild=green, moderate=yellow, severe=red)
  - [ ] `xcodebuild test` → HealthViewModel tests pass

  **QA Scenarios**:

  ```
  Scenario: Health record CRUD via ViewModel
    Tool: Bash (xcodebuild)
    Preconditions: HealthViewModel + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: HealthViewModelTests all pass
    Expected Result: ≥6 tests pass, 0 failures
    Evidence: .sisyphus/evidence/task-13-tests.txt

  Scenario: Health sign severity badges render
    Tool: Bash (grep)
    Preconditions: HealthSignListView.swift created
    Steps:
      1. Verify file contains color mappings for mild/moderate/severe
      2. Verify uses .green, .yellow/.orange, .red system colors
    Expected Result: Color-coded severity badges defined
    Evidence: .sisyphus/evidence/task-13-badges.txt
  ```

  **Commit**: NO (groups with Wave 3 commit)

- [ ] 14. Daily Task System (Template Builder + Daily Checklist)

  **What to do**:
  - Create `TasksView.swift` replacing the stub — main Tasks tab:
    - **Today's Checklist** section at top: shows today's task instances with checkable items
    - **Templates** section below: list of recurring templates (Morning Chores, Evening Chores, etc.)
    - "Add Template" button
    - "Add One-Off Task" button → creates ad-hoc TaskInstance for today
  - Create `TaskTemplateFormView.swift`:
    - Fields: template name, recurrence (daily/weekly/monthly), items list
    - Add/remove/reorder template items
    - Save creates TaskTemplate + TaskTemplateItems
  - Create `DailyChecklistView.swift`:
    - Shows a TaskInstance for a given date
    - Each TaskInstanceItem is a checkable row with title, completion status, who completed it
    - Tapping checkbox marks `isCompleted = true`, sets `completedAt` and `completedBy`
    - Shows completion progress (e.g., "4/7 done")
    - Supports adding ad-hoc items to any day
  - Create `TasksViewModel` (TDD):
    - Generate daily instances from templates
    - Check/uncheck items (individual record updates for CloudKit safety)
    - Add ad-hoc tasks
    - Calculate completion progress
    - Tests: instance generation, item toggling, progress calculation, ad-hoc creation

  **Must NOT do**:
  - Add task priorities, dependencies, or subtasks
  - Add assignment to specific users (both users see all tasks)
  - Store items as array property on instance — MUST be individual records

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Complex state management with CloudKit-safe concurrent editing patterns
  - **Skills**: [`mobile-design`]
    - `mobile-design`: Checklist UI patterns, list interactions

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 10-13, 15)
  - **Blocks**: Tasks 20, 21
  - **Blocked By**: Tasks 2, 5, 9

  **References**:
  - **Pattern References**:
    - `RedSkySanctuary/Models/TaskTemplate.swift` — Template model (from Task 5)
    - `RedSkySanctuary/Models/TaskTemplateItem.swift` — Template item (from Task 5)
    - `RedSkySanctuary/Models/TaskInstance.swift` — Instance model (from Task 5)
    - `RedSkySanctuary/Models/TaskInstanceItem.swift` — Individual checkable item (from Task 5)
  - **WHY individual items matter**: CloudKit uses last-write-wins per record. If items were an array on TaskInstance, two users checking different boxes simultaneously would cause one check to disappear. Individual records solve this.

  **Acceptance Criteria**:
  - [ ] TasksView.swift shows today's checklist + template list
  - [ ] TaskTemplateFormView.swift for creating/editing templates
  - [ ] DailyChecklistView.swift with per-item checking
  - [ ] `TasksViewModel.swift` with TDD tests (≥6 tests)
  - [ ] Each checkbox updates its own TaskInstanceItem record (NOT the parent)
  - [ ] `xcodebuild test` → TasksViewModel tests pass

  **QA Scenarios**:

  ```
  Scenario: Task instance generation from template
    Tool: Bash (xcodebuild)
    Preconditions: TasksViewModel + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: test for "generate instance from template" passes
      3. Assert: test for "check item updates individual record" passes
    Expected Result: ≥6 tests pass, individual item updates verified
    Evidence: .sisyphus/evidence/task-14-tests.txt

  Scenario: Items stored as individual records
    Tool: Bash (grep)
    Preconditions: TasksViewModel.swift created
    Steps:
      1. Verify TasksViewModel checks individual TaskInstanceItem.isCompleted
      2. Verify no bulk array updates on TaskInstance
    Expected Result: Each checkbox toggle saves one TaskInstanceItem, not parent array
    Failure Indicators: Array-level updates on TaskInstance
    Evidence: .sisyphus/evidence/task-14-individual.txt
  ```

  **Commit**: NO (groups with Wave 3 commit)

- [ ] 15. Maintenance Scheduler

  **What to do**:
  - Create `MaintenanceListView.swift`:
    - Two sections: "Property" and "Animal Care" maintenance tasks
    - Each row: title, category icon, next due date, last completed
    - Overdue tasks highlighted in red/orange
    - "Add Task" button → form
    - Tap to view details / mark complete
  - Create `MaintenanceFormView.swift`:
    - Fields: title, category (property/animal_care), notes, isRecurring, recurrencePattern, nextDueDate
  - Create `MaintenanceDetailView.swift`:
    - Shows full details + history of completion
    - "Mark Complete" button: sets lastCompletedDate, calculates next due date based on recurrence
  - Create `MaintenanceViewModel` (TDD):
    - CRUD for maintenance tasks
    - Mark complete + auto-calculate next due date
    - Filter by category
    - Sort by due date (overdue first)
    - Tests: CRUD, completion, recurrence calculation, overdue detection

  **Must NOT do**:
  - Add task assignment to specific users
  - Add complex recurrence (custom days, exceptions) — just daily/weekly/monthly/yearly
  - Link maintenance tasks to specific animals (keep simple)

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: List patterns, form patterns, status indicators

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 10-14)
  - **Blocks**: Tasks 20, 21
  - **Blocked By**: Tasks 2, 6, 9

  **References**:
  - **Pattern References**:
    - `RedSkySanctuary/Models/MaintenanceTask.swift` — Maintenance model (from Task 6)
    - `RedSkySanctuary/Components/SanctuaryRow.swift` — Row component (from Task 2)

  **Acceptance Criteria**:
  - [ ] Maintenance list, form, and detail views created
  - [ ] `MaintenanceViewModel.swift` with TDD tests (≥5 tests)
  - [ ] Overdue tasks visually highlighted
  - [ ] "Mark Complete" auto-calculates next due date for recurring tasks
  - [ ] `xcodebuild test` → MaintenanceViewModel tests pass

  **QA Scenarios**:

  ```
  Scenario: Recurring maintenance auto-calculates next due
    Tool: Bash (xcodebuild)
    Preconditions: MaintenanceViewModel + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: test for "mark complete calculates next due date" passes
      3. Assert: test for "overdue detection" passes
    Expected Result: ≥5 tests pass, recurrence calculation works
    Evidence: .sisyphus/evidence/task-15-tests.txt
  ```

  **Commit**: YES
  - Message: `feat(core): implement animal management, health records, and daily tasks`
  - Files: `RedSkySanctuary/Views/Animals/**`, `RedSkySanctuary/Views/Tasks/**`, `RedSkySanctuary/ViewModels/**`
  - Pre-commit: `xcodebuild test`

---

### Wave 4: Secondary Feature Views (5 parallel after Wave 3)

- [ ] 16. Custom Reminder System

  **What to do**:
  - Create `RemindersListView.swift` (accessible from Tasks tab or More tab):
    - List of all reminders sorted by date
    - Sections: "Upcoming", "Recurring", "Completed"
    - Each row: title, date, recurrence indicator (🔄 icon), related animal name (if linked)
    - "Add Reminder" button → form
    - Swipe to complete / delete
  - Create `ReminderFormView.swift`:
    - Fields: title, notes, date (DatePicker), isRecurring toggle, recurrencePattern (yearly/monthly/weekly/daily), recurrenceEndDate (optional), relatedAnimal (optional picker)
    - Example use case shown as placeholder: "e.g., Muzzle horses every spring"
  - Create `RemindersViewModel` (TDD):
    - CRUD for reminders
    - Filter by upcoming/recurring/completed
    - Schedule/cancel local notifications (via notificationIdentifier)
    - Generate next occurrence for recurring reminders
    - Tests: CRUD, filtering, recurrence generation, notification scheduling

  **Must NOT do**:
  - Add complex custom recurrence rules (no "every 3rd Tuesday") — just standard patterns
  - Add multi-user notification targeting — both users get all notifications

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: List patterns, form patterns, swipe actions

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 17-20)
  - **Blocks**: Tasks 20, 21
  - **Blocked By**: Tasks 2, 6, 9

  **References**:
  - **Pattern References**:
    - `RedSkySanctuary/Models/Reminder.swift` — Reminder model (from Task 6)
    - `RedSkySanctuary/Models/Animal.swift` — For optional animal linking
  - **External References**:
    - `UNUserNotificationCenter` — scheduling local notifications
    - `UNCalendarNotificationTrigger` — for date-based triggers

  **Acceptance Criteria**:
  - [ ] Reminder list + form views created
  - [ ] `RemindersViewModel.swift` with TDD tests (≥5 tests)
  - [ ] Recurring reminders show recurrence indicator
  - [ ] Can optionally link a reminder to an animal
  - [ ] `xcodebuild test` → RemindersViewModel tests pass

  **QA Scenarios**:

  ```
  Scenario: Reminder CRUD and filtering
    Tool: Bash (xcodebuild)
    Preconditions: RemindersViewModel + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: RemindersViewModelTests all pass
    Expected Result: ≥5 tests pass, 0 failures
    Evidence: .sisyphus/evidence/task-16-tests.txt
  ```

  **Commit**: NO (groups with Wave 4 commit)

- [ ] 17. Inventory Management

  **What to do**:
  - Create `InventoryListView.swift` (in Supplies tab):
    - List of all inventory items grouped by category (Feed, Medical, Bedding, Fencing, Tools, Other)
    - Each row: name, quantity with unit, low stock indicator (red badge when below threshold)
    - Horizontal category filter pills
    - "Add Item" button → form
    - Tap row → detail with edit
    - Quick quantity adjustment: stepper or +/- buttons inline
  - Create `InventoryFormView.swift`:
    - Fields: name, category (picker), quantity (number), unit (picker), reorderThreshold (optional), notes
  - Create `InventoryViewModel` (TDD):
    - CRUD for inventory items
    - Low stock detection (quantity < reorderThreshold)
    - Category filtering
    - Quantity updates (increment/decrement)
    - List of all low-stock items (for dashboard)
    - Tests: CRUD, low stock detection, filtering, quantity ops

  **Must NOT do**:
  - Add purchase orders, vendor info, or price tracking
  - Add barcode scanning
  - Track inventory per-animal

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: List patterns, badges, inline controls

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 16, 18-20)
  - **Blocks**: Task 21
  - **Blocked By**: Tasks 2, 7, 9

  **References**:
  - **Pattern References**:
    - `RedSkySanctuary/Models/InventoryItem.swift` — Inventory model (from Task 7)
    - `RedSkySanctuary/Components/SanctuaryRow.swift` — Row component

  **Acceptance Criteria**:
  - [ ] Inventory list + form views created
  - [ ] `InventoryViewModel.swift` with TDD tests (≥5 tests)
  - [ ] Low stock items show red badge/indicator
  - [ ] Category filter works
  - [ ] `xcodebuild test` → InventoryViewModel tests pass

  **QA Scenarios**:

  ```
  Scenario: Low stock detection
    Tool: Bash (xcodebuild)
    Preconditions: InventoryViewModel + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: test for "isLowStock returns true when below threshold" passes
      3. Assert: test for "lowStockItems returns correct filtered list" passes
    Expected Result: Low stock logic works correctly
    Evidence: .sisyphus/evidence/task-17-tests.txt
  ```

  **Commit**: NO (groups with Wave 4 commit)

- [ ] 18. Expense Tracker

  **What to do**:
  - Create `ExpenseListView.swift` (in Supplies tab, alongside inventory):
    - Total expenses display at top (sum for selected period)
    - List of expenses sorted by date (newest first)
    - Date range filter (This Month, This Year, All Time, Custom)
    - Category filter pills
    - Each row: amount (formatted currency), date, category icon, description
    - "Add Expense" button → form
    - Swipe to delete
  - Create `ExpenseFormView.swift`:
    - Fields: amount (currency input), date (DatePicker), category (picker), description, notes
    - Quick category presets: Feed, Veterinary, Supplies, Facility, Other
  - Create `ExpenseViewModel` (TDD):
    - CRUD for expenses
    - Total calculation for date range
    - Category filtering
    - Date range filtering
    - Tests: CRUD, total calculation, filtering by category + date

  **Must NOT do**:
  - Track expenses per-animal (total only)
  - Add receipt photo scanning
  - Add tax reporting or PDF export
  - Add budget tracking or forecasting

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: List patterns, currency formatting, date filtering

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 16, 17, 19, 20)
  - **Blocks**: Task 21
  - **Blocked By**: Tasks 2, 7, 9

  **References**:
  - **Pattern References**:
    - `RedSkySanctuary/Models/Expense.swift` — Expense model (from Task 7)
  - **External References**:
    - `NumberFormatter` with `.currency` style for amount display

  **Acceptance Criteria**:
  - [ ] Expense list + form views created
  - [ ] `ExpenseViewModel.swift` with TDD tests (≥5 tests)
  - [ ] Total expense sum shows at top of list
  - [ ] Date range filter works (this month/year/all)
  - [ ] `xcodebuild test` → ExpenseViewModel tests pass

  **QA Scenarios**:

  ```
  Scenario: Expense total calculation
    Tool: Bash (xcodebuild)
    Preconditions: ExpenseViewModel + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: test for "total calculation for date range" passes
    Expected Result: Sum correctly calculated for filtered date range
    Evidence: .sisyphus/evidence/task-18-tests.txt
  ```

  **Commit**: NO (groups with Wave 4 commit)

- [ ] 19. Emergency System (Contacts + Protocols)

  **What to do**:
  - Create `EmergencyView.swift` (in More tab):
    - Two sections: "Emergency Contacts" and "Emergency Protocols"
    - **Contacts section**:
      - List of contacts with: name, role badge, phone number
      - Primary contact highlighted at top
      - Tap phone number → one-tap call (using `tel:` URL scheme)
      - "Add Contact" button → form
    - **Protocols section**:
      - Grouped by animal type (Horse, Goat, Pig, Chicken, Duck, General)
      - Each protocol: situation title, expandable steps
      - "Add Protocol" button → form
  - Create `EmergencyContactFormView.swift`:
    - Fields: name, role (picker), phone, email, notes, isPrimary toggle
  - Create `EmergencyProtocolFormView.swift`:
    - Fields: animalType (picker), situation (picker + custom), steps (TextEditor with numbered list), notes
  - Design the emergency view for fast access — large tap targets, minimal scrolling to reach contacts

  **Must NOT do**:
  - Add GPS/location features
  - Add automatic emergency calling
  - Over-complicate the protocol steps — plain text is fine

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: Accessibility, large tap targets, contact card patterns

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 16-18, 20)
  - **Blocks**: None
  - **Blocked By**: Tasks 2, 8, 9

  **References**:
  - **Pattern References**:
    - `RedSkySanctuary/Models/EmergencyContact.swift` — Contact model (from Task 8)
    - `RedSkySanctuary/Models/EmergencyProtocol.swift` — Protocol model (from Task 8)
  - **External References**:
    - `URL(string: "tel://\(phone)")` — one-tap calling pattern
    - Apple HIG: Emergency-style UI with large buttons and high contrast

  **Acceptance Criteria**:
  - [ ] Emergency contacts list with one-tap calling
  - [ ] Emergency protocols grouped by animal type
  - [ ] Contact + protocol forms created
  - [ ] Primary contact shown first/highlighted
  - [ ] `xcodebuild build` succeeds

  **QA Scenarios**:

  ```
  Scenario: Emergency view renders with calling capability
    Tool: Bash (grep)
    Preconditions: EmergencyView.swift created
    Steps:
      1. Verify file contains "tel:" URL scheme for phone calls
      2. Verify contacts section and protocols section both exist
      3. Build: xcodebuild build — assert success
    Expected Result: Emergency view compiles with call capability
    Evidence: .sisyphus/evidence/task-19-build.txt
  ```

  **Commit**: NO (groups with Wave 4 commit)

- [ ] 20. Local Notification Integration

  **What to do**:
  - Create `NotificationManager.swift` as an `@Observable` class:
    - Request notification permission (strategic delay — ask when first reminder is created, not on launch)
    - Schedule local notifications for:
      - Reminders (one-time and recurring)
      - Upcoming vet visits (from HealthRecord.nextVisitDate)
      - Overdue maintenance tasks
      - Low stock alerts (daily check)
    - Cancel notifications when reminder is deleted/completed
    - Use `UNCalendarNotificationTrigger` for date-based
    - Use `UNTimeIntervalNotificationTrigger` for recurring intervals
    - Store `notificationIdentifier` on Reminder model for cancellation
    - Add actionable notifications: "Mark Complete" action on task/reminder notifications
  - Create `NotificationManagerTests.swift` (TDD):
    - Test scheduling logic (correct trigger dates)
    - Test cancellation logic
    - Test permission request flow
    - Test action handling

  **Must NOT do**:
  - Ask for notification permission on first launch — wait until first reminder
  - Add push notifications (local only)
  - Add notification grouping or threading (keep simple)

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: OS-level integration with UNUserNotificationCenter, complex scheduling logic
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 16-19)
  - **Blocks**: Task 21
  - **Blocked By**: Tasks 6, 14, 15, 16

  **References**:
  - **Pattern References**:
    - `RedSkySanctuary/Models/Reminder.swift` — notificationIdentifier field
    - `RedSkySanctuary/Models/HealthRecord.swift` — nextVisitDate for vet reminders
    - `RedSkySanctuary/Models/MaintenanceTask.swift` — overdue detection
  - **External References**:
    - `UNUserNotificationCenter` API
    - `UNCalendarNotificationTrigger`, `UNTimeIntervalNotificationTrigger`
    - `UNNotificationAction`, `UNNotificationCategory` for actionable notifications

  **Acceptance Criteria**:
  - [ ] `NotificationManager.swift` created with schedule/cancel methods
  - [ ] `NotificationManagerTests.swift` with TDD tests (≥5 tests)
  - [ ] Permission requested only when first reminder is created
  - [ ] Notifications scheduled for reminders, vet visits, overdue maintenance
  - [ ] `xcodebuild test` → NotificationManager tests pass

  **QA Scenarios**:

  ```
  Scenario: Notification scheduling tests
    Tool: Bash (xcodebuild)
    Preconditions: NotificationManager + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: NotificationManagerTests all pass
    Expected Result: ≥5 tests pass, scheduling logic verified
    Evidence: .sisyphus/evidence/task-20-tests.txt
  ```

  **Commit**: YES
  - Message: `feat(features): add reminders, inventory, expenses, emergency, and notifications`
  - Files: `RedSkySanctuary/Views/Tasks/Reminders/**`, `RedSkySanctuary/Views/Supplies/**`, `RedSkySanctuary/Views/More/Emergency/**`, `RedSkySanctuary/Utilities/NotificationManager.swift`
  - Pre-commit: `xcodebuild test`

---

### Wave 5: Integration (4 parallel after Wave 4)

- [ ] 21. Dashboard — Today's Overview

  **What to do**:
  - Create `DashboardView.swift` replacing the stub:
    - **Welcome header**: "Red Sky Sanctuary" with current date
    - **Today's Tasks** section: Compact checklist showing today's task progress (e.g., "Morning Chores 3/7"), tap to navigate to full checklist
    - **Upcoming** section: Next 3 reminders/appointments/vet visits across all features, sorted by date
    - **Attention Needed** section: Unresolved health signs (severe first), overdue maintenance tasks, low stock items
    - **Quick Actions** row: "Add Animal", "Log Health", "Add Expense", "Emergency" — 4 icon buttons
    - **Animal Count** card: Quick stats showing total animals by type (🐴 3 🐐 2 🐷 1 🐔 4 🦆 2)
  - Create `DashboardViewModel` (TDD):
    - Aggregate data from all models
    - Today's task progress
    - Upcoming events (sorted, max 3)
    - Attention items (unresolved signs, overdue tasks, low stock)
    - Animal count by type
    - Tests: aggregation, sorting, filtering, empty states

  **Must NOT do**:
  - Add charts or graphs (out of scope)
  - Add weather integration
  - Show more than 3 upcoming items (keep concise)
  - Duplicate full feature views — just show summaries with navigation links

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: Dashboard card layouts, GroupBox sections, quick action buttons

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 22-24)
  - **Blocks**: None
  - **Blocked By**: Tasks 10-18, 20

  **References**:
  - **Pattern References**:
    - `.claude/skills/mobile-design/SKILL.md:244-276` — Card and GroupBox patterns
    - `.claude/skills/mobile-design/SKILL.md:168-196` — Icon patterns for quick actions
    - All ViewModel files from previous tasks — for data aggregation
  - **WHY**: Dashboard is the first screen users see. It must answer: "What needs my attention today?"

  **Acceptance Criteria**:
  - [ ] `DashboardView.swift` with all sections (tasks, upcoming, attention, quick actions, stats)
  - [ ] `DashboardViewModel.swift` with TDD tests (≥5 tests)
  - [ ] Today's task progress shows correct completion count
  - [ ] Attention section surfaces unresolved health signs + overdue items
  - [ ] `xcodebuild test` → DashboardViewModel tests pass

  **QA Scenarios**:

  ```
  Scenario: Dashboard aggregation tests
    Tool: Bash (xcodebuild)
    Preconditions: DashboardViewModel + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: DashboardViewModelTests all pass
    Expected Result: ≥5 tests pass — aggregation, sorting, filtering verified
    Evidence: .sisyphus/evidence/task-21-tests.txt

  Scenario: Dashboard view contains all required sections
    Tool: Bash (grep)
    Preconditions: DashboardView.swift created
    Steps:
      1. Build: xcodebuild build — assert BUILD SUCCEEDED
      2. grep for "Red Sky Sanctuary" in DashboardView.swift — assert welcome header text exists
      3. grep for quick action section: 'Add Animal\|Log Health\|Add Expense\|Emergency'
      4. Assert: at least 3 of 4 quick action labels found
      5. grep for attention/alert section: 'Attention\|attention\|lowStock\|overdue\|unresolved'
      6. Assert: attention section exists
    Expected Result: Dashboard compiles with welcome header, quick actions, and attention section
    Failure Indicators: Missing sections, build failure
    Evidence: .sisyphus/evidence/task-21-dashboard.txt
  ```

  **Commit**: NO (groups with Wave 5 commit)

- [ ] 22. CloudKit Sharing (Spike + Implementation)

  **What to do**:
  - **SPIKE PHASE** (research + prototype):
    - Investigate SwiftData + CloudKit sharing current API surface
    - Determine whether to use `NSPersistentCloudKitContainer` bridge or SwiftData native (if available in iOS 18+)
    - Configure CloudKit container in Xcode project capabilities
    - Set up dual store configuration (private + shared zones)
  - **IMPLEMENTATION PHASE**:
    - Create `CloudKitManager.swift`:
      - Configure `ModelContainer` with CloudKit sync enabled
      - Create and manage `CKShare` for the sanctuary workspace
      - Invite user via share sheet (CKShare participant)
      - Handle share acceptance
      - Monitor sync status (for UI indicator)
    - Add sync status indicator to the app (subtle, non-intrusive):
      - Small cloud icon in navigation bar: synced ✓, syncing ↻, offline ✗
    - Create `CloudKitManagerTests.swift` (TDD where testable):
      - Configuration tests
      - Share creation tests
      - Sync status logic tests
    - Update `RedSkySanctuaryApp.swift` to use CloudKit-configured ModelContainer

  **Must NOT do**:
  - Build roles or permissions system — V1 is equal access for both users
  - Add user profile management or avatar
  - Build a custom sync engine — use CloudKit's native sync
  - Add sign-in UI — rely on iCloud account on device

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Complex infrastructure with CloudKit APIs, dual stores, and sharing protocols
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 21, 23, 24)
  - **Blocks**: None
  - **Blocked By**: Tasks 3-8 (all models must exist)

  **References**:
  - **External References**:
    - Apple CloudKit documentation: `CKShare`, `CKShareParticipant`
    - WWDC sessions on SwiftData + CloudKit integration
    - `NSPersistentCloudKitContainer` sharing guide
  - **WHY**: This is the highest-risk task. CloudKit sharing has no simple SwiftData API. The spike phase de-risks before committing to an approach.

  **Acceptance Criteria**:
  - [ ] CloudKit container configured in Xcode capabilities
  - [ ] `CloudKitManager.swift` created with share management
  - [ ] Sync status indicator visible in app
  - [ ] ModelContainer configured for CloudKit sync
  - [ ] `xcodebuild build` succeeds with CloudKit entitlements

  **QA Scenarios**:

  ```
  Scenario: CloudKit configuration compiles
    Tool: Bash (xcodebuild)
    Preconditions: CloudKit manager and configuration created
    Steps:
      1. Build: xcodebuild -scheme RedSkySanctuary build
      2. Assert: BUILD SUCCEEDED
      3. Verify CloudKitManager.swift exists and references CKShare
    Expected Result: App compiles with CloudKit integration
    Failure Indicators: Missing entitlements, build errors
    Evidence: .sisyphus/evidence/task-22-build.txt

  Scenario: Sync indicator shows offline state
    Tool: Bash (grep)
    Preconditions: CloudKitManager.swift exists
    Steps:
      1. Verify file contains sync status enum/state (synced, syncing, offline)
      2. Verify a view shows sync status indicator
    Expected Result: Sync status state machine defined
    Evidence: .sisyphus/evidence/task-22-status.txt
  ```

  **Commit**: NO (groups with Wave 5 commit)

- [ ] 23. Global Search

  **What to do**:
  - Create `SearchView.swift` (accessible via search icon in navigation or spotlight):
    - Single search bar that queries across ALL data types
    - Results grouped by type: Animals, Health Records, Tasks, Inventory, Reminders, Emergency
    - Each result shows: type icon, title, subtitle (relevant detail), tap to navigate
    - Recent searches (last 5, stored in UserDefaults)
    - Empty state with search suggestions: "Try searching for an animal name, supply item, or symptom"
  - Create `SearchViewModel` (TDD):
    - Multi-model query: searches Animal.name, HealthRecord.title, InventoryItem.name, Reminder.title, EmergencyContact.name, etc.
    - Result ranking: exact matches first, then partial
    - Recent search storage
    - Tests: multi-model search, ranking, recent storage

  **Must NOT do**:
  - Add full-text search or complex ranking algorithms — simple `contains` matching is fine
  - Add search filters beyond the automatic type grouping
  - Index search terms — query SwiftData directly

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: Search patterns

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 21, 22, 24)
  - **Blocks**: None
  - **Blocked By**: Tasks 3-8, 9

  **References**:
  - **Pattern References**:
    - `.claude/skills/mobile-design/SKILL.md:455-464` — Search pattern
    - All model files — for search field mapping

  **Acceptance Criteria**:
  - [ ] `SearchView.swift` with cross-model search
  - [ ] `SearchViewModel.swift` with TDD tests (≥4 tests)
  - [ ] Results grouped by type with navigation
  - [ ] Recent searches stored and displayed
  - [ ] `xcodebuild test` → SearchViewModel tests pass

  **QA Scenarios**:

  ```
  Scenario: Cross-model search tests
    Tool: Bash (xcodebuild)
    Preconditions: SearchViewModel + tests created
    Steps:
      1. Run: xcodebuild test
      2. Assert: SearchViewModelTests all pass
    Expected Result: ≥4 tests pass — multi-model search verified
    Evidence: .sisyphus/evidence/task-23-tests.txt
  ```

  **Commit**: NO (groups with Wave 5 commit)

- [ ] 24. Settings + Onboarding

  **What to do**:
  - Create `MoreView.swift` replacing the stub (More tab):
    - Sections:
      - **Sanctuary**: "Red Sky Sanctuary" name, logo/icon area
      - **Features**: Emergency Contacts & Protocols (→ EmergencyView), Reminders (→ RemindersListView)
      - **Settings**: Notification preferences toggle, appearance info (follows system)
      - **Data**: Export data (share as JSON), clear all data (with confirmation)
      - **About**: App version, "Inspired by Medwyn's Valley", link to non-profit info
    - CloudKit sharing: "Invite Team Member" button → share sheet (uses CloudKitManager)
  - Create `SettingsView.swift`:
    - Notification preferences: toggle per category (reminders, tasks, maintenance, vet visits)
    - Data management: export, clear (with destructive confirmation alert)
  - Create a simple first-launch onboarding (3 screens):
    - Screen 1: "Welcome to Red Sky Sanctuary" with app icon
    - Screen 2: "Track Your Animals" — quick overview of features
    - Screen 3: "Get Started" — prompt to add first animal
    - Store `hasCompletedOnboarding` in `@AppStorage`
    - Skip button available

  **Must NOT do**:
  - Add complex user profile management
  - Add theme customization (system-adaptive only)
  - Add analytics or tracking
  - Make onboarding more than 3 screens

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
  - **Skills**: [`mobile-design`]
    - `mobile-design`: Settings patterns, onboarding conventions

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 21-23)
  - **Blocks**: None
  - **Blocked By**: Tasks 2, 9

  **References**:
  - **Pattern References**:
    - `.claude/skills/mobile-design/SKILL.md:278-291` — Settings row pattern
    - `RedSkySanctuary/Utilities/CloudKitManager.swift` — For sharing (from Task 22)

  **Acceptance Criteria**:
  - [ ] `MoreView.swift` with all sections
  - [ ] `SettingsView.swift` with notification toggles
  - [ ] 3-screen onboarding flow
  - [ ] `hasCompletedOnboarding` stored in `@AppStorage`
  - [ ] "Invite Team Member" triggers share sheet
  - [ ] `xcodebuild build` succeeds

  **QA Scenarios**:

  ```
  Scenario: Settings and onboarding compile
    Tool: Bash (xcodebuild)
    Preconditions: MoreView, SettingsView, and onboarding created
    Steps:
      1. Build: xcodebuild build
      2. Assert: BUILD SUCCEEDED
      3. Verify onboarding checks @AppStorage for hasCompletedOnboarding
    Expected Result: All settings and onboarding views compile
    Evidence: .sisyphus/evidence/task-24-build.txt

  Scenario: Onboarding shows on first launch
    Tool: Bash (grep)
    Preconditions: Onboarding views created
    Steps:
      1. Verify @AppStorage("hasCompletedOnboarding") exists in app entry or root view
      2. Verify onboarding is shown when hasCompletedOnboarding == false
    Expected Result: First-launch onboarding gated by AppStorage flag
    Evidence: .sisyphus/evidence/task-24-onboarding.txt
  ```

  **Commit**: YES
  - Message: `feat(integration): add dashboard, CloudKit sync, search, and settings`
  - Files: `RedSkySanctuary/Views/Dashboard/**`, `RedSkySanctuary/Views/More/**`, `RedSkySanctuary/Utilities/CloudKitManager.swift`
  - Pre-commit: `xcodebuild test`

---

## Final Verification Wave (MANDATORY — after ALL implementation tasks)

> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.

- [ ] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. For each "Must Have": verify implementation exists (read file, run build). For each "Must NOT Have": search codebase for forbidden patterns (force casts, `@Attribute(.unique)`, hardcoded hex colors, `.deny` delete rules) — reject with file:line if found. Check evidence files exist in `.sisyphus/evidence/`. Compare deliverables against plan.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [ ] F2. **Code Quality Review** — `unspecified-high`
  Run `xcodebuild -scheme RedSkySanctuary build` + `xcodebuild test -scheme RedSkySanctuary`. Review all Swift files for: `as!` force casts without guard, empty catches, `print()` in production code, commented-out code, unused imports. Check AI slop: excessive comments, over-abstraction, generic variable names (data/result/item/temp), unnecessary protocol conformances.
  Output: `Build [PASS/FAIL] | Tests [N pass/N fail] | Files [N clean/N issues] | VERDICT`

- [ ] F3. **Real Manual QA** — `unspecified-high` + `mobile-design` skill
  This is the ONLY task that performs interactive simulator testing. Requires macOS with Xcode and Simulator.
  1. Build: `xcodebuild -scheme RedSkySanctuary -destination 'platform=iOS Simulator,name=iPhone 16' build`
  2. Install to simulator: `xcrun simctl install booted RedSkySanctuary.app`
  3. Launch: `xcrun simctl launch booted com.redskysanctuary.app`
  4. Test each tab loads (Dashboard, Animals, Tasks, Supplies, More)
  5. Test CRUD flow: Add animal → Add health record → View on dashboard
  6. Test daily tasks: Create template → Generate daily instance → Check items off
  7. Test edge cases: empty state (fresh app), long animal names, back navigation
  8. Capture screenshots: `xcrun simctl io booted screenshot .sisyphus/evidence/final-qa/{name}.png`
  9. Test light AND dark mode: `xcrun simctl ui booted appearance dark` / `light`
  Save all evidence to `.sisyphus/evidence/final-qa/`.
  Output: `Scenarios [N/N pass] | Integration [N/N] | Edge Cases [N tested] | VERDICT`

- [ ] F4. **Scope Fidelity Check** — `deep`
  For each task: read "What to do", read actual implementation. Verify 1:1 — everything in spec was built (no missing), nothing beyond spec was built (no creep). Check "Must NOT do" compliance. Detect cross-task contamination: Task N touching Task M's files. Flag unaccounted changes.
  Output: `Tasks [N/N compliant] | Contamination [CLEAN/N issues] | Unaccounted [CLEAN/N files] | VERDICT`

---

## Commit Strategy

| After Tasks | Commit Message | Pre-commit Check |
|-------------|---------------|-----------------|
| 1 | `chore(project): scaffold Xcode project with SwiftData and Swift Testing` | `xcodebuild build` |
| 2-9 | `feat(foundation): add data models, design system, and navigation shell` | `xcodebuild test` |
| 10-15 | `feat(core): implement animal management, health records, and daily tasks` | `xcodebuild test` |
| 16-20 | `feat(features): add reminders, inventory, expenses, emergency, and notifications` | `xcodebuild test` |
| 21-24 | `feat(integration): add dashboard, CloudKit sync, search, and settings` | `xcodebuild test` |

---

## Success Criteria

### Verification Commands
```bash
xcodebuild -scheme RedSkySanctuary build          # Expected: BUILD SUCCEEDED
xcodebuild -scheme RedSkySanctuary test            # Expected: ALL TESTS PASSED
xcodebuild -scheme RedSkySanctuary -destination 'platform=iOS Simulator,name=iPhone 16' build  # Expected: BUILD SUCCEEDED
```

### Final Checklist
- [ ] App builds with zero warnings
- [ ] All Swift Testing tests pass
- [ ] All 5 tabs load and display correct content
- [ ] Animal CRUD works (add, view, edit, with photos)
- [ ] Health records can be added and viewed per animal
- [ ] Daily task checklists work (create template, check items)
- [ ] Maintenance tasks can be created and marked complete
- [ ] Reminders fire local notifications at scheduled time
- [ ] Inventory items show low-stock alerts when below threshold
- [ ] Expenses can be logged with categories
- [ ] Emergency contacts support one-tap calling
- [ ] Dashboard shows today's overview
- [ ] CloudKit sync works between two devices
- [ ] App works fully offline (airplane mode)
- [ ] Light and dark mode both look correct
- [ ] All "Must NOT Have" patterns absent from codebase
