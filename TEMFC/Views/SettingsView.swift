import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var userManager: UserManager
    @State private var tempSettings: AppSettings
    @State private var showingResetAlert = false
    @State private var showingLogoutAlert = false
    
    @Environment(\.presentationMode) var presentationMode
    
    init(settingsManager: SettingsManager) {
        _tempSettings = State(initialValue: settingsManager.settings)
    }
    
    var body: some View {
        ZStack {
            TEMFCDesign.Colors.groupedBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Seção de aparência
                    appearanceSection
                    
                    // Seção de som e vibração
                    soundAndHapticsSection
                    
                    // Seção de notificações
                    notificationsSection
                    
                    // Seção de comportamento
                    behaviorSection
                    
                    // Seção de reinicialização
                    resetSection
                    
                    // Logout
                    if userManager.isLoggedIn {
                        logoutSection
                    }
                    
                    // Informações do app
                    appInfoSection
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Configurações")
        .navigationBarItems(trailing: Button("Salvar") {
            settingsManager.settings = tempSettings
            settingsManager.saveSettings()
            presentationMode.wrappedValue.dismiss()
        })
        .alert(isPresented: $showingResetAlert) {
            Alert(
                title: Text("Restaurar Padrões"),
                message: Text("Tem certeza que deseja restaurar todas as configurações para os valores padrão?"),
                primaryButton: .destructive(Text("Restaurar")) {
                    tempSettings = AppSettings()
                },
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
        .onChange(of: tempSettings.dailyReminderEnabled) { newValue, _ in
            if newValue {
                // Solicitar permissão de notificação quando ativado
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
            }
        }
    }
    
    // MARK: - Seções da interface
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Aparência")
            
            VStack(spacing: 0) {
                // Modo escuro
                Toggle("Modo Escuro", isOn: $tempSettings.isDarkModeEnabled)
                    .padding()
                    .background(TEMFCDesign.Colors.background)
                    .cornerRadius(tempSettings.colorTheme == .blue ? TEMFCDesign.BorderRadius.medium : 0)
                
                Divider().padding(.leading)
                
                // Tema de cores
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tema de cores")
                        .font(TEMFCDesign.Typography.body)
                        .foregroundColor(TEMFCDesign.Colors.text)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AppSettings.ColorTheme.allCases, id: \.self) { theme in
                                colorThemeButton(theme)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
                .padding()
                .background(TEMFCDesign.Colors.background)
                .cornerRadius(TEMFCDesign.BorderRadius.medium)
            }
            .temfcCard(padding: 0)
        }
    }
    
    private var soundAndHapticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Som e Vibração")
            
            VStack(spacing: 0) {
                // Som
                Toggle("Sons de Feedback", isOn: $tempSettings.soundEnabled)
                    .padding()
                    .background(TEMFCDesign.Colors.background)
                
                Divider().padding(.leading)
                
                // Vibração
                Toggle("Feedback Háptico", isOn: $tempSettings.hapticFeedbackEnabled)
                    .padding()
                    .background(TEMFCDesign.Colors.background)
                    .cornerRadius(TEMFCDesign.BorderRadius.medium)
            }
            .temfcCard(padding: 0)
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Notificações")
            
            VStack(spacing: 0) {
                // Lembrete diário
                Toggle("Lembrete Diário", isOn: $tempSettings.dailyReminderEnabled)
                    .padding()
                    .background(TEMFCDesign.Colors.background)
                
                if tempSettings.dailyReminderEnabled {
                    Divider().padding(.leading)
                    
                    // Horário do lembrete
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Horário do Lembrete")
                            .font(TEMFCDesign.Typography.subheadline)
                            .foregroundColor(TEMFCDesign.Colors.secondaryText)
                        
                        DatePicker("", selection: $tempSettings.dailyReminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                    .background(TEMFCDesign.Colors.background)
                    .cornerRadius(TEMFCDesign.BorderRadius.medium)
                }
            }
            .temfcCard(padding: 0)
        }
    }
    
    private var behaviorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Comportamento")
            
            VStack(spacing: 0) {
                // Continuar automaticamente
                Toggle("Continuar Automaticamente", isOn: $tempSettings.automaticallyContinueQuizzes)
                    .padding()
                    .background(TEMFCDesign.Colors.background)
                
                Divider().padding(.leading)
                
                // Mostrar resposta correta
                Toggle("Mostrar Resposta Imediatamente", isOn: $tempSettings.showCorrectAnswerImmediately)
                    .padding()
                    .background(TEMFCDesign.Colors.background)
                
                Divider().padding(.leading)
                
                // Confete em respostas corretas
                Toggle("Comemorar Respostas Corretas", isOn: $tempSettings.showConfettiOnCorrectAnswer)
                    .padding()
                    .background(TEMFCDesign.Colors.background)
                
                Divider().padding(.leading)
                
                // Tamanho padrão do quiz
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tamanho padrão do quiz")
                        .font(TEMFCDesign.Typography.body)
                        .foregroundColor(TEMFCDesign.Colors.text)
                    
                    Picker("", selection: $tempSettings.defaultQuizSize) {
                        Text("5 questões").tag(5)
                        Text("10 questões").tag(10)
                        Text("15 questões").tag(15)
                        Text("20 questões").tag(20)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                .background(TEMFCDesign.Colors.background)
                .cornerRadius(TEMFCDesign.BorderRadius.medium)
            }
            .temfcCard(padding: 0)
        }
    }
    
    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Restaurar")
            
            Button(action: {
                showingResetAlert = true
            }) {
                HStack {
                    Text("Restaurar Configurações Padrão")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.red)
                }
                .padding()
                .background(TEMFCDesign.Colors.background)
                .cornerRadius(TEMFCDesign.BorderRadius.medium)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var logoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Conta")
            
            Button(action: {
                showingLogoutAlert = true
            }) {
                HStack {
                    Text("Sair da Conta")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
                .padding()
                .background(TEMFCDesign.Colors.background)
                .cornerRadius(TEMFCDesign.BorderRadius.medium)
            }
            .buttonStyle(PlainButtonStyle())
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Sair da Conta"),
                    message: Text("Tem certeza que deseja sair da sua conta?"),
                    primaryButton: .destructive(Text("Sair")) {
                        userManager.logout()
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text("Cancelar"))
                )
            }
        }
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Sobre o Aplicativo")
            
            VStack(spacing: 16) {
                Image("AppIcon") // Certifique-se de ter uma imagem "AppIcon" em Assets
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
                    .padding(.top, 16)
                
                VStack(spacing: 4) {
                    Text("TEMFC")
                        .font(TEMFCDesign.Typography.title2)
                        .foregroundColor(TEMFCDesign.Colors.text)
                    
                    Text("Versão 1.0")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                }
                
                Text("Desenvolvido com ❤️ para médicos e estudantes de Medicina de Família e Comunidade.")
                    .font(TEMFCDesign.Typography.subheadline)
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Link(destination: URL(string: "mailto:contato@temfcapp.com.br")!) {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Contato e Suporte")
                    }
                    .foregroundColor(TEMFCDesign.Colors.primary)
                }
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity)
            .background(TEMFCDesign.Colors.background)
            .cornerRadius(TEMFCDesign.BorderRadius.medium)
        }
    }
    
    // MARK: - Componentes auxiliares
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(TEMFCDesign.Typography.headline)
            .foregroundColor(TEMFCDesign.Colors.text)
            .padding(.leading, 8)
    }
    
    private func colorThemeButton(_ theme: AppSettings.ColorTheme) -> some View {
        Button(action: {
            tempSettings.colorTheme = theme
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(theme.primaryColor)
                        .frame(width: 56, height: 56)
                    
                    if tempSettings.colorTheme == theme {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                            .frame(width: 46, height: 46)
                        
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                
                Text(theme.rawValue)
                    .font(TEMFCDesign.Typography.caption)
                    .foregroundColor(tempSettings.colorTheme == theme ? theme.primaryColor : TEMFCDesign.Colors.secondaryText)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Ações
    
    private var isFormValid: Bool {
        !tempSettings.isDarkModeEnabled || !tempSettings.isDarkModeEnabled // Exemplo de validação, ajuste conforme necessário
        // Na verdade, aqui você deve validar os campos de usuário, por exemplo:
        // return !name.isEmpty && !email.isEmpty && email.contains("@") && email.contains(".")
    }
    
    private func completeRegistration() {
        DispatchQueue.main.async {
            // Exemplo de atualização do usuário; ajuste conforme sua lógica
            userManager.updateUser(
                name: "", // Aqui insira a lógica para atualizar o nome, se aplicável
                email: "", // Lógica para email
                specialization: .resident, // Lógica para especialização
                graduationYear: 2023 // Lógica para ano de formatura
            )
            userManager.login()
            
            if settingsManager.settings.hapticFeedbackEnabled {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Crie uma instância do SettingsManager para o preview
        let manager = SettingsManager()
        return SettingsView(settingsManager: manager)
            .environmentObject(manager)
            .environmentObject(UserManager())
    }
}
