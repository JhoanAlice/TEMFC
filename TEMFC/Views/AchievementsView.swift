import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var achievements: [Achievement] = []
    @State private var showingUnlockedToast = false
    @State private var newlyUnlockedAchievement: Achievement?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Seção de conquistas desbloqueadas
                    if !unlockedAchievements.isEmpty {
                        AchievementSection(
                            title: "Conquistas Desbloqueadas",
                            achievements: unlockedAchievements
                        )
                    }
                    
                    // Seção de conquistas bloqueadas
                    if !lockedAchievements.isEmpty {
                        AchievementSection(
                            title: "Próximas Conquistas",
                            achievements: lockedAchievements
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Conquistas")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Verificar conquistas ao aparecer
                AchievementSystem.shared.checkAchievements(with: dataManager)
                loadAchievements()
                
                // Observar novas conquistas
                NotificationCenter.default.addObserver(
                    forName: .achievementUnlocked,
                    object: nil,
                    queue: .main
                ) { notification in
                    if let achievement = notification.object as? Achievement {
                        newlyUnlockedAchievement = achievement
                        showingUnlockedToast = true
                        loadAchievements()
                    }
                }
            }
            .overlay(
                Group {
                    if showingUnlockedToast, let achievement = newlyUnlockedAchievement {
                        VStack {
                            Spacer()
                            
                            // Toast de nova conquista
                            AchievementToast(achievement: achievement) {
                                withAnimation {
                                    showingUnlockedToast = false
                                }
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 20)
                        }
                        .onAppear {
                            // Fechar automaticamente após alguns segundos
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                withAnimation {
                                    showingUnlockedToast = false
                                }
                            }
                        }
                    }
                }
            )
        }
    }
    
    // Carregar todas as conquistas
    private func loadAchievements() {
        achievements = AchievementSystem.shared.getAllAchievements()
    }
    
    // Filtrar conquistas desbloqueadas
    private var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    // Filtrar conquistas bloqueadas
    private var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
}

// Seção de conquistas
struct AchievementSection: View {
    let title: String
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                ForEach(achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
        }
    }
}

// Card de conquista
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            // Ícone
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 30))
                    .foregroundColor(achievement.isUnlocked ? .blue : .gray)
            }
            
            // Título
            Text(achievement.title)
                .font(.headline)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
            
            // Descrição
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Data de desbloqueio
            if achievement.isUnlocked {
                Text(formattedDate(achievement.unlockedDate))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(height: 180)
        .background(achievement.isUnlocked ? Color(.secondarySystemBackground) : Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
        )
        .opacity(achievement.isUnlocked ? 1 : 0.7)
    }
    
    // Formatar data
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Toast de nova conquista
struct AchievementToast: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    @State private var showConfetti = true
    
    var body: some View {
        HStack(spacing: 16) {
            // Ícone
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            
            // Informações
            VStack(alignment: .leading, spacing: 4) {
                Text("Nova Conquista!")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Botão de fechar
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
            }
            .padding(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .overlay(
            Group {
                if showConfetti {
                    // Efeito de confete simples
                    ZStack {
                        ForEach(0..<20, id: \.self) { _ in
                            Circle()
                                .fill(Color.random)
                                .frame(width: 8, height: 8)
                                .position(
                                    x: CGFloat.random(in: -20...120),
                                    y: CGFloat.random(in: -100...0)
                                )
                                .onAppear {
                                    withAnimation(.linear(duration: 1)) {
                                        // Confetes caem para fora da tela
                                    }
                                }
                        }
                    }
                    .onAppear {
                        // Desativar confete após um tempo
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showConfetti = false
                        }
                    }
                }
            }
        )
    }
}

// Extensão para cor aleatória
extension Color {
    static var random: Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return colors.randomElement() ?? .blue
    }
}
