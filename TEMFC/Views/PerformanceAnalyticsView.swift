import SwiftUI
import Charts

// MARK: - Componente de Detalhe de Desempenho

struct PerformanceDetailCard: View {
    let title: String
    let value: String
    let secondaryValue: String
    let change: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                // Indicador de mudança
                HStack(spacing: 4) {
                    Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    
                    Text("\(abs(change), specifier: "%.1f")%")
                        .font(.caption)
                }
                .foregroundColor(change >= 0 ? .green : .red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(change >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                
                Text(secondaryValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - PerformanceAnalyticsView

struct PerformanceAnalyticsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTimeRange = TimeRange.month
    @State private var selectedMetric = PerformanceMetric.score
    @State private var selectedExamFilter: String? = nil
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Semana"
        case month = "Mês"
        case year = "Ano"
        case all = "Tudo"
        
        var id: String { self.rawValue }
    }
    
    enum PerformanceMetric: String, CaseIterable, Identifiable {
        case score = "Pontuação"
        case time = "Tempo"
        case questionsPerMinute = "Questões por minuto"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Performance Summary Card
                    TEMFCCard(title: "Resumo de Desempenho", systemImage: "medal.fill", accentColor: .orange) {
                        HStack {
                            PerformanceMetricView(
                                value: String(format: "%.1f%%", averageScore),
                                label: "Média Geral",
                                change: "+2.5%",
                                isPositive: true
                            )
                            
                            Divider()
                                .frame(height: 50)
                            
                            PerformanceMetricView(
                                value: String(format: "%.1f", averageQuestionsPerMinute),
                                label: "Quest./Min",
                                change: "+0.3",
                                isPositive: true
                            )
                            
                            Divider()
                                .frame(height: 50)
                            
                            PerformanceMetricView(
                                value: "\(completedExamCount)",
                                label: "Simulados",
                                change: "+3",
                                isPositive: true
                            )
                        }
                    }
                    
                    // Detalhamento do Desempenho (novo componente)
                    PerformanceDetailCard(
                        title: "Pontuação Média",
                        value: String(format: "%.1f%%", averageScore),
                        secondaryValue: "Geral",
                        change: 2.5,
                        icon: "chart.bar.fill",
                        color: .orange
                    )
                    
                    // Main Performance Chart
                    TEMFCCard(title: "Performance ao Longo do Tempo", systemImage: "chart.line.uptrend.xyaxis") {
                        VStack(spacing: 16) {
                            // Chart Controls
                            HStack {
                                // Metric Picker
                                Picker("Metric", selection: $selectedMetric) {
                                    ForEach(PerformanceMetric.allCases) { metric in
                                        Text(metric.rawValue).tag(metric)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.trailing)
                                
                                // Time Range Picker
                                Menu {
                                    ForEach(TimeRange.allCases) { range in
                                        Button {
                                            selectedTimeRange = range
                                        } label: {
                                            Label(range.rawValue, systemImage: selectedTimeRange == range ? "checkmark" : "")
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedTimeRange.rawValue)
                                        Image(systemName: "chevron.down")
                                    }
                                    .frame(minWidth: 80)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(uiColor: .secondarySystemBackground))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Performance Chart
                            if #available(iOS 16.0, *) {
                                PerformanceChart(
                                    dataManager: dataManager,
                                    timeRange: selectedTimeRange,
                                    metric: selectedMetric
                                )
                                .frame(height: 200)
                            } else {
                                Text("Gráfico disponível no iOS 16+")
                                    .foregroundStyle(.secondary)
                                    .frame(height: 200)
                            }
                        }
                    }
                    
                    // Category Performance
                    TEMFCCard(title: "Desempenho por Categoria", systemImage: "tag.fill") {
                        VStack(spacing: 16) {
                            ForEach(topCategoryPerformance().prefix(5), id: \.category) { item in
                                CategoryPerformanceRow(
                                    category: item.category,
                                    percentage: item.percentage,
                                    questionCount: item.questionCount
                                )
                            }
                            
                            NavigationLink {
                                AllCategoriesPerformanceView()
                            } label: {
                                Text("Ver Todas as Categorias")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(uiColor: .secondarySystemBackground))
                                    .foregroundStyle(.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Recent Exams with Performance
                    TEMFCCard(title: "Simulados Recentes", systemImage: "list.clipboard.fill") {
                        VStack(spacing: 12) {
                            ForEach(recentExams().prefix(3), id: \.id) { exam in
                                NavigationLink {
                                    ExamResultPreviewView(completedExam: exam)
                                } label: {
                                    RecentExamRow(
                                        examName: getExamName(exam.examId),
                                        date: exam.endTime,
                                        score: exam.score,
                                        time: exam.timeSpent
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            
                            NavigationLink {
                                ExamHistoryView()
                            } label: {
                                Text("Ver Histórico Completo")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(uiColor: .secondarySystemBackground))
                                    .foregroundStyle(.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Improvement Suggestions
                    TEMFCCard(title: "Recomendações", systemImage: "lightbulb.fill", accentColor: .yellow) {
                        VStack(spacing: 16) {
                            ImprovementSuggestionRow(
                                title: "Foco em Saúde Mental",
                                description: "Seu desempenho está 15% abaixo da média nesta categoria",
                                actionText: "Praticar Agora"
                            )
                            
                            ImprovementSuggestionRow(
                                title: "Revisão Espaçada",
                                description: "Revise as questões erradas dos últimos 3 simulados",
                                actionText: "Iniciar Revisão"
                            )
                            
                            ImprovementSuggestionRow(
                                title: "Aumente o Ritmo",
                                description: "Tente responder mais rápido para melhorar sua velocidade",
                                actionText: "Quiz Cronometrado"
                            )
                        }
                    }
                }
                .padding(.top)
                .padding(.bottom, 24)
            }
            .navigationTitle("Desempenho")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            // Share performance report
                        } label: {
                            Label("Compartilhar Relatório", systemImage: "square.and.arrow.up")
                        }
                        
                        Menu {
                            Button {
                                selectedExamFilter = nil
                            } label: {
                                Label("Todos os Simulados", systemImage: selectedExamFilter == nil ? "checkmark" : "")
                            }
                            
                            ForEach(uniqueExamIds(), id: \.self) { examId in
                                Button {
                                    selectedExamFilter = examId
                                } label: {
                                    Label(getExamName(examId), systemImage: selectedExamFilter == examId ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Label("Filtrar por Simulado", systemImage: "line.3.horizontal.decrease.circle")
                        }
                        
                        Button {
                            // Reset statistics
                        } label: {
                            Label("Redefinir Estatísticas", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties and Methods
    
    private var averageScore: Double {
        let exams = filteredExams()
        guard !exams.isEmpty else { return 0 }
        return exams.reduce(0) { $0 + $1.score } / Double(exams.count)
    }
    
    private var averageQuestionsPerMinute: Double {
        let exams = filteredExams()
        guard !exams.isEmpty else { return 0 }
        
        let totalQuestions = exams.reduce(0) { $0 + $1.answers.count }
        let totalMinutes = exams.reduce(0.0) { $0 + $1.timeSpent / 60.0 }
        
        return totalMinutes > 0 ? Double(totalQuestions) / totalMinutes : 0
    }
    
    private var completedExamCount: Int {
        filteredExams().count
    }
    
    private func filteredExams() -> [CompletedExam] {
        var exams = dataManager.completedExams
        
        if let examId = selectedExamFilter {
            exams = exams.filter { $0.examId == examId }
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
            exams = exams.filter { $0.endTime >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: today)!
            exams = exams.filter { $0.endTime >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: today)!
            exams = exams.filter { $0.endTime >= yearAgo }
        case .all:
            break
        }
        
        return exams
    }
    
    private func topCategoryPerformance() -> [(category: String, percentage: Double, questionCount: Int)] {
        var categoryStats: [String: (correct: Int, total: Int)] = [:]
        
        for completedExam in filteredExams() {
            if let exam = dataManager.exams.first(where: { $0.id == completedExam.examId }) {
                for answer in completedExam.answers {
                    if let question = exam.questions.first(where: { $0.id == answer.questionId }) {
                        for tag in question.tags {
                            var stats = categoryStats[tag] ?? (0, 0)
                            stats.total += 1
                            if answer.isCorrect {
                                stats.correct += 1
                            }
                            categoryStats[tag] = stats
                        }
                    }
                }
            }
        }
        
        return categoryStats
            .filter { $0.value.total >= 5 }
            .map { (category: $0.key,
                   percentage: Double($0.value.correct) / Double($0.value.total) * 100,
                   questionCount: $0.value.total) }
            .sorted { $0.percentage > $1.percentage }
    }
    
    private func recentExams() -> [CompletedExam] {
        return dataManager.completedExams.sorted { $0.endTime > $1.endTime }
    }
    
    private func getExamName(_ examId: String) -> String {
        dataManager.exams.first { $0.id == examId }?.name ?? examId
    }
    
    private func uniqueExamIds() -> [String] {
        Array(Set(dataManager.completedExams.map { $0.examId })).sorted()
    }
}

// MARK: - Supporting Components

struct PerformanceMetricView: View {
    let value: String
    let label: String
    let change: String
    let isPositive: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 3) {
                Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    .font(.system(size: 8))
                
                Text(change)
                    .font(.caption2)
            }
            .foregroundStyle(isPositive ? .green : .red)
        }
        .frame(maxWidth: .infinity)
    }
}

@available(iOS 16.0, *)
struct PerformanceChart: View {
    let dataManager: DataManager
    let timeRange: PerformanceAnalyticsView.TimeRange
    let metric: PerformanceAnalyticsView.PerformanceMetric
    
    var body: some View {
        let chartData = prepareChartData()
        
        Chart {
            ForEach(chartData, id: \.date) { item in
                LineMark(
                    x: .value("Data", item.date),
                    y: .value("Valor", item.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(gradient)
                .symbol {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .chartYScale(domain: yAxisRange())
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .blue.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func prepareChartData() -> [(date: Date, value: Double)] {
        let calendar = Calendar.current
        let today = Date()
        var startDate: Date
        
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
        case .all:
            startDate = calendar.date(byAdding: .year, value: -5, to: today)!
        }
        
        let filteredExams = dataManager.completedExams
            .filter { $0.endTime >= startDate }
            .sorted { $0.endTime < $1.endTime }
        
        return filteredExams.map { exam in
            let value: Double
            
            switch metric {
            case .score:
                value = exam.score
            case .time:
                value = exam.timeSpent / 60.0
            case .questionsPerMinute:
                value = Double(exam.answers.count) / (exam.timeSpent / 60.0)
            }
            
            return (date: exam.endTime, value: value)
        }
    }
    
    private func yAxisRange() -> ClosedRange<Double> {
        let values = prepareChartData().map { $0.value }
        guard !values.isEmpty else { return 0...100 }
        
        let min = values.min() ?? 0
        let max = values.max() ?? 100
        
        switch metric {
        case .score:
            return 0...100
        case .time, .questionsPerMinute:
            let padding = (max - min) * 0.1
            return (min - padding)...(max + padding)
        }
    }
}

struct CategoryPerformanceRow: View {
    let category: String
    let percentage: Double
    let questionCount: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(category)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(Int(percentage.rounded()))%")
                    .font(.headline)
                    .foregroundStyle(percentageColor)
            }
            
            HStack(spacing: 16) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(uiColor: .systemGray5))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(percentageColor)
                            .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                Text("\(questionCount) questões")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 90, alignment: .trailing)
            }
        }
    }
    
    private var percentageColor: Color {
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

struct RecentExamRow: View {
    let examName: String
    let date: Date
    let score: Double
    let time: TimeInterval
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private var formattedTime: String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(examName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(score.rounded()))%")
                    .font(.headline)
                    .foregroundStyle(score >= 60 ? .green : .red)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    
                    Text(formattedTime)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct ImprovementSuggestionRow: View {
    let title: String
    let description: String
    let actionText: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                // Implementar ação
            } label: {
                Text(actionText)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow)
                    .foregroundStyle(.black)
                    .cornerRadius(16)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Placeholder Views para Navegação

struct AllCategoriesPerformanceView: View {
    var body: some View {
        Text("Desempenho por Categoria")
            .navigationTitle("Categorias")
    }
}

struct ExamHistoryView: View {
    var body: some View {
        Text("Histórico de Simulados")
            .navigationTitle("Histórico")
    }
}

struct ExamResultPreviewView: View {
    let completedExam: CompletedExam
    
    var body: some View {
        Text("Detalhes do Simulado")
            .navigationTitle("Resultado")
    }
}
