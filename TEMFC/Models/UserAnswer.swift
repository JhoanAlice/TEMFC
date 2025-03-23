import Foundation

struct UserAnswer: Identifiable, Codable {
    var id = UUID()
    var questionId: Int
    var selectedOption: Int
    var isCorrect: Bool
    var examId: String
    var timestamp: Date
}
