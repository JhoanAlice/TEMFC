// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFCTests/MockDataManager.swift

import Foundation
@testable import TEMFC

// Criamos um data manager totalmente novo para testes
// Em vez de herdar de DataManager, implementamos apenas o necessário
class MockDataManager {
    var exams: [Exam] = []
    var completedExams: [CompletedExam] = []
    var inProgressExams: [InProgressExam] = []
    var isLoadingData: Bool = false
    var lastUpdated: Date = Date()
    
    private var favoriteQuestions: Set<Int> = []
    
    init() {
        // Inicializa com dados de teste
        exams = createMockExams()
    }
    
    func loadAndProcessExams(completion: (() -> Void)? = nil) {
        exams = createMockExams()
        isLoadingData = false
        completion?()
    }
    
    private func createMockExams() -> [Exam] {
        let sampleQuestions = [
            Question(
                id: 1,
                number: 1,
                statement: "Questão de teste 1",
                options: ["A - Opção A", "B - Opção B", "C - Opção C", "D - Opção D"],
                correctOption: 0,
                explanation: "Explicação da questão 1",
                tags: ["Tag1", "Tag2"]
            ),
            Question(
                id: 2,
                number: 2,
                statement: "Questão de teste 2",
                options: ["A - Opção A", "B - Opção B", "C - Opção C", "D - Opção D"],
                correctOption: 1,
                explanation: "Explicação da questão 2",
                tags: ["Tag1", "Tag3"]
            ),
            Question(
                id: 3,
                number: 3,
                statement: "Questão anulada",
                options: ["A - Opção A", "B - Opção B", "C - Opção C", "D - Opção D"],
                correctOption: nil,
                explanation: "Esta questão foi anulada",
                tags: ["Tag2", "Tag3"]
            )
        ]
        
        let exam1 = Exam(
            id: "TEST1",
            name: "Exame de Teste 1",
            type: .theoretical,
            questions: [sampleQuestions[0], sampleQuestions[1]]
        )
        
        let exam2 = Exam(
            id: "TEST2",
            name: "Exame de Teste 2",
            type: .theoretical_practical,
            questions: [sampleQuestions[0], sampleQuestions[2]]
        )
        
        return [exam1, exam2]
    }
    
    func saveCompletedExam(_ exam: CompletedExam) {
        completedExams.append(exam)
        lastUpdated = Date()
    }
    
    // Métodos para favoritos
    func addToFavorites(questionId: Int) {
        favoriteQuestions.insert(questionId)
    }
    
    func removeFromFavorites(questionId: Int) {
        favoriteQuestions.remove(questionId)
    }
    
    func isFavorite(questionId: Int) -> Bool {
        return favoriteQuestions.contains(questionId)
    }
    
    func resetFavorites() {
        favoriteQuestions.removeAll()
    }
    
    // Implementamos outros métodos conforme necessário para testes
    func getExam(id: String) -> Exam? {
        return exams.first { $0.id == id }
    }
    
    func getExamsByType(type: Exam.ExamType) -> [Exam] {
        return exams.filter { $0.type == type }
    }
    
    func getCompletedExamsByType(type: Exam.ExamType) -> [CompletedExam] {
        let examIds = exams.filter { $0.type == type }.map { $0.id }
        return completedExams.filter { examIds.contains($0.examId) }
    }
}
