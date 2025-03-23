import SwiftUI
import Foundation

@main
struct TEMFCApp: App {
    @StateObject private var dataManager = DataManager()
    @State private var latestCompletedExam: CompletedExam?
    @State private var showLatestResult = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                SplashScreenView()
                    .environmentObject(dataManager)
                
                // Solução de fallback para resultados perdidos
                if showLatestResult, let exam = latestCompletedExam {
                    NavigationView {
                        ExamResultView(completedExam: exam)
                            .environmentObject(dataManager)
                            .navigationBarItems(trailing: Button("Fechar") {
                                showLatestResult = false
                                latestCompletedExam = nil
                            })
                    }
                    .transition(.opacity)
                }
            }
            .onAppear {
                // Aplicar otimizações de teclado na thread principal
                DispatchQueue.main.async {
                    KeyboardOptimization.setupKeyboard()
                }
                
                // Configurar notificação para exames finalizados
                NotificationCenter.default.addObserver(forName: .examCompleted, object: nil, queue: .main) { notification in
                    if let exam = notification.object as? CompletedExam {
                        self.latestCompletedExam = exam
                        // Pequeno atraso para garantir que a UI seja atualizada corretamente
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                self.showLatestResult = true
                            }
                        }
                    }
                }
            }
        }
    }
}
