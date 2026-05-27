import Foundation

struct ReminderItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var note: String = ""
    var isDone: Bool = false
    
    // New Student Features
    var category: String = "Lainnya"
    var priority: Int = 2 // 1: Rendah, 2: Sedang, 3: Tinggi
    var isRecurring: Bool = false
    var reminderOffset: TimeInterval = 0 // 0 means at time of event, otherwise seconds before deadline

    var isOverdue: Bool {
        !isDone && date < Date()
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
