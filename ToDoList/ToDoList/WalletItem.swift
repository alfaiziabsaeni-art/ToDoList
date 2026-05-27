import Foundation

enum WalletType: String, Codable, CaseIterable {
    case income = "Pemasukan"
    case expense = "Pengeluaran"
}

struct WalletItem: Identifiable, Codable {
    var id: UUID = UUID()
    var amount: Double
    var label: String
    var type: WalletType
    var date: Date = Date()
    var emoji: String = ""
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "0"
        return "Rp \(formatted)"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
