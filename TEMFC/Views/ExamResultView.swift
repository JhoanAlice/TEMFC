import SwiftUI

struct ExamResultView: View {
    let completedExam: CompletedExam
    @EnvironmentObject var dataManager: DataManager
    
    private var exam: Exam? {
        dataManager.exams.first(where: { $0.id == completedExam.examId })
    }
    
    init(completedExam: CompletedExam) {
        self.completedExam = completedExam
        print("ExamResultView inicializado com score: \(completedExam.score)%")
        print("Respostas: \(completedExam.answers.count)")
        print("Tempo: \(formattedTime(completedExam.timeSpent))")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Resultado do Simulado")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let exam = exam {
                        Text(exam.name)
                            .font(.headline)
                        
                        Text(exam.type.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                // Score card com animação
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Pontuação")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(String(format: "%.1f%%", completedExam.score))
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(completedExam.score >= 60 ? .green : .red)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Tempo Total")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(formattedTime(completedExam.timeSpent))
                                .font(.system(size: 24, weight: .semibold))
                        }
                    }
                    
                    // Barra de progresso animada
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geometry.size.width, height: 10)
                                .opacity(0.3)
                                .foregroundColor(Color.gray)
                            
                            Rectangle()
                                .frame(width: min(CGFloat(completedExam.score) / 100.0 * geometry.size.width, geometry.size.width), height: 10)
                                .foregroundColor(completedExam.score >= 60 ? .green : .red)
                                // Animação aplicada à barra de progresso
                                .animation(.easeInOut(duration: 1), value: completedExam.score)
                        }
                        .cornerRadius(5)
                    }
                    .frame(height: 10)
                    
                    // Status de aprovação
                    HStack {
                        Image(systemName: completedExam.score >= 60 ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(completedExam.score >= 60 ? .green : .red)
                        
                        Text(completedExam.score >= 60 ? "Aprovado" : "Reprovado")
                            .font(.headline)
                            .foregroundColor(completedExam.score >= 60 ? .green : .red)
                        
                        Spacer()
                        
                        Text("Mínimo necessário: 60%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                // Animação aplicada ao card
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: true)
                
                // Performance por categoria
                if let exam = exam {
                    PerformanceByCategoryView(completedExam: completedExam, exam: exam)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Resultados")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct PerformanceByCategoryView: View {
    let completedExam: CompletedExam
    let exam: Exam
    
    // Extrai as tags únicas das questões
    private var uniqueTags: [String] {
        var tags = Set<String>()
        for question in exam.questions {
            for tag in question.tags {
                tags.insert(tag)
            }
        }
        return Array(tags).sorted()
    }
    
    // Calcula o desempenho por tag
    private func performanceByTag(_ tag: String) -> (correct: Int, total: Int, percentage: Double) {
        var correctCount = 0
        var totalCount = 0
        
        for question in exam.questions {
            if question.tags.contains(tag) {
                totalCount += 1
                
                if let answer = completedExam.answers.first(where: { $0.questionId == question.id }),
                   answer.isCorrect {
                    correctCount += 1
                }
            }
        }
        
        let percentage = totalCount > 0 ? (Double(correctCount) / Double(totalCount) * 100) : 0
        return (correctCount, totalCount, percentage)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Desempenho por Categoria")
                .font(.headline)
                .padding(.top, 8)
            
            ForEach(uniqueTags, id: \.self) { tag in
                let performance = performanceByTag(tag)
                
                if performance.total > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(tag)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(performance.correct)/\(performance.total)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 8) {
                            ProgressView(value: performance.percentage / 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: progressColor(performance.percentage)))
                            
                            Text(String(format: "%.1f%%", performance.percentage))
                                .font(.caption)
                                .foregroundColor(progressColor(performance.percentage))
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
    }
    
    private func progressColor(_ percentage: Double) -> Color {
        if percentage >= 80 {
            return .green
        } else if percentage >= 60 {
            return .blue
        } else if percentage >= 40 {
            return .orange
        } else {
            return .red
        }
    }
}
