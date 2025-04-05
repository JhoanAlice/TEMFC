// TEMFC/Models/Exam.swift

import Foundation

/// Represents an exam containing questions
struct Exam: Identifiable, Codable, Equatable {
    /// Unique identifier for the exam
    var id: String
    
    /// Display name for the exam
    var name: String
    
    /// Type of the exam (theoretical or theoretical-practical)
    var type: ExamType
    
    /// Total number of questions in the exam
    var totalQuestions: Int
    
    /// Array of questions in the exam
    var questions: [Question]
    
    /// Optional year the exam was administered 
    var year: String?
    
    // MARK: - Exam Type
    
    /// Represents the type of exam
    enum ExamType: String, Codable, CaseIterable {
        /// Theoretical exam (multiple choice)
        case theoretical = "Teórica"
        
        /// Theoretical-practical exam (case-based)
        case theoretical_practical = "Teórico-Prática"
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            
            switch rawValue {
            case "Teórica":
                self = .theoretical
            case "Teórico-Prática":
                self = .theoretical_practical
            default:
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot initialize ExamType from invalid String value \(rawValue)"
                )
            }
        }
        
        /// A user-friendly display name for the exam type (used in UI)
        var displayName: String {
            switch self {
            case .theoretical:
                return "Teórica"
            case .theoretical_practical:
                return "Teórico-Prática"
            }
        }
        
        /// A shortened display name for space-constrained UIs
        var shortName: String {
            switch self {
            case .theoretical:
                return "Teórica"
            case .theoretical_practical:
                return "T. Prática"
            }
        }
        
        /// Icon name to be used with this exam type
        var iconName: String {
            switch self {
            case .theoretical:
                return "doc.text.fill"
            case .theoretical_practical:
                return "video.fill"
            }
        }
    }
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, totalQuestions, questions, year
    }
    
    // MARK: - Initializers
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(ExamType.self, forKey: .type)
        questions = try container.decode([Question].self, forKey: .questions)
        year = try container.decodeIfPresent(String.self, forKey: .year)
        
        // If totalQuestions is present, use it, otherwise calculate automatically
        if let definedTotal = try? container.decode(Int.self, forKey: .totalQuestions) {
            totalQuestions = definedTotal
        } else {
            totalQuestions = questions.count
        }
    }
    
    init(id: String, 
         name: String, 
         type: ExamType, 
         totalQuestions: Int? = nil, 
         questions: [Question],
         year: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.questions = questions
        self.totalQuestions = totalQuestions ?? questions.count
        self.year = year
    }
    
    // MARK: - Computed Properties
    
    /// Returns a set of unique tags across all questions in the exam
    var uniqueTags: Set<String> {
        return Set(questions.flatMap { $0.tags })
    }
    
    /// Returns the number of completed questions (for UI display)
    func completedQuestionsCount(userAnswers: [Int: Int]) -> Int {
        return questions.filter { userAnswers[$0.id] != nil }.count
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Exam, rhs: Exam) -> Bool {
        return lhs.id == rhs.id
    }
}