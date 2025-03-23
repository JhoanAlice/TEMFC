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
                        
                        // Player de vídeo, se disponível
                        if let videoUrlString = question.videoUrl,
                           let videoUrl = URL(string: videoUrlString) {
                            VideoPlayer(player: AVPlayer(url: videoUrl))
                                .frame(height: 200)
                                .cornerRadius(8)
                                .padding(.bottom, 8)
                        }
                        
                        // Opções de resposta
                        ForEach(question.options.indices, id: \.self) { index in
                            OptionButtonView(
                                option: question.options[index],
                                index: index,
                                selectedIndex: selectedOption,
                                correctIndex: showingExplanation ? question.correctOption : nil,
                                isNullified: question.isNullified
                            ) {
                                if !showingExplanation {
                                    selectedOption = index
                                    viewModel.answerCurrentQuestion(optionIndex: index)
                                }
                            }
                        }
                        
                        // Exibição da explicação
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
                    
                    if !showingExplanation && selectedOption != nil {
                        Button(action: {
                            showingExplanation = true
                        }) {
                            Text("Ver Explicação")
                                .padding()
                                .foregroundColor(.green)
                        }
                    } else if showingExplanation {
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
            viewModel.loadQuestions(from: dataManager.exams, with: selectedTags, size: quizSize)
        }
        .onChange(of: viewModel.currentQuestionIndex) { oldValue, newValue in
            selectedOption = viewModel.userAnswers[safe: newValue]
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
