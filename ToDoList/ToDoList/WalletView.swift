import SwiftUI

struct WalletView: View {
    @StateObject private var store = WalletStore()
    @State private var showAdd = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.cream.ignoresSafeArea()
                
                // Ornamen background
                Circle()
                    .fill(Color.green.opacity(0.06))
                    .frame(width: 400)
                    .offset(x: 150, y: -300)
                    .blur(radius: 50)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - Kartu Saldo Utama
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.18, green: 0.55, blue: 0.40),
                                            Color(red: 0.10, green: 0.40, blue: 0.55)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.sage.opacity(0.5), radius: 20, x: 0, y: 10)
                            
                            // Ornamen lingkaran di dalam kartu
                            Circle()
                                .fill(Color.white.opacity(0.07))
                                .frame(width: 200)
                                .offset(x: 100, y: -60)
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 140)
                                .offset(x: -90, y: 60)
                            
                            VStack(spacing: 16) {
                                Text("💰 Total Saldo")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(store.formattedCurrency(store.totalSaldo))
                                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider().background(Color.white.opacity(0.3)).padding(.vertical, 4)
                                
                                HStack(spacing: 0) {
                                    // Pemasukan
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.down.circle.fill")
                                                .foregroundColor(.green.opacity(0.9))
                                            Text("Pemasukan")
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        Text(store.formattedCurrency(store.totalIncome))
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                    
                                    // Pengeluaran
                                    VStack(alignment: .trailing, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.up.circle.fill")
                                                .foregroundColor(.red.opacity(0.9))
                                            Text("Pengeluaran")
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        Text(store.formattedCurrency(store.totalExpense))
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(28)
                        }
                        .frame(height: 220)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // MARK: - Daftar Transaksi
                        VStack(alignment: .leading, spacing: 14) {
                            if store.sortedItems.isEmpty {
                                WalletEmptyState()
                                    .padding(.top, 40)
                            } else {
                                HStack {
                                    Text("Riwayat Transaksi")
                                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    Text("\(store.items.count) transaksi")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.textSecondary)
                                }
                                .padding(.horizontal, 20)
                                
                                ForEach(store.sortedItems) { item in
                                    WalletCard(item: item) {
                                        withAnimation { store.delete(item) }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.bottom, 120)
                    }
                }
                
                // FAB
                Button { showAdd = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.18, green: 0.55, blue: 0.40), Color(red: 0.10, green: 0.40, blue: 0.55)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.sage.opacity(0.5), radius: 14, x: 0, y: 8)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Dompet Saku")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.light)
        .sheet(isPresented: $showAdd) {
            AddWalletItemView(store: store)
        }
    }
}

// MARK: - Wallet Card
struct WalletCard: View {
    let item: WalletItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Ikon Tipe
            ZStack {
                Circle()
                    .fill(item.type == .income ? Color.green.opacity(0.15) : Color.red.opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: item.type == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(item.type == .income ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.label)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                Text(item.formattedDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text((item.type == .income ? "+" : "-") + item.formattedAmount)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(item.type == .income ? .green : .red)
                
                Button { onDelete() } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Empty State
struct WalletEmptyState: View {
    @State private var floating = false
    var body: some View {
        VStack(spacing: 16) {
            Text("💸")
                .font(.system(size: 70))
                .offset(y: floating ? -10 : 10)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floating)
                .onAppear { floating = true }
            
            Text("Belum ada transaksi")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.textPrimary)
            
            Text("Catat uang masuk & keluar\nhari ini dengan menekan tombol +")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Add Wallet Item View
struct AddWalletItemView: View {
    @ObservedObject var store: WalletStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var label: String = ""
    @State private var amountText: String = ""
    @State private var type: WalletType = .expense
    @State private var date: Date = Date()
    
    var amount: Double { Double(amountText) ?? 0 }
    var isValid: Bool { !label.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0 }
    
    let quickLabels: [String: [String]] = [
        "Pemasukan": ["Uang Saku", "Beasiswa", "Hadiah", "Bayaran Kerja", "Lainnya"],
        "Pengeluaran": ["Makan", "Transportasi", "Jajan", "Beli Buku", "Fotokopi", "Pulsa", "Lainnya"]
    ]
    
    var currentLabels: [String] {
        quickLabels[type.rawValue] ?? []
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Tipe
                Section(header: Text("Jenis Transaksi")) {
                    Picker("Tipe", selection: $type) {
                        ForEach(WalletType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Label Cepat
                Section(header: Text("Label Cepat")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(currentLabels, id: \.self) { quick in
                                Text(quick)
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(label == quick ? Color.sage : Color.sageLight.opacity(0.5))
                                    .foregroundColor(label == quick ? .white : .textPrimary)
                                    .cornerRadius(16)
                                    .onTapGesture { label = quick }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Keterangan
                Section(header: Text("Keterangan")) {
                    TextField("Nama transaksi...", text: $label)
                }
                
                // Nominal
                Section(header: Text("Nominal (Rp)"), footer: Text("Masukkan angka saja tanpa titik atau koma.")) {
                    TextField("Contoh: 25000", text: $amountText)
                        .keyboardType(.numberPad)
                }
                
                // Tanggal
                Section(header: Text("Tanggal")) {
                    DatePicker("Tanggal", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle(type == .income ? "Tambah Pemasukan" : "Tambah Pengeluaran")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") { dismiss() }.foregroundColor(.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simpan") {
                        let item = WalletItem(amount: amount, label: label.trimmingCharacters(in: .whitespaces), type: type, date: date)
                        store.add(item)
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isValid ? .sage : .gray)
                    .disabled(!isValid)
                }
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
