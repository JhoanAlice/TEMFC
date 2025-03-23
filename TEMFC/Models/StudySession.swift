import Foundation

struct StudySession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var duration: TimeInterval
    var tags: [String]
    var questionsCount: Int
    var correctAnswers: Int
    
    var score: Double {
        guard questionsCount > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsCount) * 100.0
    }
}
