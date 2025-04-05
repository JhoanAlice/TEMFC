// TEMFC/ViewModels/ExamViewModel.swift

import Foundation
import Combine

/// View model for managing exam sessions
final class ExamViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var currentExam: Exam?
    @Published var currentQuestionIndex: Int = 0
    @Published private(set) var userAnswers: [Int: Int] = [:]  // questionId: selectedOption
    @Published var isExamActive: Bool = false
    @Published var shouldShowResults: Bool = false
    @Published private(set) var startTime: Date?
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published var completedExam: CompletedExam?
    @Published var isResumedExam: Bool = false
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    
    // MARK: - Computed Properties
    
    /// The current question being displayed
    var currentQuestion: Question? {
        guard let exam = currentExam, currentQuestionIndex < exam.questions.count else {
            return nil
        }
        return exam.questions[currentQuestionIndex]
    }
    
    /// Formatted elapsed time string (MM:SS)
    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Percentage of questions answered
    var progressPercentage: Double {
        guard let exam = currentExam, !exam.questions.isEmpty else { return 0 }
        return Double(userAnswers.count) / Double(exam.questions.count)
    }
    
    // MARK: - Exam Control Methods
    
    /// Starts a new exam session
    /// - Parameter exam: The exam to start
    func startExam(exam: Exam) {
        self.currentExam = exam
        self.currentQuestionIndex = 0
        self.userAnswers = [:]
        self.isExamActive = true
        self.shouldShowResults = false
        self.startTime = Date()
        self.completedExam = nil
        
        startTimer()
        
        // Log telemetry for exam start
        TelemetryService.shared.logExamStarted(
            examId: exam.id,
            examType: exam.type.rawValue
        )
    }
    
    /// Records an answer for a question
    /// - Parameters:
    ///   - questionId: The ID of the question being answered
    ///   - optionIndex: The index of the selected option
    func selectAnswer(questionId: Int, optionIndex: Int) {
        userAnswers[questionId] = optionIndex
        
        // Log telemetry for question answered
        if let exam = currentExam {
            let isCorrect = isAnswerCorrect(questionId: questionId, optionIndex: optionIndex)
            let timeSpent = elapsedTime // Current overall time (ideally we'd track per-question time)
            
            TelemetryService.shared.logQuestionAnswered(
                examId: exam.id,
                questionId: questionId,
                isCorrect: isCorrect,
                timeSpent: timeSpent
            )
        }
    }
    
    /// Navigates to the next question if available
    func moveToNextQuestion() {
        if let exam = currentExam, currentQuestionIndex < exam.questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    /// Navigates to the previous question if available
    func moveToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    /// Completes the exam and calculates the final score
    /// - Returns: A CompletedExam object with the results, or nil if the exam cannot be finished
    func finishExam() -> CompletedExam? {
        guard let exam = currentExam, let startTime = startTime else {
            print("❌ Error: Cannot finish exam: exam or start time is nil")
            return nil
        }
        
        stopTimer()
        isExamActive = false
        
        let endTime = Date()
        let answers = createUserAnswers(for: exam, at: endTime)
        let (score, _, answeredQuestions) = calculateScore(for: exam, with: answers)
        
        let completed = CompletedExam(
            examId: exam.id,
            startTime: startTime,
            endTime: endTime,
            answers: answers,
            score: score,
            actualQuestionCount: exam.questions.count
        )
        
        self.completedExam = completed
        NotificationCenter.default.post(name: .examCompleted, object: completed)
        self.shouldShowResults = true
        
        // Log telemetry for exam completion
        TelemetryService.shared.logExamCompleted(
            examId: exam.id,
            examType: exam.type.rawValue,
            score: score,
            duration: endTime.timeIntervalSince(startTime),
            questionsAnswered: answeredQuestions
        )
        
        return completed
    }
    
    // MARK: - In-Progress Exam Methods
    
    /// Loads an in-progress exam to continue
    /// - Parameters:
    ///   - inProgressExam: The saved exam state
    ///   - exam: The full exam data
    func loadInProgressExam(inProgressExam: InProgressExam, exam: Exam) {
        self.currentExam = exam
        self.currentQuestionIndex = inProgressExam.currentQuestionIndex
        self.userAnswers = inProgressExam.userAnswers
        self.isExamActive = true
        self.startTime = Date().addingTimeInterval(-inProgressExam.elapsedTime)
        self.elapsedTime = inProgressExam.elapsedTime
        self.isResumedExam = true
        
        startTimer()
    }
    
    /// Saves the current progress and exits the exam
    /// - Returns: An InProgressExam object with the current state
    func saveProgressAndExit() -> InProgressExam {
        stopTimer()
        isExamActive = false
        
        return InProgressExam(
            examId: currentExam?.id ?? "",
            startTime: startTime ?? Date(),
            elapsedTime: elapsedTime,
            currentQuestionIndex: currentQuestionIndex,
            userAnswers: userAnswers
        )
    }
    
    // MARK: - Helper Methods
    
    /// Checks if a selected answer is correct
    /// - Parameters:
    ///   - questionId: The question ID
    ///   - optionIndex: The selected option index
    /// - Returns: True if the answer is correct
    func isAnswerCorrect(questionId: Int, optionIndex: Int) -> Bool {
        guard let exam = currentExam,
              let question = exam.questions.first(where: { $0.id == questionId }) else {
            return false
        }
        return question.isNullified || (question.correctOption != nil && question.correctOption == optionIndex)
    }
    
    /// Returns the number of correctly answered questions
    var correctAnswersCount: Int {
        guard let exam = currentExam else { return 0 }
        
        var count = 0
        for question in exam.questions {
            if let selectedOption = userAnswers[question.id],
               question.isNullified || (question.correctOption != nil && selectedOption == question.correctOption) {
                count += 1
            }
        }
        return count
    }
    
    // MARK: - Private Helper Methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Testing Methods
    
    /// Define o tempo decorrido manualmente (usado apenas para testes)
    /// - Parameter time: O tempo decorrido em segundos
    #if DEBUG
    func setElapsedTimeForTesting(_ time: TimeInterval) {
        self.elapsedTime = time
    }
    #endif
    
    private func createUserAnswers(for exam: Exam, at endTime: Date) -> [UserAnswer] {
        var answers: [UserAnswer] = []
        
        for question in exam.questions {
            guard let selectedOption = userAnswers[question.id] else { continue }
            
            let isCorrect = question.isNullified || 
                           (question.correctOption != nil && selectedOption == question.correctOption)
            
            let answer = UserAnswer(
                questionId: question.id,
                selectedOption: selectedOption,
                isCorrect: isCorrect,
                examId: exam.id,
                timestamp: endTime
            )
            answers.append(answer)
        }
        
        return answers
    }
    
    private func calculateScore(for exam: Exam, with answers: [UserAnswer]) -> (score: Double, correct: Int, answered: Int) {
        let totalQuestions = exam.questions.count
        let answeredQuestions = answers.count
        let correctAnswers = answers.filter { $0.isCorrect }.count
        
        // Calculate percentage score
        let score = totalQuestions > 0 ? 
            Double(correctAnswers) / Double(totalQuestions) * 100.0 : 0
        
        return (score, correctAnswers, answeredQuestions)
    }
}