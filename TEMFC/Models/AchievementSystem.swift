// Caminho: /TEMFC/Models/AchievementSystem.swift

import Foundation

// Sistema de conquistas e gamificação
class AchievementSystem {
    static let shared = AchievementSystem()
    
    // Chave para UserDefaults
    private let achievementsKey = "userAchievements"
    
    // Lista de conquistas do usuário
    private(set) var unlockedAchievements: [Achievement] = []
    
    // Inicializar o sistema
    private init() {
        loadAchievements()
    }
    
    // Carregar conquistas salvas
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let achievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.unlockedAchievements = achievements
        }
    }
    
    // Salvar conquistas
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }
    
    // Verificar e conceder conquistas
    func checkAchievements(with dataManager: DataManager) {
        // Conquistas baseadas em número de exames completados
        let completedExams = dataManager.completedExams.count
        checkAndUnlockAchievement(.firstExam, if: completedExams >= 1)
        checkAndUnlockAchievement(.fiveExams, if: completedExams >= 5)
        checkAndUnlockAchievement(.tenExams, if: completedExams >= 10)
        checkAndUnlockAchievement(.twentyFiveExams, if: completedExams >= 25)
        
        // Conquistas baseadas em pontuações
        if let bestScore = dataManager.completedExams.map({ $0.score }).max() {
            checkAndUnlockAchievement(.sixtyPercentScore, if: bestScore >= 60)
            checkAndUnlockAchievement(.seventyPercentScore, if: bestScore >= 70)
            checkAndUnlockAchievement(.eightyPercentScore, if: bestScore >= 80)
            checkAndUnlockAchievement(.ninetyPercentScore, if: bestScore >= 90)
            checkAndUnlockAchievement(.perfectScore, if: bestScore == 100)
        }
        
        // Conquistas baseadas em categorias estudadas
        let studiedCategories = Set(dataManager.completedExams.flatMap { exam in
            exam.answers.compactMap { answer in
                dataManager.exams.flatMap { $0.questions }
                    .first(where: { $0.id == answer.questionId })?
                    .tags
            }.flatMap { $0 }
        })
        
        checkAndUnlockAchievement(.fiveCategories, if: studiedCategories.count >= 5)
        checkAndUnlockAchievement(.tenCategories, if: studiedCategories.count >= 10)
        checkAndUnlockAchievement(.allCategories, if: studiedCategories.count >= 15)
        
        // Conquista por estudo consistente (dias seguidos)
        let studyDates = dataManager.completedExams.map { Calendar.current.startOfDay(for: $0.endTime) }
        let uniqueDates = Set(studyDates)
        
        let calendar = Calendar.current
        var consecutiveDays = 0
        let today = calendar.startOfDay(for: Date())
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                if uniqueDates.contains(date) {
                    consecutiveDays += 1
                } else {
                    break
                }
            }
        }
        
        checkAndUnlockAchievement(.threeConsecutiveDays, if: consecutiveDays >= 3)
        checkAndUnlockAchievement(.sevenConsecutiveDays, if: consecutiveDays >= 7)
    }
    
    // Verificar e desbloquear uma conquista específica
    private func checkAndUnlockAchievement(_ achievement: Achievement.ID, if condition: Bool) {
        if condition && !isAchievementUnlocked(achievement) {
            let achievement = Achievement.allAchievements.first { $0.id == achievement }!
            unlockedAchievements.append(achievement)
            saveAchievements()
            
            // Notificar o usuário sobre a nova conquista
            NotificationCenter.default.post(
                name: .achievementUnlocked,
                object: achievement
            )
        }
    }
    
    // Verificar se uma conquista já foi desbloqueada
    func isAchievementUnlocked(_ achievementID: Achievement.ID) -> Bool {
        return unlockedAchievements.contains { $0.id == achievementID }
    }
    
    // Obter todas as conquistas (desbloqueadas e bloqueadas)
    func getAllAchievements() -> [Achievement] {
        return Achievement.allAchievements.map { achievement in
            if isAchievementUnlocked(achievement.id) {
                return achievement
            } else {
                var lockedAchievement = achievement
                lockedAchievement.isUnlocked = false
                return lockedAchievement
            }
        }
    }
}

// Extensão para notificação de conquista desbloqueada
extension Notification.Name {
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
}

// Modelo de Conquista
struct Achievement: Identifiable, Codable, Equatable {
    let id: ID
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool = true
    var unlockedDate: Date = Date()  // Changed from 'let' to 'var'
    
    // Identificadores de conquistas
    enum ID: String, Codable {
        // Baseadas em número de exames
        case firstExam
        case fiveExams
        case tenExams
        case twentyFiveExams
        
        // Baseadas em pontuação
        case sixtyPercentScore
        case seventyPercentScore
        case eightyPercentScore
        case ninetyPercentScore
        case perfectScore
        
        // Baseadas em categorias
        case fiveCategories
        case tenCategories
        case allCategories
        
        // Baseadas em consistência
        case threeConsecutiveDays
        case sevenConsecutiveDays
    }
    
    // Todas as conquistas disponíveis
    static let allAchievements: [Achievement] = [
        // Conquistas de exames
        Achievement(id: .firstExam, title: "Primeiro Passo", description: "Complete seu primeiro simulado", icon: "1.circle.fill"),
        Achievement(id: .fiveExams, title: "Dedicação", description: "Complete 5 simulados", icon: "5.circle.fill"),
        Achievement(id: .tenExams, title: "Persistência", description: "Complete 10 simulados", icon: "10.circle.fill"),
        Achievement(id: .twentyFiveExams, title: "Maratonista", description: "Complete 25 simulados", icon: "medal.fill"),
        
        // Conquistas de pontuação
        Achievement(id: .sixtyPercentScore, title: "Aprovado", description: "Alcance 60% ou mais em um simulado", icon: "checkmark.circle.fill"),
        Achievement(id: .seventyPercentScore, title: "Bom Desempenho", description: "Alcance 70% ou mais em um simulado", icon: "hand.thumbsup.fill"),
        Achievement(id: .eightyPercentScore, title: "Excelência", description: "Alcance 80% ou mais em um simulado", icon: "star.fill"),
        Achievement(id: .ninetyPercentScore, title: "Domínio", description: "Alcance 90% ou mais em um simulado", icon: "star.circle.fill"),
        Achievement(id: .perfectScore, title: "Perfeição", description: "Alcance 100% em um simulado", icon: "crown.fill"),
        
        // Conquistas de categorias
        Achievement(id: .fiveCategories, title: "Explorador", description: "Estude 5 áreas temáticas diferentes", icon: "folder.fill"),
        Achievement(id: .tenCategories, title: "Versátil", description: "Estude 10 áreas temáticas diferentes", icon: "folder.badge.plus"),
        Achievement(id: .allCategories, title: "Completo", description: "Estude todas as áreas temáticas", icon: "checkmark.seal.fill"),
        
        // Conquistas de consistência
        Achievement(id: .threeConsecutiveDays, title: "Constância", description: "Estude por 3 dias consecutivos", icon: "flame.fill"),
        Achievement(id: .sevenConsecutiveDays, title: "Disciplinado", description: "Estude por 7 dias consecutivos", icon: "sparkles")
    ]
    
    // Verificar se duas conquistas são iguais
    static func ==(lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.id == rhs.id
    }
}
