import SwiftUI

struct ExamDetailView: View {
    let exam: Exam
    @StateObject private var viewModel = ExamViewModel()
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingResumeAlert = false
    @State private var isButtonPressed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Cabeçalho
                VStack(spacing: 16) {
                    Image(systemName: exam.type == .theoretical ? "doc.text.fill" : "video.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.blue)
                    
                    VStack(spacing: 8) {
                        Text(exam.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(exam.type.rawValue)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .accessibilityIdentifier("examDetailHeader")
                
                // Informações do exame
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        InfoCard(
                            icon: "list.number",
                            title: "Questões",
                            value: "\(exam.totalQuestions)"
                        )
                        .accessibilityIdentifier("questionsInfoCard")
                        
                        InfoCard(
                            icon: "clock",
                            title: "Tempo Médio",
                            value: examAverageTime
                        )
                        .accessibilityIdentifier("averageTimeInfoCard")
                    }
                    
                    Text("Sobre este Simulado")
                        .font(.headline)
                        .padding(.top, 8)
                        .accessibilityIdentifier("aboutExamTitle")
                    
                    Text("Esta prova simula com fidelidade o formato oficial do exame TEMFC. As questões são baseadas em situações clínicas reais e seguem o conteúdo programático definido pela SBMFC.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("aboutExamDescription")
                    
                    if exam.type == .theoretical_practical {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Esta prova inclui questões com vídeos que reproduzem situações clínicas. Certifique-se de que seu dispositivo tem som disponível.")
                                .font(.callout)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .accessibilityIdentifier("videoWarning")
                    }
                    
                    // Áreas Temáticas (Tags)
                    Text("Áreas Temáticas")
                        .font(.headline)
                        .padding(.top, 8)
                        .accessibilityIdentifier("tagsTitle")
                    
                    TagsCloudView(tags: uniqueTags)
                        .accessibilityIdentifier("tagsCloudView")
                    
                    // Histórico e melhor pontuação
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tentativas Anteriores")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(previousAttempts)")
                                .font(.headline)
                        }
                        .accessibilityIdentifier("previousAttemptsInfo")
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Melhor Pontuação")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(bestScore.isEmpty ? "--" : bestScore)
                                .font(.headline)
                                .foregroundColor(bestScoreColor)
                        }
                        .accessibilityIdentifier("bestScoreInfo")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Botões de ação – Iniciar ou Continuar Simulado
                VStack(spacing: 16) {
                    if let inProgressExam = dataManager.getInProgressExam(examId: exam.id) {
                        // Exame em andamento encontrado
                        Button(action: {
                            showingResumeAlert = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Continuar Simulado")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .accessibilityIdentifier("continueExamButton")
                        
                        // Informações sobre o exame em andamento
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Progresso atual:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(inProgressExam.userAnswers.count) de \(exam.totalQuestions) questões respondidas")
                                    .font(.subheadline)
                            }
                            .accessibilityIdentifier("inProgressInfo")
                            
                            Spacer()
                            
                            Text("Tempo: \(formattedTime(inProgressExam.elapsedTime))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .accessibilityIdentifier("elapsedTimeInfo")
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    } else {
                        // Nenhum exame em andamento - Botão Iniciar Simulado
                        Button(action: {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            
                            viewModel.startExam(exam: exam)
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Iniciar Simulado")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .accessibilityIdentifier("startExamButton")
                            // Efeito de escala ao pressionar
                            .scaleEffect(isButtonPressed ? 0.96 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isButtonPressed)
                        }
                        .padding(.top, 20)
                        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: 50, pressing: { pressing in
                            isButtonPressed = pressing
                        }, perform: {})
                    }
                }
                .padding(.top, 20)
                .alert(isPresented: $showingResumeAlert) {
                    Alert(
                        title: Text("Continuar Simulado?"),
                        message: Text("Você quer continuar o simulado de onde parou ou iniciar um novo?"),
                        primaryButton: .default(Text("Continuar")) {
                            if let inProgressExam = dataManager.getInProgressExam(examId: exam.id) {
                                viewModel.loadInProgressExam(inProgressExam: inProgressExam, exam: exam)
                            }
                        },
                        secondaryButton: .destructive(Text("Novo Simulado")) {
                            dataManager.removeInProgressExam(examId: exam.id)
                            viewModel.startExam(exam: exam)
                        }
                    )
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.isExamActive) {
            if let completedExam = viewModel.completedExam {
                ExamResultView(completedExam: completedExam)
                    .environmentObject(dataManager)
            } else {
                ExamSessionView(viewModel: viewModel)
                    .environmentObject(dataManager)
            }
        }
    }
    
    // Calcula as tags únicas neste exame
    private var uniqueTags: [String] {
        var tags = Set<String>()
        for question in exam.questions {
            for tag in question.tags {
                tags.insert(tag)
            }
        }
        return Array(tags).sorted()
    }
    
    // Número de tentativas anteriores
    private var previousAttempts: Int {
        dataManager.completedExams.filter { $0.examId == exam.id }.count
    }
    
    // Melhor pontuação
    private var bestScore: String {
        guard let best = dataManager.completedExams
                .filter({ $0.examId == exam.id })
                .max(by: { $0.score < $1.score }) else {
            return ""
        }
        return String(format: "%.1f%%", best.score)
    }
    
    // Cor para a melhor pontuação
    private var bestScoreColor: Color {
        guard let best = dataManager.completedExams
                .filter({ $0.examId == exam.id })
                .max(by: { $0.score < $1.score }) else {
            return .primary
        }
        return best.score >= 60 ? .green : .red
    }
    
    // Tempo médio para fazer o exame
    private var examAverageTime: String {
        let completedExams = dataManager.completedExams.filter { $0.examId == exam.id }
        guard !completedExams.isEmpty else {
            return "--:--"
        }
        let totalTime = completedExams.reduce(0) { $0 + $1.timeSpent }
        let averageSeconds = totalTime / Double(completedExams.count)
        let hours = Int(averageSeconds) / 3600
        let minutes = Int(averageSeconds) / 60 % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct ExamDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExamDetailView(exam: Exam(
            id: "EX1",
            name: "Exemplo de Prova",
            type: .theoretical,
            totalQuestions: 20,
            questions: [
                Question(
                    id: 1,
                    number: 1,
                    statement: "Exemplo de questão.",
                    options: ["Opção A", "Opção B", "Opção C", "Opção D"],
                    correctOption: 0,
                    explanation: "Esta é a explicação da questão.",
                    tags: ["Tag1", "Tag2"]
                )
            ]
        ))
        .environmentObject(DataManager())
    }
}
