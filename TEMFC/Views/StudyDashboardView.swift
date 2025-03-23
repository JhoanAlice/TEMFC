// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/Views/StudyDashboardView.swift

import SwiftUI
import Charts

// MARK: - Estrutura para Recomendações de Estudo

struct StudyRecommendation: Identifiable {
    let id = UUID()
    let category: String
    let score: Double
    let questionCount: Int
    let recommendation: String
}

struct StudyDashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingQuizCreator = false
    @State private var showingFavorites = false
    @State private var activeStudySession: StudySession?
    
    // Study time statistics
    private var totalStudyTimeThisWeek: TimeInterval {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        
        return dataManager.completedExams
            .filter { $0.endTime >= startOfWeek }
            .reduce(0) { $0 + $1.timeSpent }
    }
    
    private var formattedWeeklyStudyTime: String {
        let hours = Int(totalStudyTimeThisWeek / 3600)
        let minutes = Int((totalStudyTimeThisWeek.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes) minutos"
        }
    }
    
    // Streak calculation
    private var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = Date()
        
        while true {
            let startOfDay = calendar.startOfDay(for: currentDate)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: currentDate)!
            
            let hasStudiedToday = dataManager.completedExams.contains {
                $0.endTime >= startOfDay && $0.endTime <= endOfDay
            }
            
            if hasStudiedToday {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Study Metrics
                    TEMFCCard(title: "Estatísticas de Estudo", systemImage: "chart.bar.doc.horizontal") {
                        VStack(spacing: 20) {
                            HStack {
                                StatisticView(
                                    value: formattedWeeklyStudyTime,
                                    label: "Esta Semana",
                                    systemImage: "clock.fill"
                                )
                                
                                Divider()
                                    .frame(height: 40)
                                
                                StatisticView(
                                    value: "\(currentStreak)",
                                    label: "Dias Seguidos",
                                    systemImage: "flame.fill"
                                )
                                
                                Divider()
                                    .frame(height: 40)
                                
                                StatisticView(
                                    value: "\(dataManager.completedExams.count)",
                                    label: "Simulados",
                                    systemImage: "list.bullet.clipboard.fill"
                                )
                            }
                            
                            // Weekly Study Chart
                            if #available(iOS 16.0, *) {
                                StudyActivityChart(dataManager: dataManager)
                                    .frame(height: 130)
                            }
                        }
                    }
                    
                    // Quick Start Section
                    TEMFCCard(title: "Iniciar Estudo", systemImage: "play.fill", accentColor: .green) {
                        VStack(spacing: 14) {
                            // Start New Study Session
                            QuickStartButton(
                                title: "Nova Sessão de Estudo",
                                subtitle: "Configure um quiz personalizado",
                                systemImage: "play.circle.fill",
                                color: .green
                            ) {
                                showingQuizCreator = true
                            }
                            
                            // Review Weak Areas
                            QuickStartButton(
                                title: "Revisar Pontos Fracos",
                                subtitle: "Foco nas áreas com baixo desempenho",
                                systemImage: "exclamationmark.triangle.fill",
                                color: .orange
                            ) {
                                let recommendations = getStudyRecommendations()
                                print("Recomendações de Estudo:", recommendations)
                            }
                            
                            // Continue Previous Session
                            if dataManager.inProgressExams.first != nil {
                                QuickStartButton(
                                    title: "Continuar Última Sessão",
                                    subtitle: "Retomar de onde parou",
                                    systemImage: "arrow.triangle.2.circlepath",
                                    color: .blue
                                ) {
                                    // Continue last session
                                }
                            }
                        }
                    }
                    
                    // Spaced Repetition and Favorites
                    HStack(spacing: 16) {
                        // Spaced Repetition
                        TEMFCCard(title: "Repetição Espaçada", systemImage: "calendar", accentColor: .purple) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Revisão programada para hoje:")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(Int.random(in: 12...24)) questões")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Button {
                                    // Start spaced repetition session
                                } label: {
                                    Text("Iniciar Revisão")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.purple)
                                        .foregroundStyle(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Favorites
                        TEMFCCard(title: "Favoritos", systemImage: "star.fill", accentColor: .yellow) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Questões salvas para revisão:")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(Int.random(in: 5...15)) questões")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Button {
                                    showingFavorites = true
                                } label: {
                                    Text("Ver Favoritos")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.yellow)
                                        .foregroundStyle(.black)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    // Study Categories
                    TEMFCCard(title: "Áreas de Estudo", systemImage: "folder.fill", accentColor: .cyan) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(getTopCategories(), id: \.0) { category, count in
                                CategoryButton(name: category, questionCount: count)
                            }
                            
                            NavigationLink {
                                AllCategoriesView()
                            } label: {
                                Text("Ver Todas")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.cyan.opacity(0.1))
                                    .foregroundStyle(.cyan)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.top)
                .padding(.bottom, 24)
            }
            .navigationTitle("Estudo")
            .sheet(isPresented: $showingQuizCreator) {
                QuizCreatorView()
            }
            .sheet(isPresented: $showingFavorites) {
                // Updated placeholder view name
                FavoritesPlaceholderView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            // Start random quiz
                        } label: {
                            Label("Quiz Aleatório", systemImage: "dice.fill")
                        }
                        
                        Button {
                            // Study history
                        } label: {
                            Label("Histórico de Estudo", systemImage: "clock.arrow.circlepath")
                        }
                        
                        Button {
                            // Start timed session
                        } label: {
                            Label("Sessão Cronometrada", systemImage: "timer")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
            }
        }
    }
    
    // MARK: - Função para Recomendações de Estudo
    
    private func getStudyRecommendations() -> [StudyRecommendation] {
        var categoryPerformance: [String: (correct: Int, total: Int)] = [:]
        
        for completedExam in dataManager.completedExams {
            if let exam = dataManager.exams.first(where: { $0.id == completedExam.examId }) {
                for answer in completedExam.answers {
                    if let question = exam.questions.first(where: { $0.id == answer.questionId }) {
                        for tag in question.tags {
                            var stats = categoryPerformance[tag] ?? (0, 0)
                            stats.total += 1
                            if answer.isCorrect {
                                stats.correct += 1
                            }
                            categoryPerformance[tag] = stats
                        }
                    }
                }
            }
        }
        
        let weakCategories = categoryPerformance
            .filter { $0.value.total >= 5 }
            .map { (category: $0.key,
                    percentage: Double($0.value.correct) / Double($0.value.total) * 100,
                    questionCount: $0.value.total) }
            .sorted { $0.percentage < $1.percentage }
            .prefix(3)
        
        return weakCategories.map { category in
            StudyRecommendation(
                category: category.category,
                score: category.percentage,
                questionCount: category.questionCount,
                recommendation: "Recomendamos estudar \(category.category) para melhorar seu desempenho de \(Int(category.percentage))%."
            )
        }
    }
    
    // Get top study categories
    private func getTopCategories() -> [(String, Int)] {
        var categories: [String: Int] = [:]
        for exam in dataManager.exams {
            for question in exam.questions {
                for tag in question.tags {
                    categories[tag, default: 0] += 1
                }
            }
        }
        return categories.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }
}

// MARK: - Placeholder View Renamed

struct FavoritesPlaceholderView: View {
    var body: some View {
        NavigationStack {
            Text("Questões Favoritas")
                .navigationTitle("Favoritos")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Supporting Views

struct StudyActivityChart: View {
    let dataManager: DataManager
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(last7Days(), id: \.date) { day in
                    BarMark(
                        x: .value("Dia", day.weekday),
                        y: .value("Tempo", day.minutes)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(8)
                }
            }
            .chartXAxis {
                AxisMarks(values: last7Days().map { $0.weekday }) { _ in
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        } else {
            Text("Gráfico disponível no iOS 16+")
                .foregroundStyle(.secondary)
        }
    }
    
    private func last7Days() -> [(date: Date, weekday: String, minutes: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let weekday = dateFormatter.string(from: date)
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
            let minutesStudied = dataManager.completedExams
                .filter { $0.endTime >= startOfDay && $0.endTime <= endOfDay }
                .reduce(0.0) { $0 + $1.timeSpent / 60.0 }
            return (date: date, weekday: weekday, minutes: minutesStudied)
        }
        .reversed()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter
    }
}

struct StatisticView: View {
    let value: String
    let label: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.caption)
                Text(label)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickStartButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct CategoryButton: View {
    let name: String
    let questionCount: Int
    
    var body: some View {
        NavigationLink {
            // Category detail view placeholder
            Text("Detalhes de \(name)")
                .navigationTitle(name)
        } label: {
            VStack(spacing: 6) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(questionCount) questões")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct QuizCreatorView: View {
    var body: some View {
        NavigationStack {
            Text("Criador de Quiz")
                .navigationTitle("Novo Quiz")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AllCategoriesView: View {
    var body: some View {
        Text("Todas as Categorias")
            .navigationTitle("Áreas de Estudo")
    }
}
