// TEMFC/Models/InProgressExam.swift

import Foundation

struct InProgressExam: Codable, Identifiable {
    var id = UUID()
    var examId: String
    var startTime: Date
    var elapsedTime: TimeInterval
    var currentQuestionIndex: Int
    var userAnswers: [Int: Int] // questionId: selectedOption
    
    static func from(viewModel: ExamViewModel) -> InProgressExam {
        return InProgressExam(
            examId: viewModel.currentExam?.id ?? "",
            startTime: viewModel.startTime ?? Date(),
            elapsedTime: viewModel.elapsedTime,
            currentQuestionIndex: viewModel.currentQuestionIndex,
            userAnswers: viewModel.userAnswers
        )
    }
}
