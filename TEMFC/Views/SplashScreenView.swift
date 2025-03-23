import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var loadingMessage = "Carregando recursos..."
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isActive {
                // Se estiver ativo, mostra a HomeView
                HomeView()
                    .environmentObject(dataManager)
            } else {
                // Interface de carregamento
                VStack(spacing: 20) {
                    Text("TEMFC")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Simulados para Medicina de Família e Comunidade")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer().frame(height: 40)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text(loadingMessage)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
        }
        .onAppear {
            // Verifica se há exames carregados no dataManager
            if dataManager.exams.isEmpty {
                loadingMessage = "Carregando base de questões..."
            } else {
                loadingMessage = "Preparando simulados..."
            }
            
            // Simula um tempo de carregamento e então ativa a view principal
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Atualiza o status para o usuário
                if dataManager.exams.isEmpty {
                    loadingMessage = "Nenhum exame encontrado. Criando dados de exemplo..."
                    
                    // Dá mais tempo para os exames de exemplo serem criados
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            isActive = true
                        }
                    }
                } else {
                    loadingMessage = "\(dataManager.exams.count) simulados carregados."
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
            .environmentObject(DataManager())
    }
}
