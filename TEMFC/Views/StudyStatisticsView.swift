// Caminho: TEMFC/Views/StudyStatisticsView.swift

import SwiftUI

struct StudyStatisticsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTimeRange: TimeRange = .month
    
    enum TimeRange: String, CaseIterable {
        case week = "Semana"
        case month = "Mês"
        case year = "Ano"
        case all = "Todo o tempo"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Seletor de período
                Picker("Período", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Resumo de estatísticas
                HStack {
                    StatisticCard(title: "Tempo Total", value: formattedTime(totalStudyTime), icon: "clock.fill", color: .blue)
                    StatisticCard(title: "Simulados", value: "\(completedExams.count)", icon: "doc.text.fill", color: .green)
                }
                
                HStack {
                    StatisticCard(title: "Média", value: String(format: "%.1f%%", averageScore), icon: "chart.bar.fill", color: scoreColor)
                    StatisticCard(title: "Questões", value: "\(totalQuestions)", icon: "list.number", color: .orange)
                }
                
                // Gráfico de progresso
                StudyProgressGraph(dataPoints: progressDataPoints)
                    .frame(height: 200)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Categorias mais estudadas
                VStack(alignment: .leading) {
                    Text("Categorias Mais Estudadas")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(topStudiedCategories, id: \.0) { category, count in
                        HStack {
                            Text(category)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("\(count) questões")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                
                // Dias de estudo
                VStack(alignment: .leading) {
                    Text("Dias de Estudo")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        ForEach(0..<7, id: \.self) { index in
                            let date = Calendar.current.date(byAdding: .day, value: -index, to: Date())!
                            let hasStudied = studyDates.contains(Calendar.current.startOfDay(for: date))
                            
                            VStack {
                                Text(dayAbbreviation(date))
                                    .font(.caption)
                                
                                Circle()
                                    .fill(hasStudied ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 24, height: 24)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("Estatísticas de Estudo")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // Exames filtrados por período de tempo selecionado
    private var completedExams: [CompletedExam] {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return dataManager.completedExams.filter { $0.endTime >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return dataManager.completedExams.filter { $0.endTime >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            return dataManager.completedExams.filter { $0.endTime >= yearAgo }
        case .all:
            return dataManager.completedExams
        }
    }
    
    // Tempo total de estudo no período selecionado
    private var totalStudyTime: TimeInterval {
        return completedExams.reduce(0) { $0 + $1.timeSpent }
    }
    
    // Pontuação média no período selecionado
    private var averageScore: Double {
        guard !completedExams.isEmpty else { return 0 }
        return completedExams.reduce(0) { $0 + $1.score } / Double(completedExams.count)
    }
    
    // Total de questões respondidas no período
    private var totalQuestions: Int {
        return completedExams.reduce(0) { $0 + $1.answers.count }
    }
    
    // Cor baseada na pontuação média
    private var scoreColor: Color {
        if averageScore >= 80 {
            return .green
        } else if averageScore >= 60 {
            return .blue
        } else {
            return .red
        }
    }
    
    // Top categorias estudadas
    private var topStudiedCategories: [(String, Int)] {
        var categories: [String: Int] = [:]
        
        for exam in completedExams {
            for answer in exam.answers {
                if let question = dataManager.exams.flatMap({ $0.questions })
                    .first(where: { $0.id == answer.questionId }) {
                    for tag in question.tags {
                        categories[tag, default: 0] += 1
                    }
                }
            }
        }
        
        return categories.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }
    
    // Datas em que o usuário estudou
    private var studyDates: Set<Date> {
        let calendar = Calendar.current
        return Set(completedExams.map { calendar.startOfDay(for: $0.endTime) })
    }
    
    // Dados para o gráfico de progresso
    private var progressDataPoints: [(date: Date, score: Double)] {
        let sortedExams = completedExams.sorted { $0.endTime < $1.endTime }
        return sortedExams.map { (date: $0.endTime, score: $0.score) }
    }
    
    // Formatação de tempo
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Abreviação do dia da semana
    private func dayAbbreviation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// Cartão de estatística
struct StatisticCard: View {
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
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Gráfico de progresso
struct StudyProgressGraph: View {
    let dataPoints: [(date: Date, score: Double)]
    
    var body: some View {
        GeometryReader { geometry in
            if dataPoints.isEmpty {
                Text("Sem dados suficientes para exibir o gráfico")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    // Linhas de grade
                    VStack(spacing: 0) {
                        ForEach(0..<5) { i in
                            Divider()
                                .opacity(0.5)
                                .frame(height: 1)
                            
                            if i < 4 {
                                Spacer()
                            }
                        }
                    }
                    
                    // Pontos e linhas
                    Path { path in
                        for (index, point) in dataPoints.enumerated() {
                            let x = geometry.size.width * (CGFloat(index) / CGFloat(max(dataPoints.count - 1, 1)))
                            let y = geometry.size.height * (1 - CGFloat(point.score / 100))
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                    
                    // Pontos
                    ForEach(0..<dataPoints.count, id: \.self) { index in
                        let point = dataPoints[index]
                        let x = geometry.size.width * (CGFloat(index) / CGFloat(max(dataPoints.count - 1, 1)))
                        let y = geometry.size.height * (1 - CGFloat(point.score / 100))
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                    
                    // Linha de aprovação (60%)
                    let approvalY = geometry.size.height * 0.4 // 100 - 60 = 40%
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: approvalY))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: approvalY))
                    }
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    
                    // Rótulo da linha de aprovação
                    Text("Aprovação (60%)")
                        .font(.caption)
                        .foregroundColor(.green)
                        .position(x: geometry.size.width - 60, y: approvalY - 10)
                }
            }
        }
    }
}
