// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/Views/ExamResultView.swift

import SwiftUI

struct ExamResultView: View {
    let completedExam: CompletedExam
    @EnvironmentObject var dataManager: DataManager
    @State private var animateChart = false
    @State private var showConfetti = false
    
    private var exam: Exam? {
        dataManager.exams.first(where: { $0.id == completedExam.examId })
    }
    
    init(completedExam: CompletedExam) {
        self.completedExam = completedExam
    }
    
    // Propriedade atualizada para usar o número real de questões
    private var totalQuestions: Int {
        return completedExam.actualQuestionCount
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header com informações gerais
                headerView
                
                // Card de pontuação com animação
                scoreCardView
                
                // Performance por categoria
                if let exam = exam {
                    PerformanceByCategoryView(completedExam: completedExam, exam: exam)
                }
                
                // Botões de ação
                actionButtonsView
                
                // Espaço para garantir que o conteúdo não seja coberto
                Spacer().frame(height: 30)
            }
            .padding()
        }
        .background(TEMFCDesign.Colors.groupedBackground.ignoresSafeArea())
        .navigationTitle("Resultados")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Animar componentes ao aparecer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                    animateChart = true
                }
                
                // Mostrar confetti para aprovação
                if completedExam.score >= 60 {
                    showConfetti = true
                    
                    // Remover confetti após alguns segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        showConfetti = false
                    }
                }
            }
        }
        .overlay(
            Group {
                if showConfetti {
                    ExamConfettiView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
        )
    }
    
    // Cabeçalho com informações gerais
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Informações da prova
            if let exam = exam {
                Text(exam.name)
                    .font(TEMFCDesign.Typography.title2)
                    .foregroundColor(TEMFCDesign.Colors.text)
                
                HStack(spacing: 12) {
                    // Tipo de prova
                    HStack(spacing: 5) {
                        Image(systemName: exam.type == .theoretical ? "doc.text.fill" : "video.fill")
                            .foregroundColor(TEMFCDesign.Colors.primary)
                        
                        Text(exam.type.rawValue)
                            .font(TEMFCDesign.Typography.subheadline)
                            .foregroundColor(TEMFCDesign.Colors.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(TEMFCDesign.Colors.primary.opacity(0.1))
                    )
                    
                    // Data de realização
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .foregroundColor(TEMFCDesign.Colors.secondaryText)
                        
                        Text(formattedDate(completedExam.endTime))
                            .font(TEMFCDesign.Typography.caption)
                            .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                .fill(TEMFCDesign.Colors.background)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    // Card de pontuação com animação
    private var scoreCardView: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                // Pontuação
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sua pontuação")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(String(format: "%.1f", animateChart ? completedExam.score : 0))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(scoreColor)
                        
                        Text("%")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(scoreColor)
                            .padding(.leading, 2)
                    }
                    .animation(.spring(response: 1.5, dampingFraction: 0.8), value: animateChart)
                }
                
                Spacer()
                
                // Status de aprovação
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Status")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    
                    HStack {
                        Image(systemName: completedExam.score >= 60 ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .font(.system(size: 20))
                        
                        Text(completedExam.score >= 60 ? "Aprovado" : "Reprovado")
                            .font(TEMFCDesign.Typography.headline)
                    }
                    .foregroundColor(scoreColor)
                }
            }
            
            // Tempo de realização
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
                
                Text("Tempo de realização:")
                    .font(TEMFCDesign.Typography.callout)
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
                
                Spacer()
                
                Text(formattedTime(completedExam.timeSpent))
                    .font(TEMFCDesign.Typography.headline)
                    .monospacedDigit()
                    .foregroundColor(TEMFCDesign.Colors.text)
            }
            
            // Barra de progresso
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Fundo
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 14)
                        
                        // Progresso
                        RoundedRectangle(cornerRadius: 8)
                            .fill(scoreColor)
                            .frame(
                                width: animateChart ?
                                    min(CGFloat(completedExam.score) / 100.0 * geometry.size.width,
                                        geometry.size.width) : 0,
                                height: 14
                            )
                        
                        // Linha de 60% (aprovação)
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 2, height: 20)
                            .position(x: geometry.size.width * 0.6, y: 7)
                    }
                }
                .frame(height: 14)
                
                // Linha de aprovação
                HStack {
                    Text("0%")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    
                    Spacer()
                    
                    Text("Aprovação: 60%")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                        .position(x: 0, y: 0)
                    
                    Spacer()
                    
                    Text("100%")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                }
            }
            
            // Resumo de respostas
            HStack(spacing: 20) {
                // Acertos
                VStack(spacing: 4) {
                    Text(String(correctAnswers))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Text("Acertos")
                        .font(TEMFCDesign.Typography.footnote)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                
                // Erros
                VStack(spacing: 4) {
                    Text(String(wrongAnswers))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                    
                    Text("Erros")
                        .font(TEMFCDesign.Typography.footnote)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                
                // Total
                VStack(spacing: 4) {
                    Text(String(totalQuestions))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(TEMFCDesign.Colors.text)
                    
                    Text("Total")
                        .font(TEMFCDesign.Typography.footnote)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                .fill(TEMFCDesign.Colors.background)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    // Botões de ação
    private var actionButtonsView: some View {
        HStack(spacing: 16) {
            // Botão de compartilhar resultados
            Button(action: {
                shareResults()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Compartilhar")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                        .fill(TEMFCDesign.Colors.background)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                .foregroundColor(TEMFCDesign.Colors.primary)
            }
            
            // Botão de refazer simulado
            Button(action: {
                // Implementar ação de refazer simulado
                // Isso seria feito adicionando navegação para iniciar o mesmo exame
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refazer")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                        .fill(TEMFCDesign.Colors.primary)
                        .shadow(color: TEMFCDesign.Colors.primary.opacity(0.3), radius: 5, x: 0, y: 2)
                )
                .foregroundColor(.white)
            }
        }
    }
    
    // Propriedades calculadas
    private var scoreColor: Color {
        if completedExam.score >= 60 {
            return .green
        } else {
            return .red
        }
    }
    
    private var correctAnswers: Int {
        return completedExam.answers.filter { $0.isCorrect }.count
    }
    
    private var wrongAnswers: Int {
        return completedExam.answers.filter { !$0.isCorrect }.count
    }
    
    // Funções auxiliares
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func shareResults() {
        // Implementação básica para compartilhar resultados
        var textToShare = "Resultado TEMFC - \(exam?.name ?? "Simulado")\n"
        textToShare += "Pontuação: \(String(format: "%.1f%%", completedExam.score))\n"
        textToShare += "Status: \(completedExam.score >= 60 ? "Aprovado" : "Reprovado")\n"
        textToShare += "Tempo: \(formattedTime(completedExam.timeSpent))"
        
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

struct ExamResultView_Previews: PreviewProvider {
    static var previews: some View {
        let dataManager = DataManager()
        
        // Criar um exame e completedExam de exemplo para o preview
        let sampleQuestion = Question(
            id: 1,
            number: 1,
            statement: "Exemplo",
            options: ["A", "B", "C", "D"],
            correctOption: 0,
            explanation: "Explicação",
            tags: ["Tag1", "Tag2"]
        )
        
        let sampleExam = Exam(
            id: "SAMPLE",
            name: "Exame Exemplo",
            type: .theoretical,
            questions: [sampleQuestion]
        )
        
        let sampleCompletedExam = CompletedExam(
            examId: "SAMPLE",
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date(),
            answers: [
                UserAnswer(
                    questionId: 1,
                    selectedOption: 0,
                    isCorrect: true,
                    examId: "SAMPLE",
                    timestamp: Date()
                )
            ],
            score: 75.0,
            actualQuestionCount: 1 // Parâmetro adicionado
        )
        
        // Adicionar exame ao dataManager para que possa ser encontrado
        dataManager.exams = [sampleExam]
        
        return NavigationView {
            ExamResultView(completedExam: sampleCompletedExam)
                .environmentObject(dataManager)
        }
    }
}

// MARK: - Performance por Categoria
struct PerformanceByCategoryView: View {
    let completedExam: CompletedExam
    let exam: Exam
    @State private var animateProgress = false
    
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Desempenho por Categoria")
                .font(TEMFCDesign.Typography.headline)
                .foregroundColor(TEMFCDesign.Colors.text)
                .padding(.bottom, 4)
            
            ForEach(uniqueTags, id: \.self) { tag in
                let performance = performanceByTag(tag)
                
                if performance.total > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(tag)
                                .font(TEMFCDesign.Typography.subheadline)
                                .lineLimit(1)
                                .foregroundColor(TEMFCDesign.Colors.text)
                            
                            Spacer()
                            
                            Text("\(performance.correct)/\(performance.total)")
                                .font(TEMFCDesign.Typography.subheadline)
                                .foregroundColor(TEMFCDesign.Colors.secondaryText)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Fundo da barra
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 10)
                                
                                // Progresso
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(progressColor(performance.percentage))
                                    .frame(
                                        width: animateProgress ?
                                            min(CGFloat(performance.percentage) / 100.0 * geometry.size.width, geometry.size.width) : 0,
                                        height: 10
                                    )
                            }
                        }
                        .frame(height: 10)
                        
                        HStack {
                            Spacer()
                            Text(String(format: "%.1f%%", performance.percentage))
                                .font(TEMFCDesign.Typography.caption)
                                .foregroundColor(progressColor(performance.percentage))
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                .fill(TEMFCDesign.Colors.background)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                    animateProgress = true
                }
            }
        }
    }
    
    private func progressColor(_ percentage: Double) -> Color {
        if percentage >= 80 {
            return .green
        } else if percentage >= 60 {
            return TEMFCDesign.Colors.primary
        } else if percentage >= 40 {
            return .orange
        } else {
            return .red
        }
    }
}
