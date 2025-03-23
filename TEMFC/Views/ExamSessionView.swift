import SwiftUI
import AVKit

struct ExamSessionView: View {
    @ObservedObject var viewModel: ExamViewModel
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingExplanation = false
    @State private var selectedOption: Int? = nil
    @State private var showingActionSheet = false
    @State private var showConfetti = false
    
    // Adicionar ScrollViewReader para controlar a rolagem
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    // Geradores de feedback háptico
    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    let impactLight = UIImpactFeedbackGenerator(style: .light)
    let notificationFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            // Fundo
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            // Conteúdo principal em uma única ScrollView
            VStack(spacing: 0) {
                // Cabeçalho fixo
                headerView
                
                // Barra de progresso
                progressBarView
                
                if let question = viewModel.currentQuestion {
                    // Todo o conteúdo em uma única ScrollView para evitar problemas de layout
                    ScrollView(.vertical, showsIndicators: true) {
                        ScrollViewReader { proxy in
                            VStack(alignment: .leading, spacing: 20) {
                                // Título da questão
                                Text("Questão \(question.number)")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal)
                                    .padding(.top)
                                    .id("questionHeader") // ID para rolagem
                                
                                // Enunciado
                                Text(question.statement)
                                    .font(.body)
                                    .padding(.horizontal)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                // Player de vídeo (se houver)
                                if let videoUrlString = question.videoUrl, let videoUrl = URL(string: videoUrlString) {
                                    VideoPlayer(player: AVPlayer(url: videoUrl))
                                        .frame(height: 200)
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                }
                                
                                // Título das alternativas
                                Text("Alternativas")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                
                                // Alternativas simplificadas
                                VStack(spacing: 10) {
                                    ForEach(question.options.indices, id: \.self) { index in
                                        simpleOptionButton(
                                            option: question.options[index],
                                            index: index,
                                            isSelected: selectedOption == index,
                                            isCorrect: showingExplanation ? index == question.correctOption : nil,
                                            isNullified: question.isNullified
                                        ) {
                                            if !showingExplanation {
                                                handleOptionSelected(question: question, index: index, proxy: proxy)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // Explicação (se visível)
                                if showingExplanation {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Explicação")
                                            .font(.headline)
                                            .foregroundColor(.orange)
                                            .id("explanationHeader") // ID para rolagem
                                        
                                        if question.isNullified {
                                            Text("Esta questão foi anulada. Qualquer resposta será considerada correta.")
                                                .font(.subheadline)
                                                .foregroundColor(.orange)
                                                .padding()
                                                .background(Color.orange.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                        
                                        Text(question.explanation)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding()
                                    .background(Color.yellow.opacity(0.1))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                                
                                // Espaço para garantir que o conteúdo não seja coberto pela barra de navegação
                                Spacer(minLength: 80)
                            }
                            .padding(.bottom, 50)
                            .onAppear {
                                // Armazenar a referência para o ScrollViewProxy
                                scrollProxy = proxy
                                
                                // Rolar para o topo ao carregar uma nova questão
                                withAnimation {
                                    proxy.scrollTo("questionHeader", anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
            
            // Barra de navegação inferior sobreposta ao conteúdo
            VStack {
                Spacer()
                navigationButtons
            }
            
            // Confetti para respostas corretas
            if showConfetti {
                ExamConfettiView()
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            setupOnAppear()
        }
        .onChange(of: viewModel.currentQuestionIndex) { _ in
            selectedOption = viewModel.userAnswers[viewModel.currentQuestion?.id ?? 0]
            
            // Rolar para o topo quando mudar de questão
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    scrollProxy?.scrollTo("questionHeader", anchor: .top)
                }
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            createActionSheet()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Componentes
    
    // Cabeçalho com cronômetro e número da questão
    private var headerView: some View {
        ZStack {
            HStack {
                Label(
                    formattedTime(viewModel.elapsedTime),
                    systemImage: "clock.fill"
                )
                .font(.headline)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                }
            }
            
            if let exam = viewModel.currentExam {
                Text("\(viewModel.currentQuestionIndex + 1)/\(exam.questions.count)")
                    .font(.headline)
            }
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
    
    // Barra de progresso simplificada
    private var progressBarView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                if let exam = viewModel.currentExam {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(
                            width: geometry.size.width * CGFloat(viewModel.currentQuestionIndex + 1) / CGFloat(exam.questions.count),
                            height: 4
                        )
                }
            }
        }
        .frame(height: 4)
    }
    
    // Alternativa simplificada
    private func simpleOptionButton(
        option: String,
        index: Int,
        isSelected: Bool,
        isCorrect: Bool?,
        isNullified: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let letters = ["A", "B", "C", "D"]
        
        // Determinar as cores
        let backgroundColor: Color
        let textColor: Color
        let borderColor: Color
        
        if let isCorrect = isCorrect {
            if isNullified {
                backgroundColor = Color.orange.opacity(0.1)
                textColor = .primary
                borderColor = .orange
            } else if isCorrect {
                backgroundColor = Color.green.opacity(0.1)
                textColor = .primary
                borderColor = .green
            } else if isSelected {
                backgroundColor = Color.red.opacity(0.1)
                textColor = .primary
                borderColor = .red
            } else {
                backgroundColor = Color.white
                textColor = .primary
                borderColor = Color.gray.opacity(0.3)
            }
        } else {
            if isSelected {
                backgroundColor = Color.blue.opacity(0.1)
                textColor = .primary
                borderColor = .blue
            } else {
                backgroundColor = Color.white
                textColor = .primary
                borderColor = Color.gray.opacity(0.3)
            }
        }
        
        return Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Letra da opção
                ZStack {
                    Circle()
                        .fill(isSelected ? .blue : Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Text(letters[index])
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                // Texto da opção
                Text(option)
                    .font(.body)
                    .foregroundColor(textColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Ícone de status
                if isSelected, let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isCorrect != nil)
    }
    
    // Botões de navegação
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
                .padding(.horizontal, 16)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(25)
            }
            .disabled(viewModel.currentQuestionIndex == 0)
            .opacity(viewModel.currentQuestionIndex == 0 ? 0.5 : 1)
            
            Spacer()
            
            // Botão Próxima
            if showingExplanation {
                Button(action: {
                    navigateToNextQuestion()
                }) {
                    HStack {
                        Text(isLastQuestion ? "Finalizar" : "Próxima")
                        Image(systemName: isLastQuestion ? "checkmark" : "chevron.right")
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -3)
    }
    
    // MARK: - Funções Auxiliares
    
    private func setupOnAppear() {
        selectedOption = viewModel.userAnswers[viewModel.currentQuestion?.id ?? 0]
        impactMedium.prepare()
        impactLight.prepare()
        notificationFeedback.prepare()
    }
    
    // Modificado para incluir a rolagem para a explicação
    private func handleOptionSelected(question: Question, index: Int, proxy: ScrollViewProxy) {
        // Feedback háptico
        impactMedium.impactOccurred()
        
        // Feedback de acerto/erro
        if viewModel.isAnswerCorrect(questionId: question.id, optionIndex: index) {
            notificationFeedback.notificationOccurred(.success)
            
            // Mostrar confete para respostas corretas
            withAnimation {
                showConfetti = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showConfetti = false
                }
            }
        } else {
            notificationFeedback.notificationOccurred(.error)
        }
        
        // Atualizar estado
        selectedOption = index
        viewModel.selectAnswer(questionId: question.id, optionIndex: index)
        
        // Mostrar explicação com animação
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showingExplanation = true
        }
        
        // Rolar para a explicação com um leve atraso
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                proxy.scrollTo("explanationHeader", anchor: .top)
            }
        }
    }
    
    private func navigateToPreviousQuestion() {
        impactLight.impactOccurred()
        showingExplanation = false
        
        withAnimation {
            viewModel.moveToPreviousQuestion()
        }
        
        selectedOption = viewModel.userAnswers[viewModel.currentQuestion?.id ?? 0]
    }
    
    private func navigateToNextQuestion() {
        impactLight.impactOccurred()
        
        if isLastQuestion {
            showingActionSheet = true
        } else {
            showingExplanation = false
            selectedOption = nil
            
            withAnimation {
                viewModel.moveToNextQuestion()
            }
        }
    }
    
    private var isLastQuestion: Bool {
        guard let exam = viewModel.currentExam else { return false }
        return viewModel.currentQuestionIndex == exam.questions.count - 1
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
    
    private func finishExam() {
        if let completedExam = viewModel.finishExam(),
           let examId = viewModel.currentExam?.id {
            dataManager.saveCompletedExam(completedExam)
            dataManager.removeInProgressExam(examId: examId)
            presentationMode.wrappedValue.dismiss()
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
