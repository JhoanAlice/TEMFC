import SwiftUI
import AVKit

struct ExamSessionView: View {
    @ObservedObject var viewModel: ExamViewModel
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingExplanation = false
    @State private var showingActionSheet = false
    @State private var showConfetti = false
    @State private var animateTransition = false
    
    // ScrollViewReader para controle de navegação
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    // Geradores de feedback háptico
    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    let notificationFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            // Fundo
            TEMFCDesign.Colors.background
                .ignoresSafeArea()
            
            // Conteúdo principal
            VStack(spacing: 0) {
                // Cabeçalho com cronômetro e número da questão
                headerView
                    .padding(.bottom, 1)
                
                // Barra de progresso
                progressBarView
                
                if let question = viewModel.currentQuestion {
                    // Conteúdo principal em ScrollView
                    ScrollView(.vertical, showsIndicators: true) {
                        ScrollViewReader { proxy in
                            VStack(spacing: 20) {
                                // Cartão da questão
                                QuestionCardView(
                                    question: question,
                                    selectedOption: viewModel.userAnswers[question.id],
                                    isRevealed: showingExplanation,
                                    onOptionSelected: { index in
                                        handleOptionSelected(question: question, index: index)
                                    }
                                )
                                .id("questionCard")
                                .padding(.horizontal)
                                .padding(.top)
                                .opacity(animateTransition ? 1 : 0)
                                .animation(.easeInOut(duration: 0.5), value: animateTransition)
                                
                                // Espaço para navegação
                                Spacer(minLength: 80)
                            }
                            .padding(.bottom, 50)
                            .onAppear {
                                // Armazenar a referência para o ScrollViewProxy
                                scrollProxy = proxy
                                
                                // Animar a entrada da questão
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        animateTransition = true
                                    }
                                }
                            }
                        }
                    }
                } else {
                    // Fallback se não houver questão
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
            
            // Barra de navegação inferior sobreposta
            VStack {
                Spacer()
                navigationButtons
            }
            
            // Confetti para respostas corretas
            if showConfetti {
                ExamConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            setupOnAppear()
        }
        .onChange(of: viewModel.currentQuestionIndex) { _ in
            // Reset state e animar nova questão
            showingExplanation = false
            animateTransition = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    animateTransition = true
                }
                
                // Rolar para o topo
                scrollProxy?.scrollTo("questionCard", anchor: .top)
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            createActionSheet()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Componentes
    
    // Cabeçalho com cronômetro e botões
    private var headerView: some View {
        ZStack {
            HStack {
                // Cronômetro
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
                
                // Menu de opções
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
            
            // Número da questão
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
    
    // Barra de progresso aprimorada
    private var progressBarView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Fundo da barra
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                // Progresso
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
    
    // Botões de navegação inferiores
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            // Botão Anterior
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
            
            // Botão Próxima/Finalizar
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
        
        // Iniciar com animação
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                animateTransition = true
            }
        }
    }
    
    private func handleOptionSelected(question: Question, index: Int) {
        // Registrar a resposta
        viewModel.selectAnswer(questionId: question.id, optionIndex: index)
        
        // Feedback tátil e visual
        if viewModel.isAnswerCorrect(questionId: question.id, optionIndex: index) {
            TEMFCDesign.HapticFeedback.success()
            withAnimation {
                showConfetti = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showConfetti = false
                }
            }
        } else {
            TEMFCDesign.HapticFeedback.error()
        }
        
        // Mostrar explicação com animação
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showingExplanation = true
        }
        
        // Agendar a rolagem após a animação de mostrar explicação
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.7)) {
                scrollProxy?.scrollTo("explanationSection", anchor: .top)
            }
        }
    }
    
    private func navigateToPreviousQuestion() {
        TEMFCDesign.HapticFeedback.lightImpact()
        
        // Animar transição de saída
        withAnimation {
            animateTransition = false
        }
        
        // Navegar após breve delay para animação
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
            // Animar transição de saída
            withAnimation {
                animateTransition = false
            }
            
            // Navegar após breve delay para animação
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
    
    // MARK: - Método finishExam atualizado
    
    private func finishExam() {
        print("🏁 Iniciando processo de finalização do exame")
        
        guard let currentExam = viewModel.currentExam else {
            print("❌ Erro: Nenhum exame atual encontrado")
            return
        }
        
        if let completedExam = viewModel.finishExam() {
            print("✅ Exame finalizado com sucesso: \(completedExam.score)%")
            
            // Salvar no DataManager
            dataManager.saveCompletedExam(completedExam)
            print("💾 Exame salvo no DataManager")
            
            // Limpar o exame em andamento
            dataManager.removeInProgressExam(examId: currentExam.id)
            
            // Garantir que o viewModel tenha o completedExam definido
            viewModel.completedExam = completedExam
            
            // Forçar a atualização da interface para navegar para a tela de resultados
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
    }
}
