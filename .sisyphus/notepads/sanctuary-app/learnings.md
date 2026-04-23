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

## Task 2: Animal & AnimalPhoto Models (TDD)
- Created `Animal.swift` @Model with all CloudKit-safe properties (optional or defaulted)
- Created `AnimalPhoto.swift` @Model with @Attribute(.externalStorage) for image/thumbnail Data
- Implemented computed properties: `age` (calculates years from birthday), `displayName` (returns name or "Unnamed Animal")
- Used String constants (AnimalType, AnimalStatus structs) instead of Swift enums for extensibility
- Commented out future relationships (HealthRecord, HealthSign, Reminder) with TODO markers
- Created 14 test cases in AnimalModelTests.swift using Swift Testing (@Test, @Suite, #expect)
- Tests cover: defaults, custom values, updates, status transitions, computed properties, photo linking, cascade delete, constants
- Used in-memory ModelContainer for all tests (no disk persistence)
- Cascade delete rule on photos relationship ensures orphaned photos are removed when animal is deleted

## Task 3: HealthRecord & HealthSign Models (TDD)
- Created `HealthRecord.swift` @Model with properties: id, date, recordType, title, notes, veterinarian, nextVisitDate, animal (inverse relationship)
- Created `HealthSign.swift` @Model with properties: id, date, symptom, severity, notes, isResolved, resolvedDate, animal (inverse relationship)
- Implemented String constant structs: RecordType (vaccination, vet_visit, treatment, checkup, injury, illness) and Severity (mild, moderate, severe)
- Followed exact Animal.swift pattern: @Model final class, all properties defaulted or optional, explicit init with all parameters
- Created HealthModelTests.swift with 12 comprehensive test cases covering:
  - HealthRecord: create with defaults, create with custom values, update properties, filter by type
  - HealthSign: create with defaults, create with custom values, resolve (set isResolved=true + resolvedDate), filter by severity, filter unresolved
  - Relationships: HealthRecord linked to Animal, HealthSign linked to Animal
  - Constants: RecordType and Severity constant structs
- Used in-memory ModelContainer with all 4 models (Animal, AnimalPhoto, HealthRecord, HealthSign)
- Uncommented healthRecords and healthSigns relationships in Animal.swift with inverse predicates
- No @Attribute(.unique) or .deny delete rules used (CloudKit compatibility)
- All tests use Swift Testing framework (@Test, @Suite, #expect, FetchDescriptor with predicates)

## Task 4: Task Models (TDD) — Daily Checklist System
- Created 4 SwiftData models for task/checklist system:
  - `TaskTemplate.swift`: Reusable task template with properties: id, name, isRecurring, recurrencePattern, createdAt, templateItems (cascade), instances (cascade)
  - `TaskTemplateItem.swift`: Individual template item with properties: id, title, sortOrder, template (inverse)
  - `TaskInstance.swift`: Generated instance for a specific date with properties: id, date, isAdHoc, template (inverse), items (cascade)
  - `TaskInstanceItem.swift`: Individual checkable item (SEPARATE RECORD for CloudKit LWW safety) with properties: id, title, isCompleted, completedBy, completedAt, sortOrder, instance (inverse)
- Created `RecurrencePattern` String constant struct with static lets: daily, weekly, monthly
- CRITICAL DESIGN: Each checklist item is its own @Model record (not an array property) to prevent CloudKit last-write-wins data loss when multiple users check different boxes simultaneously
- Implemented `markComplete(by:)` mutating method on TaskInstanceItem to atomically set isCompleted, completedBy, completedAt
- Implemented `displayName` computed property on TaskTemplate (returns name or "Unnamed Task")
- Implemented `displayDate` computed property on TaskInstance (formats date as medium style)
- Created TaskModelTests.swift with 12 comprehensive test cases covering:
  - TaskTemplate: defaults, custom values, displayName, persistence with items
  - TaskTemplateItem: creation with defaults and custom values
  - TaskInstance: generation from template, date filtering, ad-hoc creation
  - TaskInstanceItem: individual check-off, multiple items checked independently
  - Cascade delete: template items removed when template deleted, instance items removed when instance deleted
  - RecurrencePattern: constant values
- Used in-memory ModelContainer with all 8 models (Animal, AnimalPhoto, HealthRecord, HealthSign, TaskTemplate, TaskTemplateItem, TaskInstance, TaskInstanceItem)
- All relationships use @Relationship with explicit inverses and cascade delete rules where appropriate
- No @Attribute(.unique) or .deny delete rules used (CloudKit compatibility)
- All tests use Swift Testing framework with FetchDescriptor predicates for filtering

## Task 5: Reminder & MaintenanceTask Models (TDD) — Scheduling System
- Created `Reminder.swift` @Model with properties: id, title, notes, date, isRecurring, recurrencePattern, recurrenceEndDate, isCompleted, notificationIdentifier, relatedAnimal (inverse)
- Created `MaintenanceTask.swift` @Model with properties: id, title, category, notes, isRecurring, recurrencePattern, nextDueDate, lastCompletedDate, completedBy
- Implemented String constant structs: ReminderRecurrence (yearly, monthly, weekly, daily) and MaintenanceCategory (property, animal_care)
- Followed exact Animal.swift pattern: @Model final class, all properties defaulted or optional, explicit init with all parameters
- Updated Animal.swift to uncomment the reminders relationship: `@Relationship(inverse: \Reminder.relatedAnimal) var reminders: [Reminder]? = []`
- Created SchedulingModelTests.swift with 11 comprehensive test cases covering:
  - Reminder: create with defaults, create with custom values, CRUD operations, recurrence pattern validation, completion marking, Animal relationship
  - MaintenanceTask: create with defaults, create with custom values, CRUD operations, category validation, completion tracking, recurring with due date
- Used in-memory ModelContainer with all 10 models (Animal, AnimalPhoto, HealthRecord, HealthSign, TaskTemplate, TaskTemplateItem, TaskInstance, TaskInstanceItem, Reminder, MaintenanceTask)
- No @Attribute(.unique) or .deny delete rules used (CloudKit compatibility)
- All tests use Swift Testing framework (@Test, @Suite, #expect, FetchDescriptor with predicates)
- Reminder-Animal relationship enables tracking reminders for specific animals (e.g., "Groom Bessie", "Vet appointment for Bessie")
- MaintenanceTask supports both property maintenance (fence repair, barn cleaning) and animal care tasks (hay delivery, pasture inspection)

## Task 6: InventoryItem & Expense Models (TDD) — Supplies & Accounting System
- Created `InventoryItem.swift` @Model with properties: id, name, category, quantity, unit, reorderThreshold, notes, lastRestocked
  - Used String-based category ("feed", "medical", "bedding", "fencing", "tools", "other") for extensibility
  - Used String-based unit ("bales", "bags", "rolls", "boxes", "each") for flexible quantity tracking
  - Implemented `isLowStock` computed property: returns true when reorderThreshold is set AND quantity < threshold
- Created `Expense.swift` @Model with properties: id, amount, date, category, expenseDescription, notes
  - Used `expenseDescription` property name to avoid conflict with CustomStringConvertible protocol
  - Used String-based category ("feed", "veterinary", "supplies", "facility", "other") for extensibility
  - Avoided animal-specific relationship; expenses are facility-wide totals only
- Created String constant structs: InventoryCategory, InventoryUnit, ExpenseCategory with static let values
- Followed exact Animal.swift pattern: @Model final class, all properties defaulted or optional, explicit init with all parameters
- Created SuppliesModelTests.swift with 15 comprehensive test cases covering:
  - InventoryItem: create with defaults, create with custom values, isLowStock edge cases (no threshold, below/at/above threshold), CRUD operations
  - Expense: create with defaults, create with custom values, CRUD operations, filter by category, filter by date range
  - Constants: InventoryCategory, InventoryUnit, ExpenseCategory accessibility
- Used in-memory ModelContainer with both models (InventoryItem, Expense)
- isLowStock logic: guard against nil threshold, returns false if no threshold set, compares quantity < threshold
- No @Attribute(.unique) or .deny delete rules used (CloudKit compatibility)
- All tests use Swift Testing framework (@Test, @Suite, #expect, async/await for container tests, FetchDescriptor with predicates)

## Task 7: EmergencyContact & EmergencyProtocol Models (TDD) — Safety System
- Created `EmergencyContact.swift` @Model with properties: id, name, role, phone, email, notes, isPrimary
  - Used String-based role ("veterinarian", "farrier", "poison_control", "animal_control", "neighbor", "other") for extensibility
  - Implemented `displayName` computed property: returns name or "Unnamed Contact"
  - isPrimary flag allows designating a primary emergency contact for quick access
- Created `EmergencyProtocol.swift` @Model with properties: id, animalType, situation, steps, notes
  - Used String-based animalType ("horse", "goat", "pig", "chicken", "duck", "general") for species-specific protocols
  - Used String-based situation ("choking", "colic", "injury", "poisoning", "heat_stress", "lameness", "respiratory", "other") for emergency types
  - steps property stores ordered emergency response steps as text (multiline string)
  - Implemented `displaySituation` computed property: returns situation or "Unknown Situation"
- Created String constant structs: ContactRole, EmergencySituation, AnimalTypeForEmergency with static let values
- Followed exact Animal.swift pattern: @Model final class, all properties defaulted or optional, explicit init with all parameters
- Created SafetyModelTests.swift with 16 comprehensive test cases covering:
  - EmergencyContact: create with defaults, create with custom values, update properties, displayName, filter by isPrimary, filter by role
  - EmergencyProtocol: create with defaults, create with custom values, update properties, displaySituation, filter by animalType, filter by situation
  - Constants: ContactRole, EmergencySituation, AnimalTypeForEmergency accessibility
- Used in-memory ModelContainer with both models (EmergencyContact, EmergencyProtocol)
- No @Attribute(.unique) or .deny delete rules used (CloudKit compatibility)
- All tests use Swift Testing framework (@Test, @Suite, #expect, FetchDescriptor with predicates)
- Safety system enables quick access to emergency contacts and species-specific emergency protocols during critical situations
