// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/ViewModels/ExamViewModel.swift

import Foundation
import Combine

class ExamViewModel: ObservableObject {
    @Published var currentExam: Exam?
    @Published var currentQuestionIndex: Int = 0
    @Published var userAnswers: [Int: Int] = [:]  // questionId: selectedOption
    @Published var isExamActive: Bool = false
    @Published var shouldShowResults: Bool = false  // New property for navigation control
    @Published var startTime: Date?
    @Published var elapsedTime: TimeInterval = 0
    @Published var timer: Timer?
    @Published var completedExam: CompletedExam?
    
    // Flag to indicate if the exam was resumed from an in-progress state
    @Published var isResumedExam: Bool = false
    
    var currentQuestion: Question? {
        guard let exam = currentExam, currentQuestionIndex < exam.questions.count else {
            return nil
        }
        return exam.questions[currentQuestionIndex]
    }
    
    func startExam(exam: Exam) {
        self.currentExam = exam
        self.currentQuestionIndex = 0
        self.userAnswers = [:]
        self.isExamActive = true
        self.shouldShowResults = false
        self.startTime = Date()
        self.completedExam = nil
        
        // Start the timer
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    func selectAnswer(questionId: Int, optionIndex: Int) {
        userAnswers[questionId] = optionIndex
        print("Resposta selecionada: Questão \(questionId), Opção \(optionIndex)")
    }
    
    func moveToNextQuestion() {
        if let exam = currentExam, currentQuestionIndex < exam.questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    func moveToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    // Modified finishExam() using the actual number of questions
    func finishExam() -> CompletedExam? {
        guard let exam = currentExam, let startTime = startTime else {
            print("❌ Não foi possível finalizar o exame: exame ou tempo de início nulos")
            return nil
        }
        
        timer?.invalidate()
        timer = nil
        isExamActive = false
        
        let endTime = Date()
        var answers: [UserAnswer] = []
        var correctAnswers = 0
        var answeredQuestions = 0
        
        // Usar a contagem real de questões do exame
        let actualQuestionCount = exam.questions.count
        print("📊 Calculando resultado para \(actualQuestionCount) questões")
        
        for question in exam.questions {
            if let selectedOption = userAnswers[question.id] {
                answeredQuestions += 1
                let isCorrect = question.isNullified || selectedOption == question.correctOption
                if isCorrect {
                    correctAnswers += 1
                }
                
                let answer = UserAnswer(
                    questionId: question.id,
                    selectedOption: selectedOption,
                    isCorrect: isCorrect,
                    examId: exam.id,
                    timestamp: endTime
                )
                answers.append(answer)
                
                print("Questão \(question.id): Resposta \(selectedOption), Correta: \(isCorrect)")
            }
        }
        
        // Calcular pontuação usando a contagem real de questões
        let score = actualQuestionCount > 0 ? Double(correctAnswers) / Double(actualQuestionCount) * 100.0 : 0
        print("✅ Exame finalizado: \(correctAnswers)/\(actualQuestionCount) acertos, Score: \(score)%")
        print("Questões respondidas: \(answeredQuestions) de \(actualQuestionCount)")
        
        let completed = CompletedExam(
            examId: exam.id,
            startTime: startTime,
            endTime: endTime,
            answers: answers,
            score: score,
            actualQuestionCount: actualQuestionCount
        )
        
        self.completedExam = completed
        NotificationCenter.default.post(name: Notification.Name("examCompleted"), object: completed)
        self.shouldShowResults = true
        return completed
    }
    
    // MARK: - Methods for in-progress exams
    
    func loadInProgressExam(inProgressExam: InProgressExam, exam: Exam) {
        self.currentExam = exam
        self.currentQuestionIndex = inProgressExam.currentQuestionIndex
        self.userAnswers = inProgressExam.userAnswers
        self.isExamActive = true
        self.startTime = Date().addingTimeInterval(-inProgressExam.elapsedTime)
        self.elapsedTime = inProgressExam.elapsedTime
        self.isResumedExam = true
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    func saveProgressAndExit() -> InProgressExam {
        timer?.invalidate()
        timer = nil
        isExamActive = false
        
        let inProgressExam = InProgressExam(
            examId: currentExam?.id ?? "",
            startTime: startTime ?? Date(),
            elapsedTime: elapsedTime,
            currentQuestionIndex: currentQuestionIndex,
            userAnswers: userAnswers
        )
        
        return inProgressExam
    }
    
    // MARK: - Método para verificar se a resposta está correta (Feedback Háptico)
    func isAnswerCorrect(questionId: Int, optionIndex: Int) -> Bool {
        guard let exam = currentExam,
              let question = exam.questions.first(where: { $0.id == questionId }) else {
            return false
        }
        return question.isNullified || question.correctOption == optionIndex
    }
}
