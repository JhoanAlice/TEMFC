import Foundation

struct CompletedExam: Identifiable, Codable {
    var id = UUID()
    var examId: String
    var startTime: Date
    var endTime: Date
    var answers: [UserAnswer]
    var score: Double
    
    var timeSpent: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
}
