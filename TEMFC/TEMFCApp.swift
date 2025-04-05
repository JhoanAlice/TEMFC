import SwiftUI

@main
struct TEMFCApp: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var userManager = UserManager()
    @StateObject private var settingsManager = SettingsManager()
    @State private var latestCompletedExam: CompletedExam?
    @State private var showLatestResult = false
    @State private var showDiagnostics = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    // Verificar se estamos em modo de teste
                    if ProcessInfo.processInfo.arguments.contains("UITesting") {
                        // Em modo de teste, vamos direto para a tela principal
                        MainTabView()
                            .environmentObject(dataManager)
                            .environmentObject(userManager)
                            .environmentObject(settingsManager)
                            .preferredColorScheme(settingsManager.settings.isDarkModeEnabled ? .dark : .light)
                            .onAppear {
                                // Certificar que estamos "logados" para testes
                                userManager.isLoggedIn = true
                                
                                // Adicionar exames mockados para teste
                                addMockExamsForTesting()
                                
                                // Adicionar um exame em andamento simulado para testes
                                addMockInProgressExam()
                            }
                    } else if !userManager.isLoggedIn {
                        WelcomeView()
                            .environmentObject(userManager)
                            .environmentObject(settingsManager)
                    } else {
                        SplashScreenView()
                            .environmentObject(dataManager)
                            .environmentObject(userManager)
                            .environmentObject(settingsManager)
                            .preferredColorScheme(settingsManager.settings.isDarkModeEnabled ? .dark : .light)
                            .onAppear {
                                // Executar diagnóstico para verificar carregamento de arquivos
                                if ProcessInfo.processInfo.arguments.contains("diagnoseFiles") {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        dataManager.testJSONFileDetection()
                                        self.showDiagnostics = true
                                    }
                                }
                            }
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
    
    // Função para adicionar exames mockados durante testes
    private func addMockExamsForTesting() {
        print("Adicionando exames mockados para testes de UI")
        
        let questions = [
            Question(
                id: 1001,
                number: 1,
                statement: "Questão de teste para UI Testing",
                options: ["A - Opção A", "B - Opção B", "C - Opção C", "D - Opção D"],
                correctOption: 0,
                explanation: "Explicação da questão para UI Testing",
                tags: ["UI Testing"]
            ),
            Question(
                id: 1002,
                number: 2,
                statement: "Segunda questão de teste para UI Testing",
                options: ["A - Opção 1", "B - Opção 2", "C - Opção 3", "D - Opção 4"],
                correctOption: 1,
                explanation: "Explicação da segunda questão para UI Testing",
                tags: ["UI Testing", "Teste Automático"]
            )
        ]
        
        let mockExams = [
            Exam(
                id: "UI_TEST_1",
                name: "Exame UI Test 1",
                type: .theoretical,
                totalQuestions: questions.count,
                questions: questions
            ),
            Exam(
                id: "UI_TEST_2",
                name: "Exame UI Test 2",
                type: .theoretical_practical,
                totalQuestions: questions.count,
                questions: questions
            )
        ]
        
        DispatchQueue.main.async {
            self.dataManager.exams.append(contentsOf: mockExams)
            print("Adicionados \(mockExams.count) exames mockados para testes de UI")
        }
    }
    
    // Adicionar um exame em andamento simulado para testes
    private func addMockInProgressExam() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Ensure exams are loaded
            if !self.dataManager.exams.isEmpty {
                let mockExam = self.dataManager.exams[0]
                
                // Create an in-progress exam
                let inProgressExam = InProgressExam(
                    examId: mockExam.id,
                    startTime: Date().addingTimeInterval(-300), // Started 5 minutes ago
                    elapsedTime: 300, // 5 minutes elapsed
                    currentQuestionIndex: 1,
                    userAnswers: [mockExam.questions[0].id: 0] // Answered first question
                )
                
                // Save it to the DataManager
                self.dataManager.saveInProgressExam(inProgressExam)
                print("Added mock in-progress exam for testing: \(mockExam.id)")
            }
        }
    }
}
