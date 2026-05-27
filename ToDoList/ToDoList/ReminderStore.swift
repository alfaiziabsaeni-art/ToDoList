import Foundation
import Combine
import WidgetKit

class ReminderStore: ObservableObject {
    // Gunakan App Groups UserDefaults agar data bisa dibaca oleh Widget
    static let appGroupID = "group.com.faizganteng.ToDoList"
    private let key = "savedReminders"
    
    private var defaults: UserDefaults {
        // Fallback ke standard jika App Group belum dikonfigurasi (sebelum Widget Target dibuat)
        UserDefaults(suiteName: ReminderStore.appGroupID) ?? UserDefaults.standard
    }
    
    @Published var reminders: [ReminderItem] = [] {
        didSet {
            save()
            // Reload semua Widget timeline agar selalu up-to-date
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    init() {
        load()
    }

    // MARK: - CRUD

    func add(_ item: ReminderItem) {
        reminders.append(item)
        NotificationManager.shared.schedule(item)
    }

    func delete(_ item: ReminderItem) {
        NotificationManager.shared.cancel(item.id)
        reminders.removeAll { $0.id == item.id }
    }

    func delete(at offsets: IndexSet, from list: [ReminderItem]) {
        for index in offsets {
            delete(list[index])
        }
    }

    func toggle(_ item: ReminderItem) {
        guard let idx = reminders.firstIndex(where: { $0.id == item.id }) else { return }
        reminders[idx].isDone.toggle()
        if reminders[idx].isDone {
            NotificationManager.shared.cancel(item.id)
        } else {
            NotificationManager.shared.schedule(reminders[idx])
        }
    }

    // MARK: - Computed lists

    var upcoming: [ReminderItem] {
        reminders.filter { !$0.isDone }.sorted { $0.date < $1.date }
    }

    var done: [ReminderItem] {
        reminders.filter { $0.isDone }.sorted { $0.date > $1.date }
    }
    
    // Tugas prioritas tinggi yang belum selesai (untuk Widget)
    var widgetTasks: [ReminderItem] {
        reminders
            .filter { !$0.isDone }
            .sorted {
                if $0.priority != $1.priority { return $0.priority > $1.priority }
                return $0.date < $1.date
            }
            .prefix(3)
            .map { $0 }
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(reminders) {
            defaults.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ReminderItem].self, from: data)
        else { return }
        reminders = decoded
    }
}

