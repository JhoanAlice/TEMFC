// Caminho: /TEMFC/Views/ExamSessionView.swift

import SwiftUI
import AVKit

struct ExamSessionView: View {
    @ObservedObject var viewModel: ExamViewModel
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingsManager: SettingsManager  // Supondo que exista um SettingsManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingExplanation = false
    @State private var showingActionSheet = false
    @State private var showConfetti = false
    @State private var animateTransition = false
    
    // ScrollViewReader para controle de navegação
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    // Geradores de feedback háptico (caso não seja usado o settingsManager)
    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    let notificationFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            // Fundo
            TEMFCDesign.Colors.background
                .ignoresSafeArea()
            
            // Conteúdo principal
            VStack(spacing: 0) {
                headerView
                    .padding(.bottom, 1)
                progressBarView
                
                if let question = viewModel.currentQuestion {
                    ScrollView(.vertical, showsIndicators: true) {
                        ScrollViewReader { proxy in
                            VStack(spacing: 20) {
                                QuestionCardView(
                                    question: question,
                                    selectedOption: viewModel.userAnswers[question.id],
                                    isRevealed: showingExplanation,
                                    onOptionSelected: { index in
                                        handleOptionSelected(question: question, index: index)
                                    },
                                    onToggleFavorite: {
                                        if dataManager.isFavorite(questionId: question.id) {
                                            dataManager.removeFromFavorites(questionId: question.id)
                                        } else {
                                            dataManager.addToFavorites(questionId: question.id)
                                        }
                                    }
                                )
                                .id("questionCard")
                                .padding(.horizontal)
                                .padding(.top)
                                .opacity(animateTransition ? 1 : 0)
                                .animation(.easeInOut(duration: 0.5), value: animateTransition)
                                
                                Spacer(minLength: 80)
                            }
                            .padding(.bottom, 50)
                            .onAppear {
                                scrollProxy = proxy
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        animateTransition = true
                                    }
                                }
                            }
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                        Text("Carregando questão...")
                            .font(TEMFCDesign.Typography.headline)
                            .foregroundColor(TEMFCDesign.Colors.secondaryText)
                        Spacer()
                    }
                }
            }
            
            // Barra de navegação inferior
            VStack {
                Spacer()
                navigationButtons
            }
            
            // Confetti para feedback de respostas corretas
            if showConfetti {
                ExamConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            setupOnAppear()
        }
        .onChange(of: viewModel.currentQuestionIndex) { newValue, oldValue in
            showingExplanation = false
            animateTransition = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    animateTransition = true
                }
                scrollProxy?.scrollTo("questionCard", anchor: .top)
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            createActionSheet()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Componentes da Interface
    
    private var headerView: some View {
        ZStack {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    Text(formattedTime(viewModel.elapsedTime))
                        .font(TEMFCDesign.Typography.headline)
                        .monospacedDigit()
                        .foregroundColor(TEMFCDesign.Colors.text)
                }
                .padding(.horizontal)
                Spacer()
                Button(action: {
                    TEMFCDesign.HapticFeedback.lightImpact()
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(TEMFCDesign.Colors.primary)
                        .padding(.horizontal)
                }
            }
            if let exam = viewModel.currentExam {
                HStack(spacing: 4) {
                    Text("\(viewModel.currentQuestionIndex + 1)")
                        .font(TEMFCDesign.Typography.headline)
                        .foregroundColor(TEMFCDesign.Colors.primary)
                    Text("/")
                        .font(TEMFCDesign.Typography.subheadline)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    Text("\(exam.questions.count)")
                        .font(TEMFCDesign.Typography.subheadline)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                }
            }
        }
        .padding(.vertical, 12)
        .background(TEMFCDesign.Colors.background)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
    
    private var progressBarView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                if let exam = viewModel.currentExam {
                    Rectangle()
                        .fill(TEMFCDesign.Colors.primary)
                        .frame(
                            width: geometry.size.width * CGFloat(viewModel.currentQuestionIndex + 1) / CGFloat(exam.questions.count),
                            height: 4
                        )
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentQuestionIndex)
                }
            }
        }
        .frame(height: 4)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                navigateToPreviousQuestion()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Anterior")
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    Capsule()
                        .fill(TEMFCDesign.Colors.primary.opacity(0.1))
                )
                .foregroundColor(TEMFCDesign.Colors.primary)
            }
            .disabled(viewModel.currentQuestionIndex == 0)
            .opacity(viewModel.currentQuestionIndex == 0 ? 0.5 : 1)
            
            Spacer()
            
            if showingExplanation {
                Button(action: {
                    navigateToNextQuestion()
                }) {
                    HStack {
                        Text(isLastQuestion ? "Finalizar" : "Próxima")
                        Image(systemName: isLastQuestion ? "checkmark" : "chevron.right")
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(TEMFCDesign.Colors.primary)
                    )
                    .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(TEMFCDesign.Colors.background)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -3)
    }
    
    // MARK: - Funções Auxiliares
    
    private func setupOnAppear() {
        impactMedium.prepare()
        notificationFeedback.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                animateTransition = true
            }
        }
    }
    
    private func handleOptionSelected(question: Question, index: Int) {
        viewModel.selectAnswer(questionId: question.id, optionIndex: index)
        
        if viewModel.isAnswerCorrect(questionId: question.id, optionIndex: index) {
            if settingsManager.settings.hapticFeedbackEnabled {
                TEMFCDesign.HapticFeedback.success()
            }
            if settingsManager.settings.showConfettiOnCorrectAnswer {
                withAnimation {
                    showConfetti = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showConfetti = false
                    }
                }
            }
        } else {
            if settingsManager.settings.hapticFeedbackEnabled {
                TEMFCDesign.HapticFeedback.error()
            }
        }
        
        if settingsManager.settings.showCorrectAnswerImmediately {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showingExplanation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    scrollProxy?.scrollTo("explanationSection", anchor: .top)
                }
            }
        }
        
        // Removido o código de navegação automática para impedir a transição imediata:
        /*
        if settingsManager.settings.automaticallyContinueQuizzes && !isLastQuestion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                navigateToNextQuestion()
            }
        }
        */
    }
    
    private func navigateToPreviousQuestion() {
        TEMFCDesign.HapticFeedback.lightImpact()
        withAnimation {
            animateTransition = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingExplanation = false
            viewModel.moveToPreviousQuestion()
        }
    }
    
    private func navigateToNextQuestion() {
        TEMFCDesign.HapticFeedback.lightImpact()
        if isLastQuestion {
            showingActionSheet = true
        } else {
            withAnimation {
                animateTransition = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingExplanation = false
                viewModel.moveToNextQuestion()
            }
        }
    }
    
    private var isLastQuestion: Bool {
        guard let exam = viewModel.currentExam else { return false }
        return viewModel.currentQuestionIndex == exam.questions.count - 1
    }
    
    private func finishExam() {
        print("🏁 Iniciando processo de finalização do exame")
        guard let currentExam = viewModel.currentExam else {
            print("❌ Erro: Nenhum exame atual encontrado")
            return
        }
        
        if let completedExam = viewModel.finishExam() {
            print("✅ Exame finalizado com sucesso: \(completedExam.score)%")
            dataManager.saveCompletedExam(completedExam)
            print("💾 Exame salvo no DataManager")
            dataManager.removeInProgressExam(examId: currentExam.id)
            viewModel.completedExam = completedExam
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
            print("🔄 Navegação para tela de resultados iniciada")
        } else {
            print("❌ Erro: Falha ao finalizar o exame")
        }
    }
    
    private func createActionSheet() -> ActionSheet {
        if isLastQuestion && showingExplanation {
            return ActionSheet(
                title: Text("Finalizar Simulado"),
                message: Text("Escolha uma opção:"),
                buttons: [
                    .default(Text("Finalizar e Ver Resultados")) {
                        finishExam()
                    },
                    .default(Text("Salvar e Sair")) {
                        saveAndExit()
                    },
                    .cancel()
                ]
            )
        } else {
            return ActionSheet(
                title: Text("Opções"),
                message: Text("O que você deseja fazer?"),
                buttons: [
                    .default(Text("Salvar e Sair")) {
                        saveAndExit()
                    },
                    .destructive(Text("Finalizar sem Salvar")) {
                        presentationMode.wrappedValue.dismiss()
                    },
                    .cancel()
                ]
            )
        }
    }
    
    private func saveAndExit() {
        let inProgressExam = viewModel.saveProgressAndExit()
        dataManager.saveInProgressExam(inProgressExam)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - Extension with Additional Methods

extension ExamSessionView {
    // O callback onToggleFavorite já está integrado na instância de QuestionCardView acima.
}

struct ExamSessionView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ExamViewModel()
        viewModel.startExam(exam: Exam(
            id: "EXAMPLE",
            name: "Exemplo de Prova",
            type: .theoretical,
            questions: [
                Question(
                    id: 1,
                    number: 1,
                    statement: "Exemplo de questão para preview.",
                    options: ["A - Opção A", "B - Opção B", "C - Opção C", "D - Opção D"],
                    correctOption: 0,
                    explanation: "Esta é a explicação da questão.",
                    tags: ["Tag1", "Tag2"]
                )
            ]
        ))
        
        return ExamSessionView(viewModel: viewModel)
            .environmentObject(DataManager())
            .environmentObject(SettingsManager())
    }
}
