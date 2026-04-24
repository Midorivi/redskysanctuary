import Foundation
import Observation
import UserNotifications

protocol UserNotificationCenterProtocol: AnyObject, Sendable {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping @Sendable (Bool, (any Error)?) -> Void)
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: (@Sendable ((any Error)?) -> Void)?)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>)
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol {}

@MainActor @Observable
final class NotificationManager {

    static let reminderCategoryIdentifier = "sanctuary.reminder"
    static let markCompleteActionIdentifier = "markComplete"

    private let notificationCenter: UserNotificationCenterProtocol
    private let calendar: Calendar

    var isAuthorized = false

    init(
        notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current(),
        calendar: Calendar = .current
    ) {
        self.notificationCenter = notificationCenter
        self.calendar = calendar
        configureCategories()
    }

    @discardableResult
    func requestPermission() async -> Bool {
        do {
            let granted = try await requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            isAuthorized = false
            return false
        }
    }

    @discardableResult
    func scheduleReminder(_ reminder: Reminder) async -> String? {
        let identifier = reminder.notificationIdentifier ?? "reminder-\(reminder.id.uuidString)"

        let scheduledIdentifier = await scheduleNotification(
            identifier: identifier,
            title: reminder.title,
            body: reminder.notes,
            date: reminder.date
        )

        reminder.notificationIdentifier = scheduledIdentifier
        return scheduledIdentifier
    }

    func cancelNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    @discardableResult
    func scheduleVetVisitReminder(for record: HealthRecord) async -> String? {
        guard let nextVisitDate = record.nextVisitDate else { return nil }

        return await scheduleNotification(
            identifier: "vet-\(record.id.uuidString)",
            title: "Vet Visit Reminder",
            body: record.title,
            date: nextVisitDate
        )
    }

    @discardableResult
    func scheduleMaintenanceReminder(for task: MaintenanceTask) async -> String? {
        guard let nextDueDate = task.nextDueDate else { return nil }

        return await scheduleNotification(
            identifier: "maintenance-\(task.id.uuidString)",
            title: "Maintenance Reminder",
            body: task.title,
            date: nextDueDate
        )
    }

    @discardableResult
    func scheduleLowStockAlert(for item: InventoryItem) async -> String? {
        guard item.isLowStock else { return nil }

        return await scheduleImmediateNotification(
            identifier: "inventory-low-stock-\(item.id.uuidString)",
            title: "Low Stock Alert",
            body: item.name
        )
    }

    private func configureCategories() {
        let markCompleteAction = UNNotificationAction(
            identifier: Self.markCompleteActionIdentifier,
            title: "Mark Complete"
        )

        let reminderCategory = UNNotificationCategory(
            identifier: Self.reminderCategoryIdentifier,
            actions: [markCompleteAction],
            intentIdentifiers: []
        )

        notificationCenter.setNotificationCategories([reminderCategory])
    }

    private func scheduleNotification(
        identifier: String,
        title: String,
        body: String?,
        date: Date
    ) async -> String? {
        var hasAccess = isAuthorized
        if !hasAccess { hasAccess = await requestPermission() }
        guard hasAccess else { return nil }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body ?? ""
        content.sound = .default
        content.categoryIdentifier = Self.reminderCategoryIdentifier

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await addNotificationRequest(request)
            return identifier
        } catch {
            return nil
        }
    }

    private func scheduleImmediateNotification(
        identifier: String,
        title: String,
        body: String?
    ) async -> String? {
        var hasAccess = isAuthorized
        if !hasAccess { hasAccess = await requestPermission() }
        guard hasAccess else { return nil }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body ?? ""
        content.sound = .default
        content.categoryIdentifier = Self.reminderCategoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await addNotificationRequest(request)
            return identifier
        } catch {
            return nil
        }
    }

    private func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, any Error>) in
            notificationCenter.requestAuthorization(options: options) { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    private func addNotificationRequest(_ request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            notificationCenter.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
