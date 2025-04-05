// TEMFC/Views/SplashScreenView.swift

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var loadingMessage = "Carregando recursos..."
    @State private var loadingProgress = 0.0
    @State private var examLoadingFinished = false
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        ZStack {
            // Fundo animado
            AnimatedBackground(colors: [
                Color.blue,
                Color.blue.opacity(0.8),
                Color(red: 0.1, green: 0.4, blue: 0.8)
            ])
            
            if isActive {
                // Se ativo, mostra a MainTabView (nova estrutura de navegação)
                MainTabView()
                    .environmentObject(dataManager)
                    .environmentObject(userManager)
                    .environmentObject(settingsManager)
                    .transition(.opacity)
            } else {
                // Interface de carregamento com indicador de progresso
                VStack(spacing: 30) {
                    // Logo animado
                    LogoAnimationView()
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Indicador de progresso
                    VStack(spacing: 12) {
                        ProgressView(value: loadingProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .frame(width: 200)
                        
                        Text(loadingMessage)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            simulateLoading()
        }
        .animation(.easeInOut(duration: 0.6), value: isActive)
    }
    
    // Função para simular o carregamento com progresso real
    private func simulateLoading() {
        // Registrar para notificação de conclusão do carregamento de exames
        NotificationCenter.default.addObserver(forName: Notification.Name("examsLoaded"), object: nil, queue: .main) { _ in
            withAnimation {
                self.loadingProgress = 0.9 // Quase pronto quando os exames carregam
                self.loadingMessage = "\(dataManager.exams.count) simulados carregados."
                self.examLoadingFinished = true
            }
            
            // Finalizar carregamento após um breve período
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation {
                    self.loadingProgress = 1.0
                    self.loadingMessage = "Iniciando aplicativo..."
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
        
        // Mensagem inicial e simulação de progresso
        self.loadingMessage = "Carregando recursos..."
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            withAnimation {
                // Avança somente até 70% enquanto o carregamento real não termina
                if loadingProgress < 0.7 {
                    loadingProgress += 0.01
                }
                
                if loadingProgress > 0.3 && loadingProgress < 0.31 {
                    loadingMessage = "Preparando interface..."
                } else if loadingProgress > 0.5 && loadingProgress < 0.51 {
                    loadingMessage = "Carregando questões..."
                }
                
                if examLoadingFinished {
                    timer.invalidate()
                }
            }
        }
        
        // Timeout de segurança: caso o carregamento demore muito
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if !examLoadingFinished && loadingProgress < 0.9 {
                withAnimation {
                    loadingProgress = 0.9
                    loadingMessage = "Preparando simulados..."
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
        
        // Iniciar o carregamento real dos exames
        dataManager.loadAndProcessExams()
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
            .environmentObject(DataManager())
            .environmentObject(UserManager())
            .environmentObject(SettingsManager())
    }
}
