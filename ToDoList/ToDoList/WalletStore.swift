import Foundation
import Combine

class WalletStore: ObservableObject {
    private let key = "savedWalletItems"
    
    @Published var items: [WalletItem] = [] {
        didSet { save() }
    }
    
    init() { load() }
    
    // MARK: - CRUD
    func add(_ item: WalletItem) { items.append(item) }
    func delete(_ item: WalletItem) { items.removeAll { $0.id == item.id } }
    
    // MARK: - Computed
    var totalSaldo: Double { totalIncome - totalExpense }
    var totalIncome: Double { items.filter { $0.type == .income }.reduce(0) { $0 + $1.amount } }
    var totalExpense: Double { items.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount } }
    
    var sortedItems: [WalletItem] { items.sorted { $0.date > $1.date } }
    
    func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return "Rp \(formatter.string(from: NSNumber(value: value)) ?? "0")"
    }
    
    // MARK: - Persistence
    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([WalletItem].self, from: data)
        else { return }
        items = decoded
    }
}
