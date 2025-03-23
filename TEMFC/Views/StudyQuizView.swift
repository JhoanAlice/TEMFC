import SwiftUI
import AVKit

struct StudyQuizView: View {
    let selectedTags: [String]
    let quizSize: Int
    
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = StudyQuizViewModel()
    @State private var selectedOption: Int? = nil
    @State private var showingExplanation = false
    
    var body: some View {
        VStack {
            // Cabeçalho
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Fechar")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Text("Questão \(viewModel.currentQuestionIndex + 1) de \(viewModel.questions.count)")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    viewModel.finishQuiz()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Finalizar")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            if !viewModel.questions.isEmpty,
               let question = viewModel.questions[safe: viewModel.currentQuestionIndex] {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Exibição das tags da questão
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(question.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.bottom, 8)
                        
                        // Enunciado da questão
                        Text(question.statement)
                            .font(.body)
                            .padding(.bottom, 8)
                        
                        // Player de vídeo, se houver URL válida
                        if let videoUrlString = question.videoUrl,
                           let videoUrl = URL(string: videoUrlString) {
                            VideoPlayer(player: AVPlayer(url: videoUrl))
                                .frame(height: 200)
                                .cornerRadius(8)
                                .padding(.bottom, 8)
                        }
                        
                        // Exibição das opções de resposta usando EnhancedOptionButton
                        ForEach(question.options.indices, id: \.self) { index in
                            EnhancedOptionButton(
                                option: question.options[index],
                                index: index,
                                selectedIndex: selectedOption,
                                correctIndex: showingExplanation ? question.correctOption : nil,
                                isNullified: question.isNullified
                            ) {
                                if !showingExplanation {
                                    selectedOption = index
                                    viewModel.answerCurrentQuestion(optionIndex: index)
                                    showingExplanation = true
                                }
                            }
                        }
                        
                        // Seção de explicação
                        if showingExplanation {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Explicação")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                if question.isNullified {
                                    Text("Esta questão foi anulada. Qualquer resposta será considerada correta.")
                                        .font(.callout)
                                        .foregroundColor(.orange)
                                        .padding(.bottom, 4)
                                }
                                
                                Text(question.explanation)
                                    .font(.body)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                }
                
                // Botões de navegação
                HStack {
                    Button(action: {
                        showingExplanation = false
                        selectedOption = nil
                        viewModel.previousQuestion()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Anterior")
                        }
                        .padding()
                        .foregroundColor(.blue)
                    }
                    .disabled(viewModel.currentQuestionIndex == 0)
                    
                    Spacer()
                    
                    if showingExplanation {
                        Button(action: {
                            showingExplanation = false
                            selectedOption = nil
                            
                            if viewModel.currentQuestionIndex == viewModel.questions.count - 1 {
                                viewModel.finishQuiz()
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                viewModel.nextQuestion()
                            }
                        }) {
                            HStack {
                                Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Finalizar" : "Próxima")
                                if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .padding()
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)
                .background(Color.white)
                .shadow(color: Color.gray.opacity(0.2), radius: 2, x: 0, y: -2)
            } else {
                // Mensagem para quando não há questões disponíveis
                VStack {
                    Text("Nenhuma questão encontrada para as categorias selecionadas.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Voltar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            // Utiliza o parâmetro quizSize para carregar as questões dinamicamente
            viewModel.loadQuestions(from: dataManager.exams, with: selectedTags, size: quizSize)
        }
        .onChange(of: viewModel.currentQuestionIndex) { _ in
            selectedOption = viewModel.userAnswers[safe: viewModel.currentQuestionIndex]
        }
    }
}

// Extensão para acesso seguro a coleções
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview
struct StudyQuizView_Previews: PreviewProvider {
    static var previews: some View {
        let dataManager = DataManager()
        return StudyQuizView(
            selectedTags: ["Saúde da Mulher", "Saúde Mental"],
            quizSize: 5
        )
        .environmentObject(dataManager)
    }
}
// MARK: - StudyTagSelectionRow
struct StudyTagSelectionRow: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(tag)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.system(size: 22))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: isSelected ? Color.blue.opacity(0.1) : Color.black.opacity(0.05),
                        radius: isSelected ? 6 : 4,
                        x: 0,
                        y: isSelected ? 3 : 2)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        )
    }
}
