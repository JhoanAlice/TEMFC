// TEMFC/Views/ExamProgressView.swift

import SwiftUI

struct ExamProgressView: View {
    @ObservedObject var viewModel: ExamViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let exam = viewModel.currentExam {
                        Text("Progresso do Simulado")
                            .font(.headline)
                        
                        Text("Você respondeu \(answeredCount) de \(exam.questions.count) questões.")
                            .foregroundColor(.secondary)
                        
                        // Barra de progresso
                        ProgressView(value: Double(answeredCount), total: Double(exam.questions.count))
                            .accentColor(.blue)
                            .padding(.bottom, 16)
                        
                        // Lista de questões
                        ForEach(0..<exam.questions.count, id: \.self) { index in
                            let question = exam.questions[index]
                            let answered = viewModel.userAnswers[question.id] != nil
                            
                            Button(action: {
                                viewModel.currentQuestionIndex = index
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Text("Questão \(question.number)")
                                    
                                    Spacer()
                                    
                                    if answered {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Progresso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var answeredCount: Int {
        return viewModel.userAnswers.count
    }
}
