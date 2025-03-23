import Foundation

// Tipos de eventos de análise
enum AnalyticsEventType: String {
    case appOpen = "app_open"
    case appClose = "app_close"
    case examStarted = "exam_started"
    case examCompleted = "exam_completed"
    case examCancelled = "exam_cancelled"
    case questionAnswered = "question_answered"
    case studySessionStarted = "study_session_started"
    case studySessionCompleted = "study_session_completed"
    case userRegistered = "user_registered"
    case userProfileUpdated = "user_profile_updated"
    case settingsChanged = "settings_changed"
    case featureUsed = "feature_used"
}

// Serviço de análise para rastreamento de eventos
class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {
        // Inicialização privada para singleton
    }
    
    // Função para registrar eventos
    func logEvent(_ eventType: AnalyticsEventType, parameters: [String: Any]? = nil) {
        // Para uso futuro com Firebase ou outro serviço de análise
        
        // Por enquanto, apenas registra no console para debug
        #if DEBUG
        var logMessage = "Analytics: \(eventType.rawValue)"
        if let parameters = parameters {
            logMessage += " - Parameters: \(parameters)"
        }
        print(logMessage)
        #endif
    }
    
    // Log de evento de início de exame
    func logExamStarted(examId: String, examType: String) {
        logEvent(.examStarted, parameters: [
            "exam_id": examId,
            "exam_type": examType
        ])
    }
    
    // Log de evento de conclusão de exame
    func logExamCompleted(examId: String, score: Double, timeSpent: TimeInterval) {
        logEvent(.examCompleted, parameters: [
            "exam_id": examId,
            "score": score,
            "time_spent": timeSpent
        ])
    }
    
    // Log de resposta de questão
    func logQuestionAnswered(questionId: Int, isCorrect: Bool, timeSpent: TimeInterval) {
        logEvent(.questionAnswered, parameters: [
            "question_id": questionId,
            "is_correct": isCorrect,
            "time_spent": timeSpent
        ])
    }
    
    // Log de evento de usuário
    func logUserActivity(action: String, details: [String: Any]? = nil) {
        var parameters: [String: Any] = ["action": action]
        if let details = details {
            parameters.merge(details) { (_, new) in new }
        }
        
        logEvent(.featureUsed, parameters: parameters)
    }
}
