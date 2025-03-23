import SwiftUI

struct PerformanceView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Overall stats
                    OverallStatsView()
                        .environmentObject(dataManager)
                    
                    // Performance by exam type
                    ExamTypePerformanceView()
                        .environmentObject(dataManager)
                    
                    // Nova seção de simulados concluídos com filtro por tipo
                    CompletedExamsSection()
                        .environmentObject(dataManager)
                    
                    // Performance chart by tag
                    TagPerformanceView()
                        .environmentObject(dataManager)
                }
                .padding()
            }
            .navigationTitle("Meu Desempenho")
        }
    }
}

struct OverallStatsView: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var totalExams: Int {
        dataManager.completedExams.count
    }
    
    private var averageScore: Double {
        guard !dataManager.completedExams.isEmpty else { return 0 }
        let sum = dataManager.completedExams.reduce(0) { $0 + $1.score }
        return sum / Double(dataManager.completedExams.count)
    }
    
    private var bestExam: (CompletedExam, Exam)? {
        guard let bestCompleted = dataManager.completedExams.max(by: { $0.score < $1.score }),
              let exam = dataManager.exams.first(where: { $0.id == bestCompleted.examId }) else {
            return nil
        }
        return (bestCompleted, exam)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estatísticas Gerais")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Simulados",
                    value: "\(totalExams)",
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Média",
                    value: String(format: "%.1f%%", averageScore),
                    icon: "chart.bar.fill",
                    color: averageScore >= 60 ? .green : .red
                )
            }
            
            if let (bestCompleted, exam) = bestExam {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Melhor Desempenho")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exam.name)
                                .font(.headline)
                            
                            Text(exam.type.rawValue)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(String(format: "%.1f%%", bestCompleted.score))
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text(formattedDate(bestCompleted.endTime))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ExamTypePerformanceView: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var theoreticalPerformance: Double {
        let exams = dataManager.getCompletedExamsByType(type: .theoretical)
        guard !exams.isEmpty else { return 0 }
        return exams.reduce(0) { $0 + $1.score } / Double(exams.count)
    }
    
    private var practicalPerformance: Double {
        let exams = dataManager.getCompletedExamsByType(type: .theoretical_practical)
        guard !exams.isEmpty else { return 0 }
        return exams.reduce(0) { $0 + $1.score } / Double(exams.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Desempenho por Tipo de Prova")
                .font(.headline)
            
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Prova Teórica")
                        .font(.subheadline)
                    HStack {
                        Text(String(format: "%.1f%%", theoreticalPerformance))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(theoreticalPerformance >= 60 ? .green : .red)
                        Spacer()
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                    }
                    ProgressView(value: theoreticalPerformance / 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: theoreticalPerformance >= 60 ? .green : .red))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Prova Teórico-Prática")
                        .font(.subheadline)
                    HStack {
                        Text(String(format: "%.1f%%", practicalPerformance))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(practicalPerformance >= 60 ? .green : .red)
                        Spacer()
                        Image(systemName: "video.fill")
                            .foregroundColor(.blue)
                    }
                    ProgressView(value: practicalPerformance / 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: practicalPerformance >= 60 ? .green : .red))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct TagPerformanceView: View {
    @EnvironmentObject var dataManager: DataManager
    
    private var tagPerformance: [(tag: String, percentage: Double)] {
        var tagScores: [String: (correct: Int, total: Int)] = [:]
        for completedExam in dataManager.completedExams {
            if let exam = dataManager.exams.first(where: { $0.id == completedExam.examId }) {
                for answer in completedExam.answers {
                    if let question = exam.questions.first(where: { $0.id == answer.questionId }) {
                        for tag in question.tags {
                            var current = tagScores[tag] ?? (0, 0)
                            current.total += 1
                            if answer.isCorrect {
                                current.correct += 1
                            }
                            tagScores[tag] = current
                        }
                    }
                }
            }
        }
        return tagScores.map { (tag, scores) in
            let percentage = scores.total > 0 ? Double(scores.correct) / Double(scores.total) * 100 : 0
            return (tag, percentage)
        }.sorted { $0.percentage > $1.percentage }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Desempenho por Área Temática")
                .font(.headline)
            
            if tagPerformance.isEmpty {
                Text("Complete simulados para ver seu desempenho por área temática.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(tagPerformance.prefix(5).enumerated()), id: \.element.tag) { indexElement in
                        let index = indexElement.offset
                        let item = indexElement.element
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.tag)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Spacer()
                                Text(String(format: "%.1f%%", item.percentage))
                                    .font(.subheadline)
                                    .foregroundColor(progressColor(item.percentage))
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: 6)
                                        .opacity(0.3)
                                        .foregroundColor(Color.gray)
                                    Rectangle()
                                        .frame(width: min(CGFloat(item.percentage) / 100.0 * geometry.size.width, geometry.size.width), height: 6)
                                        .foregroundColor(progressColor(item.percentage))
                                        .animation(.easeInOut(duration: 1), value: item.percentage)
                                }
                                .cornerRadius(3)
                            }
                            .frame(height: 6)
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.1), value: tagPerformance.count)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
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

struct CompletedExamsSection: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedType: Exam.ExamType? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Simulados Concluídos")
                .font(.headline)
            
            Picker("Tipo de Prova", selection: $selectedType) {
                Text("Todos").tag(nil as Exam.ExamType?)
                ForEach(Exam.ExamType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type as Exam.ExamType?)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 8)
            
            if filteredCompletedExams.isEmpty {
                Text("Nenhum simulado concluído")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                ForEach(filteredCompletedExams) { completedExam in
                    NavigationLink(destination: ExamResultView(completedExam: completedExam)) {
                        CompletedExamCard(completedExam: completedExam)
                    }
                }
            }
        }
    }
    
    private var filteredCompletedExams: [CompletedExam] {
        if let type = selectedType {
            let examIds = dataManager.exams.filter { $0.type == type }.map { $0.id }
            return dataManager.completedExams
                .filter { examIds.contains($0.examId) }
                .sorted { $0.endTime > $1.endTime }
        } else {
            return dataManager.completedExams.sorted { $0.endTime > $1.endTime }
        }
    }
}

struct CompletedExamCard: View {
    let completedExam: CompletedExam
    @EnvironmentObject var dataManager: DataManager
    
    private var exam: Exam? {
        dataManager.exams.first(where: { $0.id == completedExam.examId })
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(exam?.name ?? completedExam.examId)
                    .font(.headline)
                    .foregroundColor(.primary)
                HStack(spacing: 12) {
                    Label(
                        exam?.type.rawValue ?? "",
                        systemImage: exam?.type == .theoretical ? "doc.text" : "video"
                    )
                    .font(.caption)
                    .foregroundColor(.blue)
                    Label(
                        formattedDate(completedExam.endTime),
                        systemImage: "calendar"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(String(format: "%.1f%%", completedExam.score))
                    .font(.title3)
                    .bold()
                    .foregroundColor(completedExam.score >= 60 ? .green : .red)
                Label(
                    formattedTime(completedExam.timeSpent),
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}
