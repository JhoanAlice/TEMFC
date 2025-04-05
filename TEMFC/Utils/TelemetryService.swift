// Caminho: TEMFC/Utils/TelemetryService.swift

import Foundation
import UIKit

class TelemetryService {
    static let shared = TelemetryService()
    
    // Constantes para eventos de telemetria
    struct EventName {
        static let appOpen = "app_open"
        static let appClose = "app_close"
        static let viewScreen = "view_screen"
        static let startExam = "start_exam"
        static let finishExam = "finish_exam"
        static let answerQuestion = "answer_question"
        static let viewHelp = "view_help"
        static let changeSettings = "change_settings"
        static let exportData = "export_data"
        static let importData = "import_data"
        static let createCustomQuiz = "create_custom_quiz"
        static let viewPerformance = "view_performance"
        static let memoryWarning = "memory_warning"
        static let appError = "app_error"
        static let featureUse = "feature_use"
    }
    
    // Informações sobre a sessão atual
    private var sessionStartTime: Date = Date()
    private var screenViewTimes: [String: TimeInterval] = [:]
    private var currentScreen: String?
    
    private init() {
        sessionStartTime = Date()
        setupObservers()
    }
    
    private func setupObservers() {
        // Monitorar ciclo de vida do aplicativo
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        
        // Monitorar avisos de memória
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc func appDidBecomeActive() {
        let params: [String: Any] = [
            "session_id": UUID().uuidString,
            "session_start": sessionStartTime.timeIntervalSince1970
        ]
        logAppEvent(EventName.appOpen, parameters: params)
    }
    
    @objc func appWillResignActive() {
        let sessionDuration = Date().timeIntervalSince(sessionStartTime)
        let params: [String: Any] = [
            "session_duration": sessionDuration
        ]
        logAppEvent(EventName.appClose, parameters: params)
    }
    
    @objc func appDidEnterBackground() {
        // Calcular tempo total de sessão
        let sessionDuration = Date().timeIntervalSince(sessionStartTime)
        let params: [String: Any] = [
            "session_duration": sessionDuration,
            "current_screen": currentScreen ?? "unknown"
        ]
        logAppEvent("app_background", parameters: params)
    }
    
    @objc func appWillTerminate() {
        // Calcular duração total da sessão
        let sessionDuration = Date().timeIntervalSince(sessionStartTime)
        let params: [String: Any] = [
            "session_duration": sessionDuration,
            "screen_view_times": screenViewTimes
        ]
        logAppEvent("app_terminate", parameters: params)
    }
    
    @objc func didReceiveMemoryWarning() {
        let params: [String: Any] = [
            "free_memory": getDeviceMemoryInfo(),
            "current_screen": currentScreen ?? "unknown"
        ]
        logAppEvent(EventName.memoryWarning, parameters: params)
    }
    
    // Função para obter informações sobre a memória do dispositivo
    private func getDeviceMemoryInfo() -> [String: Any] {
        var memoryInfo: [String: Any] = [:]
        
        // Em produção, usaríamos as APIs do sistema para obter informações reais de memória
        memoryInfo["device_model"] = UIDevice.current.model
        memoryInfo["system_version"] = UIDevice.current.systemVersion
        
        return memoryInfo
    }
    
    func logAppEvent(_ event: String, parameters: [String: Any]? = nil) {
        var eventParams: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "device_model": UIDevice.current.model,
            "os_version": UIDevice.current.systemVersion
        ]
        
        if let additionalParams = parameters {
            eventParams.merge(additionalParams) { (_, new) in new }
        }
        
        AnalyticsService.shared.logEvent(.featureUsed, parameters: [
            "action": event,
            "details": eventParams
        ])
        
        print("📊 Telemetry: \(event)")
    }
    
    // Registra a visualização de uma tela, com métricas de tempo
    func logScreenView(_ screenName: String) {
        // Se estávamos em outra tela, registre o tempo de permanência
        if let lastScreen = currentScreen, let startTime = screenViewTimes[lastScreen] {
            let duration = Date().timeIntervalSince1970 - startTime
            screenViewTimes[lastScreen] = duration
            
            // Log da duração na tela anterior
            logAppEvent("screen_exit", parameters: [
                "screen": lastScreen,
                "duration": duration
            ])
        }
        
        // Atualizar tela atual e hora de início
        currentScreen = screenName
        screenViewTimes[screenName] = Date().timeIntervalSince1970
        
        // Log de entrada na nova tela
        logAppEvent(EventName.viewScreen, parameters: ["screen": screenName])
    }
    
    // Registra uma ação do usuário com detalhes
    func logUserAction(_ action: String, in screen: String, details: [String: Any]? = nil) {
        var params: [String: Any] = [
            "screen": screen,
            "action": action
        ]
        
        if let actionDetails = details {
            params.merge(actionDetails) { (_, new) in new }
        }
        
        logAppEvent(EventName.featureUse, parameters: params)
    }
    
    // Funções específicas para eventos importantes
    
    func logExamStarted(examId: String, examType: String) {
        let params: [String: Any] = [
            "exam_id": examId,
            "exam_type": examType,
            "start_time": Date().timeIntervalSince1970
        ]
        logAppEvent(EventName.startExam, parameters: params)
    }
    
    func logExamCompleted(examId: String, examType: String, score: Double, duration: TimeInterval, questionsAnswered: Int) {
        let params: [String: Any] = [
            "exam_id": examId,
            "exam_type": examType,
            "score": score,
            "duration": duration,
            "questions_answered": questionsAnswered,
            "completion_time": Date().timeIntervalSince1970
        ]
        logAppEvent(EventName.finishExam, parameters: params)
    }
    
    func logQuestionAnswered(examId: String, questionId: Int, isCorrect: Bool, timeSpent: TimeInterval) {
        let params: [String: Any] = [
            "exam_id": examId,
            "question_id": questionId,
            "is_correct": isCorrect,
            "time_spent": timeSpent
        ]
        logAppEvent(EventName.answerQuestion, parameters: params)
    }
    
    func logSettingsChanged(setting: String, oldValue: Any, newValue: Any) {
        let params: [String: Any] = [
            "setting": setting,
            "old_value": String(describing: oldValue),
            "new_value": String(describing: newValue),
            "timestamp": Date().timeIntervalSince1970
        ]
        logAppEvent(EventName.changeSettings, parameters: params)
    }
    
    func logError(_ error: Error, context: String) {
        let params: [String: Any] = [
            "error_type": String(describing: type(of: error)),
            "error_message": error.localizedDescription,
            "context": context,
            "screen": currentScreen ?? "unknown"
        ]
        logAppEvent(EventName.appError, parameters: params)
    }
}
