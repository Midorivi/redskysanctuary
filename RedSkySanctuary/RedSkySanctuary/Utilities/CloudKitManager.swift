import CloudKit
import CoreData
import Observation
import SwiftData
import SwiftUI

@MainActor @Observable
final class CloudKitManager {
    enum SyncStatus: Equatable {
        case synced
        case syncing
        case offline
        case error(String)
    }

    private var eventObserver: NSObjectProtocol?

    var syncStatus: SyncStatus = .offline

    nonisolated deinit {
        // eventObserver cleanup is handled by NotificationCenter's weak reference
    }

    func configureSyncMonitoring() {
        guard eventObserver == nil else { return }

        eventObserver = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                as? NSPersistentCloudKitContainer.Event
            let ended = event?.endDate != nil
            let errorMessage = event?.error?.localizedDescription
            MainActor.assumeIsolated {
                self?.applySyncStatus(ended: ended, errorMessage: errorMessage, hasEvent: event != nil)
            }
        }
    }

    func createShare(for container: ModelContainer) async throws -> CKShare {
        _ = container

        syncStatus = .syncing

        let database = CKContainer.default().privateCloudDatabase
        let workspaceRecordID = CKRecord.ID(recordName: "sanctuary-workspace")
        let workspaceRecord = CKRecord(recordType: "SanctuaryWorkspace", recordID: workspaceRecordID)
        workspaceRecord["name"] = "Red Sky Sanctuary" as CKRecordValue

        let share = CKShare(rootRecord: workspaceRecord)
        share[CKShare.SystemFieldKey.title] = "Red Sky Sanctuary" as CKRecordValue

        do {
            _ = try await database.modifyRecords(
                saving: [workspaceRecord, share],
                deleting: [],
                savePolicy: .allKeys,
                atomically: true
            )
            syncStatus = .synced
            return share
        } catch {
            syncStatus = Self.syncStatus(for: error)
            throw error
        }
    }

    func acceptShare(_ metadata: CKShare.Metadata) async throws {
        syncStatus = .syncing

        do {
            try await CKContainer.default().accept(metadata)
            syncStatus = .synced
        } catch {
            syncStatus = Self.syncStatus(for: error)
            throw error
        }
    }

    nonisolated static func makeContainer() -> ModelContainer {
        // Default to local-only container for Personal Team compatibility
        return makeLocalContainer()
    }

    nonisolated static func makeLocalContainer() -> ModelContainer {
        let schema = Schema([
            Animal.self, AnimalPhoto.self,
            HealthRecord.self, HealthSign.self,
            TaskTemplate.self, TaskTemplateItem.self,
            TaskInstance.self, TaskInstanceItem.self,
            Reminder.self, MaintenanceTask.self,
            InventoryItem.self, Expense.self,
            EmergencyContact.self, EmergencyProtocol.self
        ])
        let config = ModelConfiguration(
            "RedSkySanctuary",
            schema: schema,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create local ModelContainer: \(error)")
        }
    }

    nonisolated static func makeCloudKitContainer() -> ModelContainer {
        let schema = Schema([
            Animal.self, AnimalPhoto.self,
            HealthRecord.self, HealthSign.self,
            TaskTemplate.self, TaskTemplateItem.self,
            TaskInstance.self, TaskInstanceItem.self,
            Reminder.self, MaintenanceTask.self,
            InventoryItem.self, Expense.self,
            EmergencyContact.self, EmergencyProtocol.self
        ])
        let config = ModelConfiguration(
            "RedSkySanctuary",
            schema: schema,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create CloudKit ModelContainer: \(error)")
        }
    }

    private func applySyncStatus(ended: Bool, errorMessage: String?, hasEvent: Bool) {
        guard hasEvent else { return }
        if let errorMessage {
            syncStatus = .error(errorMessage)
        } else if ended {
            syncStatus = .synced
        } else {
            syncStatus = .syncing
        }
    }

    private nonisolated static func syncStatus(for error: Error) -> SyncStatus {
        guard let cloudKitError = error as? CKError else {
            return .error(error.localizedDescription)
        }

        switch cloudKitError.code {
        case .networkUnavailable, .networkFailure, .serviceUnavailable, .notAuthenticated:
            return .offline
        default:
            return .error(cloudKitError.localizedDescription)
        }
    }
}

struct CloudSyncStatusIndicator: View {
    @Environment(CloudKitManager.self) private var cloudKitManager

    var body: some View {
        Image(systemName: iconName)
            .font(.subheadline)
            .symbolEffect(.rotate, isActive: isSyncing)
            .foregroundStyle(tintColor)
            .accessibilityLabel(accessibilityLabel)
            .help(accessibilityLabel)
    }

    private var iconName: String {
        switch cloudKitManager.syncStatus {
        case .synced:
            return "checkmark.icloud"
        case .syncing:
            return "arrow.clockwise.icloud"
        case .offline:
            return "xmark.icloud"
        case .error:
            return "exclamationmark.icloud"
        }
    }

    private var tintColor: Color {
        switch cloudKitManager.syncStatus {
        case .synced:
            return .green
        case .syncing:
            return .blue
        case .offline:
            return .secondary
        case .error:
            return .red
        }
    }

    private var isSyncing: Bool {
        if case .syncing = cloudKitManager.syncStatus {
            return true
        }

        return false
    }

    private var accessibilityLabel: String {
        switch cloudKitManager.syncStatus {
        case .synced:
            return "Cloud sync complete"
        case .syncing:
            return "Cloud sync in progress"
        case .offline:
            return "Cloud sync offline"
        case .error(let message):
            return "Cloud sync error: \(message)"
        }
    }
}
