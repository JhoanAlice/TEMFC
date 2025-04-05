// TEMFC/Models/Question.swift

import Foundation

/// Represents a question in an exam
struct Question: Identifiable, Codable, Equatable {
    /// Unique identifier for the question
    let id: Int
    
    /// Question number as displayed to the user
    let number: Int
    
    /// The text content of the question
    let statement: String
    
    /// Array of answer options
    let options: [String]
    
    /// Index of the correct option, nil if the question is nullified
    let correctOption: Int?
    
    /// Explanation of the correct answer
    let explanation: String
    
    /// Category tags for the question
    let tags: [String]
    
    /// Optional URL to a video explanation
    let videoUrl: String?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id, number, statement, options, correctOption, explanation, tags, videoUrl
    }
    
    // MARK: - Initializers
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        number = try container.decode(Int.self, forKey: .number)
        statement = try container.decode(String.self, forKey: .statement)
        options = try container.decode([String].self, forKey: .options)
        correctOption = try container.decodeIfPresent(Int.self, forKey: .correctOption)
        explanation = try container.decode(String.self, forKey: .explanation)
        videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        
        // Default to empty array if tags not present
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }
    
    init(id: Int, 
         number: Int, 
         statement: String, 
         options: [String], 
         correctOption: Int?, 
         explanation: String, 
         tags: [String] = [], 
         videoUrl: String? = nil) {
        self.id = id
        self.number = number
        self.statement = statement
        self.options = options
        self.correctOption = correctOption
        self.explanation = explanation
        self.tags = tags
        self.videoUrl = videoUrl
    }
    
    // MARK: - Computed Properties
    
    /// Returns true if the question has been nullified (no correct answer)
    var isNullified: Bool {
        return correctOption == nil
    }
    
    /// Returns the option letter (A, B, C, etc.) for a given index
    func letterForOption(at index: Int) -> String {
        guard index >= 0 && index < options.count else { return "?" }
        return String(UnicodeScalar(65 + index)!)
    }
    
    /// Returns the correct option letter or "N/A" if nullified
    var correctOptionLetter: String {
        guard let correctOption = correctOption else { return "N/A" }
        return letterForOption(at: correctOption)
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id
    }
}