import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var dataManager: DataManager
    @State private var tempSettings: AppSettings
    @State private var showingResetAlert = false
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var exportURL: URL?
    
    // Novas opções de configuração
    @State private var isAutoBackupEnabled = false
    @State private var selectedAppIcon = "Default"
    
    @Environment(\.dismiss) var dismiss
    
    init(settingsManager: SettingsManager) {
        _tempSettings = State(initialValue: settingsManager.settings)
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Seção de Perfil
                Section {
                    NavigationLink {
                        UserProfileView(userManager: userManager)
                    } label: {
                        HStack {
                            ProfileAvatarView(user: userManager.currentUser, size: 50)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(userManager.currentUser.displayName)
                                    .font(.headline)
                                
                                Text(userManager.currentUser.professionalDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Seção de Aparência
                Section("Aparência") {
                    Toggle("Modo Escuro", isOn: $tempSettings.isDarkModeEnabled)
                        .onChange(of: tempSettings.isDarkModeEnabled) { _, newValue in
                            settingsManager.settings.isDarkModeEnabled = newValue
                            settingsManager.saveSettings()
                        }
                    
                    // Seleção de Ícone do Aplicativo
                    NavigationLink {
                        AppIconSelectionView(selectedIcon: $selectedAppIcon)
                    } label: {
                        HStack {
                            Text("Ícone do Aplicativo")
                            Spacer()
                            Text(selectedAppIcon)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Seletor de Tema de Cores
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tema de Cores")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(AppSettings.ColorTheme.allCases, id: \.self) { theme in
                                    ThemeColorButton(
                                        theme: theme,
                                        isSelected: tempSettings.colorTheme == theme,
                                        action: {
                                            tempSettings.colorTheme = theme
                                            settingsManager.settings.colorTheme = theme
                                            settingsManager.saveSettings()
                                        }
                                    )
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                // Seção de Preferências de Estudo
                Section("Preferências de Estudo") {
                    // Tamanho Padrão de Quiz
                    Picker("Tamanho Padrão de Quiz", selection: $tempSettings.defaultQuizSize) {
                        Text("5 questões").tag(5)
                        Text("10 questões").tag(10)
                        Text("15 questões").tag(15)
                        Text("20 questões").tag(20)
                    }
                    
                    // Lembrete Diário de Estudo
                    Toggle("Lembrete Diário de Estudo", isOn: $tempSettings.dailyReminderEnabled)
                    
                    if tempSettings.dailyReminderEnabled {
                        DatePicker("Horário do Lembrete",
                                   selection: $tempSettings.dailyReminderTime,
                                   displayedComponents: .hourAndMinute)
                    }
                    
                    // Duração da Sessão de Estudo
                    Picker("Duração da Sessão", selection: $tempSettings.studySessionDuration) {
                        Text("15 minutos").tag(15)
                        Text("30 minutos").tag(30)
                        Text("45 minutos").tag(45)
                        Text("60 minutos").tag(60)
                    }
                }
                
                // Seção de Comportamento dos Quizzes
                Section("Comportamento dos Quizzes") {
                    Toggle("Continuar Automaticamente", isOn: $tempSettings.automaticallyContinueQuizzes)
                    
                    Toggle("Mostrar Resposta Imediatamente", isOn: $tempSettings.showCorrectAnswerImmediately)
                    
                    Toggle("Comemorar Respostas Corretas", isOn: $tempSettings.showConfettiOnCorrectAnswer)
                    
                    // Nova opção: Ordem Aleatória de Questões
                    Toggle("Ordem Aleatória de Questões", isOn: $tempSettings.randomizeQuestionOrder)
                }
                
                // Seção de Feedback
                Section("Feedback") {
                    Toggle("Sons", isOn: $tempSettings.soundEnabled)
                    
                    Toggle("Feedback Háptico", isOn: $tempSettings.hapticFeedbackEnabled)
                }
                
                // Seção de Gerenciamento de Dados
                Section("Gerenciamento de Dados") {
                    // Exportar Dados de Estudo
                    Button {
                        exportStudyData()
                    } label: {
                        Label("Exportar Dados de Estudo", systemImage: "square.and.arrow.up")
                    }
                    
                    // Importar Dados de Estudo
                    Button {
                        showingImportPicker = true
                    } label: {
                        Label("Importar Dados de Estudo", systemImage: "square.and.arrow.down")
                    }
                    
                    // Nova opção: Backup Automático
                    Toggle("Backup Automático", isOn: $isAutoBackupEnabled)
                    
                    // Restaurar Configurações Padrão
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("Restaurar Configurações Padrão", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
                
                // Seção Sobre o App
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                            
                            Text("TEMFC")
                                .font(.headline)
                            
                            Text("Versão 1.1.0")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    Link(destination: URL(string: "https://temfc.com.br/privacidade")!) {
                        Label("Política de Privacidade", systemImage: "hand.raised.fill")
                    }
                    
                    Link(destination: URL(string: "https://temfc.com.br/termos")!) {
                        Label("Termos de Uso", systemImage: "doc.text.fill")
                    }
                }
                
                // Seção de Acompanhamento
                Section("Acompanhamento") {
                    NavigationLink {
                        AchievementsView()
                            .environmentObject(dataManager)
                    } label: {
                        Label("Conquistas", systemImage: "trophy.fill")
                    }
                    
                    NavigationLink {
                        PerformanceAnalyticsView()
                    } label: {
                        Label("Estatísticas de Estudo", systemImage: "chart.bar.fill")
                    }
                }
            }
            .onChange(of: tempSettings) { _, newSettings in
                settingsManager.settings = newSettings
                settingsManager.saveSettings()
            }
            .navigationTitle("Configurações")
            .alert("Restaurar Padrões", isPresented: $showingResetAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Restaurar", role: .destructive) {
                    tempSettings = AppSettings()
                    settingsManager.resetToDefaults()
                }
            } message: {
                Text("Todas as configurações serão restauradas para os valores padrão. Esta ação não pode ser desfeita.")
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportURL {
                    ActivityViewController(items: [url])
                }
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    importStudyData(from: url)
                case .failure(let error):
                    print("Import error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Função de exportação ajustada para usar os dados já codificados
    private func exportStudyData() {
        if let exportData = dataManager.getExportData() {
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "TEMFC_Dados_\(Date().ISO8601Format()).json"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            do {
                try exportData.write(to: fileURL)
                exportURL = fileURL
                showingExportSheet = true
            } catch {
                print("Export error: \(error.localizedDescription)")
            }
        }
    }
    
    private func importStudyData(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            try dataManager.importData(data)
        } catch {
            print("Import reading error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Views de Suporte

struct ActivityViewController: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ThemeColorButton: View {
    let theme: AppSettings.ColorTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(theme.primaryColor)
                    .frame(width: 32, height: 32)
                    .overlay {
                        if isSelected {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .padding(2)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                
                Text(theme.rawValue)
                    .font(.caption)
                    .foregroundStyle(isSelected ? theme.primaryColor : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct AppIconSelectionView: View {
    @Binding var selectedIcon: String
    let availableIcons = ["Default", "Dark", "Blue", "Green"]
    
    var body: some View {
        List {
            ForEach(availableIcons, id: \.self) { icon in
                Button {
                    selectedIcon = icon
                    changeAppIcon(to: icon)
                } label: {
                    HStack {
                        Image("\(icon)Icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                        
                        Text(icon)
                            .padding(.leading)
                        
                        Spacer()
                        
                        if selectedIcon == icon {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Escolha o Ícone")
    }
    
    func changeAppIcon(to iconName: String) {
        // A implementação real usaria UIApplication.shared.setAlternateIconName
        print("Changing app icon to: \(iconName)")
    }
}

struct ProfileAvatarView: View {
    let user: User
    let size: CGFloat
    
    var body: some View {
        if let imageData = user.profileImage,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            // Avatar com iniciais
            ZStack {
                Circle()
                    .fill(TEMFCDesign.Colors.primary.opacity(0.2))
                
                Text(userInitials)
                    .font(.system(size: size / 2.5, weight: .semibold))
                    .foregroundStyle(TEMFCDesign.Colors.primary)
            }
            .frame(width: size, height: size)
        }
    }
    
    private var userInitials: String {
        let components = user.name.components(separatedBy: " ")
        if components.count > 1,
           let first = components.first?.prefix(1),
           let last = components.last?.prefix(1) {
            return "\(first)\(last)".uppercased()
        } else if let first = components.first?.prefix(1) {
            return String(first).uppercased()
        } else {
            return "?"
        }
    }
}
