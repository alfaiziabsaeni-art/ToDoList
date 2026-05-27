import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            print("Notification permission granted: \(granted)")
        }
    }

    // MARK: - Schedule

    func schedule(_ reminder: ReminderItem) {
        // Don't schedule if date is in the past or already done
        guard reminder.date > Date(), !reminder.isDone else { return }

        let content = UNMutableNotificationContent()
        content.title = "⏰ Pengingat"
        content.body = reminder.title
        content.sound = .default

        if !reminder.note.isEmpty {
            content.subtitle = reminder.note
        }

        // Calculate the actual notification time (deadline - offset)
        let notifyDate = reminder.date.addingTimeInterval(-reminder.reminderOffset)
        
        // Don't schedule if the notification time is in the past
        guard notifyDate > Date() else { return }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notifyDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Cancel

    func cancel(_ id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [id.uuidString]
        )
    }
}
