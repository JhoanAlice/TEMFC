// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/Views/WelcomeView.swift

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var currentPage = 0
    @State private var name = ""
    @State private var email = ""
    @State private var specialization: User.Specialization = .resident
    @State private var graduationYear = Calendar.current.component(.year, from: Date())
    
    // Propriedade para controle do foco dos campos de texto
    @FocusState private var focusedField: Field?
    
    // Enum para identificar os campos que podem receber foco
    enum Field {
        case name, email
    }
    
    // Valores para o picker de ano de formatura
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let yearRange = Calendar.current.component(.year, from: Date()) - 30 ... Calendar.current.component(.year, from: Date()) + 5
    
    var body: some View {
        ZStack {
            // Fundo animado
            AnimatedBackground(colors: [
                settingsManager.settings.colorTheme.primaryColor,
                settingsManager.settings.colorTheme.secondaryColor,
                settingsManager.settings.colorTheme.primaryColor.opacity(0.8)
            ])
            
            // Gesto para fechar o teclado ao tocar fora dos campos
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            
            VStack {
                // Conteúdo do onboarding
                Group {
                    if currentPage == 0 {
                        welcomePage
                    } else if currentPage == 1 {
                        featuresPage
                    } else {
                        registrationPage
                    }
                }
                .transition(.opacity)
                
                // Indicadores de página
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(currentPage == i ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                // Botões de navegação
                HStack {
                    if currentPage > 0 {
                        Button {
                            DispatchQueue.main.async {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Voltar")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        if currentPage == 2 {
                            completeRegistration()
                        } else {
                            DispatchQueue.main.async {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(currentPage == 2 ? "Começar" : "Próximo")
                            Image(systemName: currentPage == 2 ? "checkmark" : "chevron.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(currentPage == 2 && !isFormValid ? 0.1 : 0.2))
                        )
                    }
                    .disabled(currentPage == 2 && !isFormValid)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Páginas do Onboarding
    
    private var welcomePage: some View {
        VStack(spacing: 30) {
            Text("TEMFC")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text("Simulados para Medicina de Família e Comunidade")
                .font(.title3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer().frame(height: 30)
            
            VStack(spacing: 16) {
                Text("Bem-vindo ao TEMFC")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Seu assistente de estudos para o Título de Especialista em Medicina de Família e Comunidade")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 30)
        }
        .padding()
    }
    
    private var featuresPage: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Prepare-se para o TEMFC")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)
            
            featureItem(icon: "doc.text.fill", title: "Simulados Completos", description: "Pratique com questões no formato oficial da prova TEMFC")
            
            featureItem(icon: "books.vertical.fill", title: "Modo Estudo", description: "Crie quizzes personalizados por área de conhecimento")
            
            featureItem(icon: "chart.bar.fill", title: "Análise de Desempenho", description: "Acompanhe sua evolução e identifique áreas de melhoria")
            
            featureItem(icon: "iphone", title: "Offline e Portátil", description: "Estude em qualquer lugar, mesmo sem conexão com a internet")
        }
        .padding(30)
    }
    
    private var registrationPage: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Crie seu Perfil")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Nome")
                    .font(.headline)
                    .foregroundColor(.white)
                
                SafeSwiftUITextField(
                    placeholder: "Seu nome completo",
                    text: $name,
                    keyboardType: .default,
                    autocapitalization: .words,
                    foregroundColor: .white
                )
                .focused($focusedField, equals: .name)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("E-mail")
                    .font(.headline)
                    .foregroundColor(.white)
                
                SafeSwiftUITextField(
                    placeholder: "Seu e-mail",
                    text: $email,
                    keyboardType: .emailAddress,
                    autocapitalization: .none,
                    foregroundColor: .white
                )
                .focused($focusedField, equals: .email)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Especialização")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Menu {
                    ForEach(User.Specialization.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            specialization = option
                        }
                    }
                } label: {
                    HStack {
                        Text(specialization.rawValue)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Ano de Formatura")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Menu {
                    ForEach(yearRange, id: \.self) { year in
                        Button(String(year)) {
                            graduationYear = year
                        }
                    }
                } label: {
                    HStack {
                        Text(String(graduationYear))
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            
            if !isFormValid {
                Text("Por favor, preencha todos os campos corretamente.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 5)
            }
        }
        .padding(30)
    }
    
    private func featureItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        email.contains(".")
    }
    
    private func completeRegistration() {
        DispatchQueue.main.async {
            userManager.updateUser(
                name: name,
                email: email,
                specialization: specialization,
                graduationYear: graduationYear
            )
            userManager.login()
            
            if settingsManager.settings.hapticFeedbackEnabled {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(UserManager())
            .environmentObject(SettingsManager())
    }
}
