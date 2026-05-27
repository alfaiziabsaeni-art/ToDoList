import SwiftUI
import Combine

struct FocusView: View {
    @State private var timeRemaining: Int = 25 * 60
    @State private var isActive = false
    @State private var isBreak = false
    @State private var totalTime: Int = 25 * 60
    
    @State private var showSettings = false
    @State private var pomodoroMinutes: Int = 25
    @State private var breakMinutes: Int = 5
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var progress: CGFloat {
        totalTime == 0 ? 0 : 1.0 - (CGFloat(timeRemaining) / CGFloat(totalTime))
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            // Background elegan dengan warna pastel
            LinearGradient(
                gradient: Gradient(colors: [Color.cream, isBreak ? Color.blue.opacity(0.1) : Color.sageLight.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isBreak ? "Waktu Istirahat" : "Mode Fokus")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                        Text(isBreak ? "Relaksasikan pikiranmu sejenak." : "Fokus penuh, hindari distraksi.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 22))
                            .foregroundColor(.sage)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)
                
                Spacer()
                
                // Timer Circle
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 28)
                        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: isBreak ? [Color.blue.opacity(0.5), Color.blue] : [Color.sageLight, Color.sage]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 28, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: progress)
                    
                    VStack(spacing: 8) {
                        Text(timeString)
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                            .contentTransition(.numericText())
                        
                        Text(isActive ? "Sedang berjalan..." : "Siap dimulai")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                }
                .frame(width: 300, height: 300)
                
                Spacer()
                
                // Controls
                HStack(spacing: 36) {
                    Button {
                        resetTimer()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.textSecondary)
                                .frame(width: 60, height: 60)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                            Text("Reset")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            isActive.toggle()
                        }
                    } label: {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white)
                            .frame(width: 88, height: 88)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: isBreak ? [Color.blue.opacity(0.7), Color.blue] : [Color.sage.opacity(0.8), Color.sage]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: isBreak ? Color.blue.opacity(0.4) : Color.sage.opacity(0.4), radius: 16, x: 0, y: 8)
                    }
                    .offset(y: -15) // Highlight main button
                    
                    Button {
                        withAnimation {
                            isBreak.toggle()
                            applySettings()
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: isBreak ? "book.fill" : "cup.and.saucer.fill")
                                .font(.system(size: 22))
                                .foregroundColor(isBreak ? .sage : .blue)
                                .frame(width: 60, height: 60)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                            Text(isBreak ? "Fokus" : "Istirahat")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(isBreak ? .sage : .blue)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onReceive(timer) { _ in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isActive = false
                // Bisa ditambahkan notifikasi lokal di sini saat waktu habis
            }
        }
        .sheet(isPresented: $showSettings) {
            TimerSettingsView(pomodoroMinutes: $pomodoroMinutes, breakMinutes: $breakMinutes) {
                applySettings()
            }
        }
        .onAppear {
            if !isActive && timeRemaining == 25 * 60 {
                applySettings() // Inisialisasi awal
            }
        }
    }
    
    private func applySettings() {
        isActive = false
        let mins = isBreak ? breakMinutes : pomodoroMinutes
        totalTime = mins * 60
        timeRemaining = totalTime
    }
    
    private func resetTimer() {
        isActive = false
        timeRemaining = totalTime
    }
}

struct TimerSettingsView: View {
    @Binding var pomodoroMinutes: Int
    @Binding var breakMinutes: Int
    var onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Waktu Fokus"), footer: Text("Disarankan 25-50 menit untuk produktivitas maksimal.")) {
                    Stepper(value: $pomodoroMinutes, in: 1...120) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.sage)
                            Text("\(pomodoroMinutes) Menit")
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Section(header: Text("Waktu Istirahat"), footer: Text("Gunakan waktu ini untuk peregangan otot atau minum air.")) {
                    Stepper(value: $breakMinutes, in: 1...60) {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                                .foregroundColor(.blue)
                            Text("\(breakMinutes) Menit")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .navigationTitle("Atur Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simpan") {
                        onSave()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.sage)
                }
            }
        }
    }
}

struct FocusView_Previews: PreviewProvider {
    static var previews: some View {
        FocusView()
    }
}
