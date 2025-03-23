import Foundation
import Combine

class ExamViewModel: ObservableObject {
    @Published var currentExam: Exam?
    @Published var currentQuestionIndex: Int = 0
    @Published var userAnswers: [Int: Int] = [:]  // questionId: selectedOption
    @Published var isExamActive: Bool = false
    @Published var startTime: Date?
    @Published var elapsedTime: TimeInterval = 0
    @Published var timer: Timer?
    @Published var completedExam: CompletedExam?
    
    // Flag para verificar se o exame foi carregado de um estado em andamento
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
        self.startTime = Date()
        self.completedExam = nil
        
        // Inicia o timer
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
    
    func finishExam() -> CompletedExam? {
        guard let exam = currentExam, let startTime = startTime else {
            print("Não foi possível finalizar o exame: exame ou tempo de início nulos")
            return nil
        }
        
        timer?.invalidate()
        timer = nil
        isExamActive = false
        
        let endTime = Date()
        var answers: [UserAnswer] = []
        var correctAnswers = 0
        var answeredQuestions = 0
        
        print("Calculando resultado para \(exam.questions.count) questões")
        
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
        
        let score = exam.totalQuestions > 0 ? Double(correctAnswers) / Double(exam.totalQuestions) * 100.0 : 0
        print("Exame finalizado: \(correctAnswers)/\(exam.questions.count) acertos, Score: \(score)%")
        print("Questões respondidas: \(answeredQuestions) de \(exam.totalQuestions)")
        
        let completed = CompletedExam(
            examId: exam.id,
            startTime: startTime,
            endTime: endTime,
            answers: answers,
            score: score
        )
        
        self.completedExam = completed
        return completed
    }
    
    // MARK: - Métodos para carregar e salvar progresso (exames em andamento)
    
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
