import SwiftUI

@main
struct TEMFCApp: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var userManager = UserManager()
    @StateObject private var settingsManager = SettingsManager()
    @State private var latestCompletedExam: CompletedExam?
    @State private var showLatestResult = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if !userManager.isLoggedIn {
                        WelcomeView()
                            .environmentObject(userManager)
                            .environmentObject(settingsManager)
                    } else {
                        SplashScreenView()
                            .environmentObject(dataManager)
                            .environmentObject(userManager)
                            .environmentObject(settingsManager)
                            .preferredColorScheme(settingsManager.settings.isDarkModeEnabled ? .dark : .light)
                    }
                }
                
                if showLatestResult, let exam = latestCompletedExam {
                    NavigationView {
                        ExamResultView(completedExam: exam)
                            .environmentObject(dataManager)
                            .navigationBarItems(trailing: Button("Fechar") {
                                showLatestResult = false
                                latestCompletedExam = nil
                            })
                    }
                }
            }
            .onAppear {
                // Configure notification observer for exam completion
                NotificationCenter.default.addObserver(
                    forName: .examCompleted,
                    object: nil,
                    queue: .main
                ) { notification in
                    if let exam = notification.object as? CompletedExam {
                        self.latestCompletedExam = exam
                        self.showLatestResult = true
                    }
                }
                
                // Configurar preferência de tamanho para diferentes tamanhos de tela
                setDefaultSizeClass()
            }
        }
    }
    
    // Função para configurar o tamanho padrão para iPads
    private func setDefaultSizeClass() {
        let idiom = UIDevice.current.userInterfaceIdiom
        if idiom == .pad {
            UserDefaults.standard.set(true, forKey: "useMultiColumn")
        } else {
            UserDefaults.standard.set(false, forKey: "useMultiColumn")
        }
    }
}
