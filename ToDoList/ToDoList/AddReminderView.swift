import SwiftUI

struct AddReminderView: View {
    @ObservedObject var store: ReminderStore
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var category: String = ""
    @State private var date: Date = Date().addingTimeInterval(3600)
    @State private var priority: Int = 2
    @State private var reminderOffset: TimeInterval = 0

    var isFormValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Detail Tugas
                Section(header: Text("Detail Tugas")) {
                    TextField("Judul Tugas (Contoh: PR Biologi)", text: $title)
                    TextField("Catatan tambahan (Opsional)", text: $note, axis: .vertical)
                        .lineLimit(2...5)
                }
                
                // MARK: - Mata Pelajaran
                Section(
                    header: Text("Mata Pelajaran / Kategori"),
                    footer: Text("Ketik langsung nama mata pelajaran atau biarkan kosong.")
                ) {
                    TextField("Ketik nama pelajaran...", text: $category)
                }

                // MARK: - Prioritas
                Section(header: Text("Tingkat Prioritas")) {
                    Picker("Prioritas", selection: $priority) {
                        Text("Rendah").tag(1)
                        Text("Sedang").tag(2)
                        Text("Tinggi").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .colorMultiply(.sage) // Memberikan nuansa warna tema
                }

                // MARK: - Tenggat Waktu (Deadline)
                Section(header: Text("Tenggat Waktu")) {
                    DatePicker(
                        "Pilih Tanggal & Waktu",
                        selection: $date,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .accentColor(.sage)
                }

                // MARK: - Notifikasi Pengingat
                Section(header: Text("Pengingat")) {
                    Picker("Ingatkan Saya", selection: $reminderOffset) {
                        Text("Saat Tenggat Waktu").tag(TimeInterval(0))
                        Text("15 Menit Sebelum").tag(TimeInterval(15 * 60))
                        Text("30 Menit Sebelum").tag(TimeInterval(30 * 60))
                        Text("1 Jam Sebelum").tag(TimeInterval(60 * 60))
                        Text("1 Hari Sebelum").tag(TimeInterval(24 * 60 * 60))
                    }
                }
            }
            .navigationTitle("Tugas Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simpan") {
                        save()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isFormValid ? .sage : .gray)
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private func save() {
        guard isFormValid else { return }
        
        let finalCategory = category.trimmingCharacters(in: .whitespaces)
        
        let item = ReminderItem(
            title: title.trimmingCharacters(in: .whitespaces),
            date: date,
            note: note.trimmingCharacters(in: .whitespaces),
            category: finalCategory.isEmpty ? "Lainnya" : finalCategory,
            priority: priority,
            isRecurring: false,
            reminderOffset: reminderOffset
        )
        store.add(item)
        dismiss()
    }
}

struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddReminderView(store: ReminderStore())
    }
}
