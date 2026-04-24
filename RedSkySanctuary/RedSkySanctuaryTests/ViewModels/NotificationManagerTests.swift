import Foundation
import Testing
import UserNotifications

@testable import RedSkySanctuary

@MainActor
@Suite("NotificationManager Tests")
struct NotificationManagerTests {

    @Test("requestPermission updates authorization state and registers actions")
    func requestPermissionFlow() async {
        let center = MockUserNotificationCenter()
        let manager = NotificationManager(notificationCenter: center, calendar: fixedCalendar)

        let granted = await manager.requestPermission()

        #expect(granted == true)
        #expect(manager.isAuthorized == true)
        #expect(center.requestAuthorizationCallCount == 1)
        #expect(center.requestedOptions == [.alert, .badge, .sound])
        #expect(center.categories.count == 1)
        #expect(center.categories.first?.actions.first?.identifier == NotificationManager.markCompleteActionIdentifier)
    }

    @Test("scheduleReminder creates a calendar trigger for the reminder date")
    func scheduleReminderCreatesExpectedTrigger() async throws {
        let center = MockUserNotificationCenter()
        let manager = NotificationManager(notificationCenter: center, calendar: fixedCalendar)
        manager.isAuthorized = true
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let reminder = Reminder(title: "Check hay delivery", notes: "Call supplier", date: date)

        let identifier = await manager.scheduleReminder(reminder)

        #expect(identifier == reminder.notificationIdentifier)
        #expect(center.addedRequests.count == 1)

        let request = try #require(center.addedRequests.first)
        #expect(request.content.title == "Check hay delivery")
        #expect(request.content.body == "Call supplier")
        #expect(request.content.categoryIdentifier == NotificationManager.reminderCategoryIdentifier)

        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(trigger.repeats == false)
        #expect(trigger.nextTriggerDate() == date)
    }

    @Test("scheduleReminder requests permission when first scheduling a reminder")
    func scheduleReminderRequestsPermissionWhenNeeded() async {
        let center = MockUserNotificationCenter()
        let manager = NotificationManager(notificationCenter: center, calendar: fixedCalendar)
        let reminder = Reminder(title: "Trim goat hooves", date: Date(timeIntervalSince1970: 1_700_050_000))

        let identifier = await manager.scheduleReminder(reminder)

        #expect(identifier == reminder.notificationIdentifier)
        #expect(center.requestAuthorizationCallCount == 1)
        #expect(manager.isAuthorized == true)
        #expect(center.addedRequests.count == 1)
    }

    @Test("cancelNotification removes the pending identifier")
    func cancelNotificationRemovesPendingRequest() {
        let center = MockUserNotificationCenter()
        let manager = NotificationManager(notificationCenter: center, calendar: fixedCalendar)

        manager.cancelNotification(identifier: "reminder-123")

        #expect(center.removedIdentifiers == ["reminder-123"])
    }

    @Test("scheduleVetVisitReminder uses nextVisitDate when present")
    func scheduleVetVisitReminder() async throws {
        let center = MockUserNotificationCenter()
        let manager = NotificationManager(notificationCenter: center, calendar: fixedCalendar)
        manager.isAuthorized = true
        let nextVisitDate = Date(timeIntervalSince1970: 1_700_100_000)
        let record = HealthRecord(recordType: RecordType.vetVisit, title: "Spring vaccines", nextVisitDate: nextVisitDate)

        let identifier = await manager.scheduleVetVisitReminder(for: record)

        #expect(identifier == "vet-\(record.id.uuidString)")

        let request = try #require(center.addedRequests.first)
        #expect(request.identifier == "vet-\(record.id.uuidString)")
        #expect(request.content.title == "Vet Visit Reminder")
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(trigger.nextTriggerDate() == nextVisitDate)
    }

    @Test("scheduleMaintenanceReminder uses nextDueDate when present")
    func scheduleMaintenanceReminder() async throws {
        let center = MockUserNotificationCenter()
        let manager = NotificationManager(notificationCenter: center, calendar: fixedCalendar)
        manager.isAuthorized = true
        let nextDueDate = Date(timeIntervalSince1970: 1_700_200_000)
        let task = MaintenanceTask(title: "Inspect perimeter fence", nextDueDate: nextDueDate)

        let identifier = await manager.scheduleMaintenanceReminder(for: task)

        #expect(identifier == "maintenance-\(task.id.uuidString)")

        let request = try #require(center.addedRequests.first)
        #expect(request.identifier == "maintenance-\(task.id.uuidString)")
        #expect(request.content.title == "Maintenance Reminder")
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(trigger.nextTriggerDate() == nextDueDate)
    }
}

private let fixedCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
}()

private final class MockUserNotificationCenter: UserNotificationCenterProtocol, @unchecked Sendable {
    var authorizationGranted = true
    var requestAuthorizationCallCount = 0
    var requestedOptions: UNAuthorizationOptions = []
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    var categories: Set<UNNotificationCategory> = []

    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping @Sendable (Bool, (any Error)?) -> Void) {
        requestAuthorizationCallCount += 1
        requestedOptions = options
        completionHandler(authorizationGranted, nil)
    }

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: (@Sendable ((any Error)?) -> Void)?) {
        addedRequests.append(request)
        completionHandler?(nil)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers = identifiers
    }

    func setNotificationCategories(_ categories: Set<UNNotificationCategory>) {
        self.categories = categories
    }
}
