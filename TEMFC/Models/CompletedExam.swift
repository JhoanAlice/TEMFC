import Foundation

struct CompletedExam: Identifiable, Codable {
    var id = UUID()
    var examId: String
    var startTime: Date
    var endTime: Date
    var answers: [UserAnswer]
    var score: Double
    var actualQuestionCount: Int // Nova propriedade
    
    var timeSpent: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    // Inicializador com inicialização padrão para retrocompatibilidade
    init(
        id: UUID = UUID(),
        examId: String,
        startTime: Date,
        endTime: Date,
        answers: [UserAnswer],
        score: Double,
        actualQuestionCount: Int? = nil // Parâmetro opcional para compatibilidade
    ) {
        self.id = id
        self.examId = examId
        self.startTime = startTime
        self.endTime = endTime
        self.answers = answers
        self.score = score
        // Se actualQuestionCount não for fornecido, use o número de respostas
        self.actualQuestionCount = actualQuestionCount ?? answers.count
    }
}
