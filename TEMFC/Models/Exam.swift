import Foundation

struct Exam: Identifiable, Codable {
    var id: String
    var name: String
    var type: ExamType
    var totalQuestions: Int
    var questions: [Question]
    
    enum ExamType: String, Codable, CaseIterable {
        case theoretical = "Teórica"
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
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, totalQuestions, questions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(ExamType.self, forKey: .type)
        questions = try container.decode([Question].self, forKey: .questions)
        
        // Verificar se totalQuestions está presente, senão calcular automaticamente
        if let definedTotal = try? container.decode(Int.self, forKey: .totalQuestions) {
            totalQuestions = definedTotal
        } else {
            totalQuestions = questions.count
        }
    }
    
    // Inicializador padrão
    init(id: String, name: String, type: ExamType, totalQuestions: Int? = nil, questions: [Question]) {
        self.id = id
        self.name = name
        self.type = type
        self.questions = questions
        self.totalQuestions = totalQuestions ?? questions.count
    }
}
