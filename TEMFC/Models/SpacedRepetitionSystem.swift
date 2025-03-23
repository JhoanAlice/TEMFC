import Foundation

// Sistema de repetição espaçada baseado no algoritmo SM-2
class SpacedRepetitionSystem {
    // Constantes para o algoritmo
    private let minEaseFactor: Double = 1.3
    private let defaultEaseFactor: Double = 2.5
    
    // Função para calcular o próximo intervalo de revisão
    func calculateNextReview(previousInterval: Int, easeFactor: Double, quality: Int) -> (nextInterval: Int, newEaseFactor: Double) {
        // Qualidade de resposta: 0 = ruim, 5 = perfeito
        var nextEaseFactor = easeFactor
        
        // Atualização do fator de facilidade
        nextEaseFactor = max(minEaseFactor, easeFactor + (0.1 - (5 - Double(quality)) * (0.08 + (5 - Double(quality)) * 0.02)))
        
        // Cálculo do próximo intervalo
        let nextInterval: Int
        
        if quality < 3 {
            // Repetir a questão no mesmo dia
            nextInterval = 1
        } else if previousInterval == 0 {
            // Primeira revisão
            nextInterval = 1
        } else if previousInterval == 1 {
            // Segunda revisão
            nextInterval = 6
        } else {
            // Próximas revisões
            nextInterval = Int(Double(previousInterval) * nextEaseFactor)
        }
        
        return (nextInterval, nextEaseFactor)
    }
    
    // Função para determinar quais questões devem ser revisadas hoje
    func questionsForReview(studyItems: [StudyItem]) -> [StudyItem] {
        let today = Calendar.current.startOfDay(for: Date())
        
        return studyItems.filter { item in
            if let nextReviewDate = item.nextReviewDate {
                return Calendar.current.compare(nextReviewDate, to: today, toGranularity: .day) != .orderedDescending
            }
            return true // Se não houver data de revisão, incluir para revisão
        }
    }
}

// Estrutura para itens de estudo com repetição espaçada
struct StudyItem: Identifiable, Codable {
    let id: UUID
    let questionId: Int
    let examId: String
    var interval: Int // Intervalo atual em dias
    var easeFactor: Double // Fator de facilidade
    var nextReviewDate: Date? // Próxima data de revisão
    var reviewHistory: [ReviewRecord] // Histórico de revisões
    
    init(questionId: Int, examId: String) {
        self.id = UUID()
        self.questionId = questionId
        self.examId = examId
        self.interval = 0
        self.easeFactor = 2.5 // Valor padrão
        self.nextReviewDate = Date() // Hoje
        self.reviewHistory = []
    }
}

// Registro de uma revisão
struct ReviewRecord: Codable {
    let date: Date
    let quality: Int // 0-5
}
