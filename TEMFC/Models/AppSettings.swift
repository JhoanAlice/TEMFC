import Foundation
import SwiftUI

struct AppSettings: Codable, Equatable {
    // Aparência
    var isDarkModeEnabled: Bool
    var colorTheme: ColorTheme
    
    // Som e Vibração
    var soundEnabled: Bool
    var hapticFeedbackEnabled: Bool
    
    // Notificações
    var dailyReminderEnabled: Bool
    var dailyReminderTime: Date
    
    // Comportamento do app
    var automaticallyContinueQuizzes: Bool
    var showCorrectAnswerImmediately: Bool
    var showConfettiOnCorrectAnswer: Bool
    
    // Opções de estudo
    var defaultQuizSize: Int
    
    enum ColorTheme: String, Codable, CaseIterable {
        case blue = "Azul"
        case green = "Verde"
        case purple = "Roxo"
        case orange = "Laranja"
        
        var primaryColor: Color {
            switch self {
            case .blue: return Color(red: 0.0, green: 0.478, blue: 1.0)
            case .green: return Color(red: 0.0, green: 0.8, blue: 0.6)
            case .purple: return Color(red: 0.6, green: 0.0, blue: 0.9)
            case .orange: return Color(red: 1.0, green: 0.6, blue: 0.0)
            }
        }
        
        var secondaryColor: Color {
            switch self {
            case .blue: return Color(red: 0.25, green: 0.54, blue: 0.89)
            case .green: return Color(red: 0.3, green: 0.7, blue: 0.5)
            case .purple: return Color(red: 0.5, green: 0.3, blue: 0.8)
            case .orange: return Color(red: 0.9, green: 0.5, blue: 0.2)
            }
        }
    }
    
    init(isDarkModeEnabled: Bool = false,
         colorTheme: ColorTheme = .blue,
         soundEnabled: Bool = true,
         hapticFeedbackEnabled: Bool = true,
         dailyReminderEnabled: Bool = false,
         dailyReminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(),
         automaticallyContinueQuizzes: Bool = true,
         showCorrectAnswerImmediately: Bool = true,
         showConfettiOnCorrectAnswer: Bool = true,
         defaultQuizSize: Int = 10) {
        self.isDarkModeEnabled = isDarkModeEnabled
        self.colorTheme = colorTheme
        self.soundEnabled = soundEnabled
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.dailyReminderEnabled = dailyReminderEnabled
        self.dailyReminderTime = dailyReminderTime
        self.automaticallyContinueQuizzes = automaticallyContinueQuizzes
        self.showCorrectAnswerImmediately = showCorrectAnswerImmediately
        self.showConfettiOnCorrectAnswer = showConfettiOnCorrectAnswer
        self.defaultQuizSize = defaultQuizSize
    }
}
