import Foundation
import SwiftUI

struct AppSettings: Codable, Equatable {
    // Appearance
    var isDarkModeEnabled: Bool
    var colorTheme: ColorTheme
    
    // Sound and Vibration
    var soundEnabled: Bool
    var hapticFeedbackEnabled: Bool
    
    // Notifications
    var dailyReminderEnabled: Bool
    var dailyReminderTime: Date
    
    // Quiz Behavior
    var automaticallyContinueQuizzes: Bool
    var showCorrectAnswerImmediately: Bool
    var showConfettiOnCorrectAnswer: Bool
    var randomizeQuestionOrder: Bool // New option
    
    // Study Options
    var defaultQuizSize: Int
    var studySessionDuration: Int // New: Study session duration in minutes
    var favoriteCategories: [String] // New: User's favorite categories
    var useSpacedRepetition: Bool // New: Whether to use spaced repetition
    
    // New: Theme Options
    var useDynamicTypeSize: Bool
    var isReduceMotionEnabled: Bool
    
    enum ColorTheme: String, Codable, CaseIterable {
        case blue = "Azul"
        case green = "Verde"
        case purple = "Roxo"
        case orange = "Laranja"
        case red = "Vermelho"   // New color
        case teal = "Turquesa"  // New color
        
        var primaryColor: Color {
            switch self {
            case .blue: return Color(red: 0.0, green: 0.478, blue: 1.0)
            case .green: return Color(red: 0.0, green: 0.8, blue: 0.6)
            case .purple: return Color(red: 0.6, green: 0.0, blue: 0.9)
            case .orange: return Color(red: 1.0, green: 0.6, blue: 0.0)
            case .red: return Color(red: 0.9, green: 0.2, blue: 0.3)
            case .teal: return Color(red: 0.0, green: 0.7, blue: 0.7)
            }
        }
        
        var secondaryColor: Color {
            switch self {
            case .blue: return Color(red: 0.25, green: 0.54, blue: 0.89)
            case .green: return Color(red: 0.3, green: 0.7, blue: 0.5)
            case .purple: return Color(red: 0.5, green: 0.3, blue: 0.8)
            case .orange: return Color(red: 0.9, green: 0.5, blue: 0.2)
            case .red: return Color(red: 0.8, green: 0.3, blue: 0.4)
            case .teal: return Color(red: 0.2, green: 0.6, blue: 0.6)
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
         randomizeQuestionOrder: Bool = false,
         defaultQuizSize: Int = 10,
         studySessionDuration: Int = 30,
         favoriteCategories: [String] = [],
         useSpacedRepetition: Bool = true,
         useDynamicTypeSize: Bool = true,
         isReduceMotionEnabled: Bool = false) {
        
        self.isDarkModeEnabled = isDarkModeEnabled
        self.colorTheme = colorTheme
        self.soundEnabled = soundEnabled
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.dailyReminderEnabled = dailyReminderEnabled
        self.dailyReminderTime = dailyReminderTime
        self.automaticallyContinueQuizzes = automaticallyContinueQuizzes
        self.showCorrectAnswerImmediately = showCorrectAnswerImmediately
        self.showConfettiOnCorrectAnswer = showConfettiOnCorrectAnswer
        self.randomizeQuestionOrder = randomizeQuestionOrder
        self.defaultQuizSize = defaultQuizSize
        self.studySessionDuration = studySessionDuration
        self.favoriteCategories = favoriteCategories
        self.useSpacedRepetition = useSpacedRepetition
        self.useDynamicTypeSize = useDynamicTypeSize
        self.isReduceMotionEnabled = isReduceMotionEnabled
    }
}
