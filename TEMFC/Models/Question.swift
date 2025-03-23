import Foundation

struct Question: Identifiable, Codable {
    var id: Int
    var number: Int
    var statement: String
    var options: [String]
    var correctOption: Int?
    var explanation: String
    var tags: [String]
    var videoUrl: String?
    
    // Fornecendo um valor padrão para tags, caso não estejam presentes no JSON
    enum CodingKeys: String, CodingKey {
        case id, number, statement, options, correctOption, explanation, tags, videoUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        number = try container.decode(Int.self, forKey: .number)
        statement = try container.decode(String.self, forKey: .statement)
        options = try container.decode([String].self, forKey: .options)
        correctOption = try container.decodeIfPresent(Int.self, forKey: .correctOption)
        explanation = try container.decode(String.self, forKey: .explanation)
        videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        
        // Se não houver tags, use um array vazio
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }
    
    // Inicializador padrão para criação direta
    init(id: Int, number: Int, statement: String, options: [String], correctOption: Int?, explanation: String, tags: [String], videoUrl: String? = nil) {
        self.id = id
        self.number = number
        self.statement = statement
        self.options = options
        self.correctOption = correctOption
        self.explanation = explanation
        self.tags = tags
        self.videoUrl = videoUrl
    }
    
    var isNullified: Bool {
        return correctOption == nil
    }
}
