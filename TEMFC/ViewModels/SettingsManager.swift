import Foundation
import SwiftUI
import Combine
import UserNotifications

class SettingsManager: ObservableObject {
    @Published var settings: AppSettings
    private let userDefaultsKey = "appSettings"
    
    init() {
        // Carrega as configurações dos UserDefaults, ou cria um conjunto padrão
        if let settingsData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSettings = try? JSONDecoder().decode(AppSettings.self, from: settingsData) {
            self.settings = decodedSettings
        } else {
            self.settings = AppSettings()
        }
        
        // Configurar atualizações de tema e notificações quando mudar a configuração
        updateAppAppearance()
    }
    
    func saveSettings() {
        if let encodedData = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
        
        // Atualizar aparência e notificações
        updateAppAppearance()
        updateDailyReminders()
    }
    
    private func updateAppAppearance() {
        // Definir o tema do app (em implementações reais, você precisaria usar UIKit para isso)
        // No SwiftUI moderno, seria melhor usar o .preferredColorScheme em views de nível superior
    }
    
    func updateDailyReminders() {
        let center = UNUserNotificationCenter.current()
        
        // Remover notificações existentes
        center.removeAllPendingNotificationRequests()
        
        // Se as notificações estiverem desativadas, sair
        guard settings.dailyReminderEnabled else { return }
        
        // Solicitar permissões, se necessário
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }
            
            DispatchQueue.main.async {
                // Criar a notificação diária
                let content = UNMutableNotificationContent()
                content.title = "Hora de estudar!"
                content.body = "Mantenha sua rotina de estudos e se prepare para o TEMFC."
                content.sound = .default
                
                // Extrair componentes de hora e minuto da data configurada
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: self.settings.dailyReminderTime)
                let minute = calendar.component(.minute, from: self.settings.dailyReminderTime)
                
                // Configurar o gatilho para a notificação diária
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                // Criar a solicitação de notificação
                let request = UNNotificationRequest(
                    identifier: "dailyReminder",
                    content: content,
                    trigger: trigger
                )
                
                // Adicionar a notificação
                center.add(request) { error in
                    if let error = error {
                        print("Erro ao agendar notificação: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func resetToDefaults() {
        settings = AppSettings()
        saveSettings()
    }
}
