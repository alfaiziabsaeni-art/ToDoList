import SwiftUI

// MARK: - Warna Tema
extension Color {
    // Tema Pastel Premium
    static let cream = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let sage = Color(red: 0.38, green: 0.52, blue: 0.45)
    static let sageLight = Color(red: 0.88, green: 0.93, blue: 0.90)
    static let cardBg = Color.white
    static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.55)
    static let overdue = Color(red: 0.95, green: 0.35, blue: 0.4)
    static let highlight = Color(red: 1.0, green: 0.7, blue: 0.3)
}

// MARK: - Main Tab View
struct ContentView: View {
    @StateObject private var store = ReminderStore()
    
    var body: some View {
        TabView {
            TasksView(store: store)
                .tabItem {
                    Label("Tugas", systemImage: "list.bullet.rectangle.portrait.fill")
                }
            
            FocusView()
                .tabItem {
                    Label("Fokus", systemImage: "timer")
                }
            
            WalletView()
                .tabItem {
                    Label("Dompet", systemImage: "creditcard.fill")
                }
        }
        .accentColor(.sage)
        // Memaksa mode terang agar teks putih di simulator (dark mode) tidak tabrakan dengan background pastel
        .preferredColorScheme(.light) 
    }
}

// MARK: - Tasks View
struct TasksView: View {
    @ObservedObject var store: ReminderStore
    @State private var showAdd = false
    @State private var isAnimating = false

    var progress: Double {
        let total = store.reminders.count
        guard total > 0 else { return 0 }
        let done = store.done.count
        return Double(done) / Double(total)
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // Background dengan Ornamen Estetik
                ZStack {
                    Color.cream.ignoresSafeArea()
                    
                    // Ornamen Lingkaran Abstrak
                    Circle()
                        .fill(Color.sageLight.opacity(0.5))
                        .frame(width: 350, height: 350)
                        .offset(x: 180, y: -250)
                        .blur(radius: 40)
                    
                    Circle()
                        .fill(Color.highlight.opacity(0.15))
                        .frame(width: 250, height: 250)
                        .offset(x: -150, y: -350)
                        .blur(radius: 30)
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Header Motivasi & Progress Bar
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Halo, Pelajar Hebat! 👋")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundColor(.textPrimary)
                            
                            Text(store.upcoming.isEmpty ? "Semua tugas beres. Waktunya bersantai!" : "Ada \(store.upcoming.count) tugas menanti. Kamu pasti bisa menyelesaikannya!")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.textSecondary)
                                .lineSpacing(4)
                            
                            // Progress Bar
                            if !store.reminders.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Progres Hari Ini")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.sage)
                                        Spacer()
                                        Text("\(Int(progress * 100))%")
                                            .font(.system(size: 14, weight: .heavy))
                                            .foregroundColor(.sage)
                                    }
                                    
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.sageLight)
                                                .frame(height: 12)
                                            
                                            Capsule()
                                                .fill(
                                                    LinearGradient(gradient: Gradient(colors: [.sage, .highlight]), startPoint: .leading, endPoint: .trailing)
                                                )
                                                .frame(width: max(0, geo.size.width * CGFloat(progress)), height: 12)
                                                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
                                        }
                                    }
                                    .frame(height: 12)
                                }
                                .padding(.top, 16)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 30)
                        .padding(.bottom, 10)

                        if store.reminders.isEmpty {
                            EmptyStateView()
                                .padding(.top, 40)
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                // — Mendatang
                                if !store.upcoming.isEmpty {
                                    SectionLabel(title: "🔥 Harus Dikerjakan", count: store.upcoming.count)
                                        .padding(.horizontal, 24)
                                    VStack(spacing: 16) {
                                        ForEach(store.upcoming) { item in
                                            ReminderCard(item: item, store: store)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }

                                // — Selesai
                                if !store.done.isEmpty {
                                    SectionLabel(title: "✅ Selesai (Mantap!)", count: store.done.count)
                                        .padding(.top, store.upcoming.isEmpty ? 0 : 36)
                                        .padding(.horizontal, 24)
                                    VStack(spacing: 16) {
                                        ForEach(store.done) { item in
                                            ReminderCard(item: item, store: store)
                                                .opacity(0.65) // Pudar untuk yang sudah selesai
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.bottom, 130)
                        }
                    }
                }

                // — FAB dengan Efek Animasi Pulse
                Button {
                    showAdd = true
                } label: {
                    ZStack {
                        // Pulse Effect
                        Circle()
                            .fill(Color.sage.opacity(0.2))
                            .frame(width: isAnimating ? 85 : 60, height: isAnimating ? 85 : 60)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Circle()
                            .fill(Color.sage.opacity(0.4))
                            .frame(width: isAnimating ? 72 : 60, height: isAnimating ? 72 : 60)
                            .animation(.easeInOut(duration: 1.5).delay(0.2).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.sage, Color(red: 0.25, green: 0.40, blue: 0.30)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.sage.opacity(0.6), radius: 14, x: 0, y: 8)
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
                .onAppear {
                    isAnimating = true
                }
            }
            .navigationBarHidden(true) // Sembunyikan navigasi bawaan karena kita pakai header kustom
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showAdd) {
            AddReminderView(store: store)
        }
        .onAppear {
            NotificationManager.shared.requestPermission()
        }
    }
}

// MARK: - Section Label
struct SectionLabel: View {
    let title: String
    let count: Int

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(.textPrimary)
            Text("\(count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(minWidth: 22, minHeight: 22)
                .background(Color.sage)
                .clipShape(Circle())
        }
        .padding(.bottom, 14)
    }
}

// MARK: - Reminder Card
struct ReminderCard: View {
    let item: ReminderItem
    let store: ReminderStore

    var body: some View {
        HStack(spacing: 16) {
            // Checkbox dengan efek per pada saat di tap
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    store.toggle(item)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(item.isDone ? Color.sage : Color.sageLight.opacity(0.3))
                        .frame(width: 32, height: 32)
                    Circle()
                        .strokeBorder(item.isDone ? Color.sage : Color.sage.opacity(0.5), lineWidth: 2)
                        .frame(width: 32, height: 32)
                    if item.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // Info Tugas
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(item.isDone ? .textSecondary : .textPrimary)
                    .strikethrough(item.isDone, color: .textSecondary)
                    .lineLimit(2)

                if !item.note.isEmpty {
                    Text(item.note)
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }

                // Tags (Category & Priority & Time)
                HStack(spacing: 8) {
                    Text(item.category)
                        .font(.system(size: 11, weight: .heavy))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.sageLight.opacity(0.8))
                        .foregroundColor(.sage)
                        .cornerRadius(8)
                    
                    if item.priority == 3 {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))
                            Text("Tinggi")
                        }
                        .font(.system(size: 11, weight: .heavy))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.overdue.opacity(0.15))
                        .foregroundColor(.overdue)
                        .cornerRadius(8)
                    } else if item.priority == 1 {
                        Text("Santai")
                            .font(.system(size: 11, weight: .heavy))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.gray.opacity(0.15))
                            .foregroundColor(.gray)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Waktu
                    HStack(spacing: 4) {
                        Image(systemName: item.isOverdue ? "clock.fill" : "clock")
                            .font(.system(size: 11, weight: .bold))
                        Text(item.isOverdue ? "Terlewat" : item.formattedDate)
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(item.isOverdue ? .overdue : .textSecondary)
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .background(Color.cardBg)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    item.priority == 3 && !item.isDone ? Color.overdue.opacity(0.6) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    @State private var float = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.highlight.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .scaleEffect(float ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: float)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.highlight)
                    .offset(y: float ? -10 : 10)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: float)
            }
            .onAppear { float = true }
            
            Text("Wah, kosong!")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(.textPrimary)
            
            Text("Tidak ada tugas saat ini.\nKetuk tombol + di bawah untuk mulai membuat keajaiban hari ini!")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
