import Foundation
import SwiftUI

struct User: Codable, Identifiable {
    var id = UUID()
    var name: String
    var email: String
    var specialization: Specialization
    var graduationYear: Int
    var profileImage: Data?
    var createdAt: Date
    
    enum Specialization: String, Codable, CaseIterable {
        case resident = "Residência MFC"
        case specialist = "Especialista MFC"
        case generalPractitioner = "Médico(a) Generalista"
        case student = "Estudante de Medicina"
        case other = "Outra especialidade"
    }
    
    init(name: String = "",
         email: String = "",
         specialization: Specialization = .resident,
         graduationYear: Int = Calendar.current.component(.year, from: Date()),
         profileImage: Data? = nil,
         createdAt: Date = Date()) {
        self.name = name
        self.email = email
        self.specialization = specialization
        self.graduationYear = graduationYear
        self.profileImage = profileImage
        self.createdAt = createdAt
    }
    
    // Computed property to provide a formatted display name
    var displayName: String {
        if name.isEmpty {
            return "Usuário TEMFC"
        }
        
        // Extract first name for a more personal touch
        let components = name.components(separatedBy: " ")
        return components.first ?? name
    }
    
    // Get user's professional description
    var professionalDescription: String {
        switch specialization {
        case .resident:
            let yearsOfPractice = Calendar.current.component(.year, from: Date()) - graduationYear
            return "Residente em MFC • \(yearsOfPractice) ano\(yearsOfPractice != 1 ? "s" : "") de prática"
        case .specialist:
            return "Especialista em MFC • Desde \(graduationYear)"
        case .generalPractitioner:
            return "Médico(a) Generalista • Formado(a) em \(graduationYear)"
        case .student:
            return "Estudante de Medicina • Turma \(graduationYear)"
        case .other:
            return "Profissional de Saúde • Desde \(graduationYear)"
        }
    }
}
