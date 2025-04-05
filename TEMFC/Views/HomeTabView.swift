// TEMFC/Views/HomeTabView.swift
// Created by Jhoan Franco on 3/26/25.

import SwiftUI
import UIKit

struct HomeTabView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var showingQuickStudy = false
    @State private var showingFavorites = false
    @State private var showingAchievements = false
    @State private var showingProfile = false
    
    private var completedExamsCount: Int {
        dataManager.completedExams.count
    }
    
    private var averageScore: Double {
        guard !dataManager.completedExams.isEmpty else { return 0 }
        let total = dataManager.completedExams.reduce(0) { $0 + $1.score }
        return total / Double(dataManager.completedExams.count)
    }
    
    private var studyTimeTotal: TimeInterval {
        dataManager.completedExams.reduce(0) { $0 + $1.timeSpent }
    }
    
    private var currentStreak: Int {
        // Calculando dias consecutivos de estudo
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
        // Removemos o NavigationView que estava aqui
        ScrollView {
            VStack(spacing: 20) {
                // Boas-vindas e avatar
                welcomeSection
                
                // Resumo de Estatísticas
                statisticsSection
                
                // Continuar Exame (se houver em andamento)
                if !dataManager.inProgressExams.isEmpty {
                    continueExamSection
                }
                
                // Sessões Recentes
                recentExamsSection
                
                // Áreas que Precisa Melhorar
                improvementAreasSection
                
                // Botões de Acesso Rápido
                quickAccessSection
            }
            .padding(.bottom, 30)
        }
        .background(TEMFCDesign.Colors.groupedBackground.ignoresSafeArea())
        .navigationTitle("Home")
        .sheet(isPresented: $showingQuickStudy) {
            quickStudyView
        }
        .sheet(isPresented: $showingFavorites) {
            NavigationView {
                FavoritesView()
                    .environmentObject(dataManager)
                    .navigationTitle("Favoritos")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $showingAchievements) {
            NavigationView {
                AchievementsView()
                    .environmentObject(dataManager)
                    .navigationTitle("Conquistas")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $showingProfile) {
            NavigationView {
                UserProfileView(userManager: userManager)
                    .environmentObject(userManager)
                    .environmentObject(dataManager)
                    .navigationTitle("Meu Perfil")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    // MARK: - UI Sections
    
    private var welcomeSection: some View {
        TEMFCCard(title: "Olá, \(userManager.currentUser.displayName)", systemImage: "person.fill", accentColor: TEMFCDesign.Colors.primary) {
            HStack(alignment: .center) {
                // Mensagem motivacional
                VStack(alignment: .leading, spacing: 8) {
                    Text(welcomeMessage)
                        .font(TEMFCDesign.Typography.subheadline)
                        .foregroundStyle(TEMFCDesign.Colors.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if currentStreak > 0 {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                            Text("\(currentStreak) dias seguidos!")
                                .foregroundStyle(.orange)
                                .fontWeight(.semibold)
                        }
                        .font(TEMFCDesign.Typography.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Avatar
                VStack {
                    profileImage
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 3)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var profileImage: some View {
        Group {
            if let imageData = userManager.currentUser.profileImage,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(TEMFCDesign.Colors.primary.opacity(0.2))
                    Text(initialsFromName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(TEMFCDesign.Colors.primary)
                }
            }
        }
    }
    
    private var initialsFromName: String {
        let components = userManager.currentUser.name.components(separatedBy: " ")
        if components.count > 1,
           let first = components.first?.prefix(1),
           let last = components.last?.prefix(1) {
            return "\(first)\(last)".uppercased()
        } else if let first = components.first?.prefix(1) {
            return String(first).uppercased()
        } else {
            return "U"
        }
    }
    
    private var statisticsSection: some View {
        TEMFCCard(title: "Seu Progresso", systemImage: "chart.bar.fill", accentColor: .blue) {
            HStack(spacing: 16) {
                // Simulados Concluídos
                VStack(spacing: 6) {
                    Text("\(completedExamsCount)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(TEMFCDesign.Colors.primary)
                    
                    Text("Simulados")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundStyle(TEMFCDesign.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                
                // Pontuação Média
                VStack(spacing: 6) {
                    Text(String(format: "%.1f%%", averageScore))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                    
                    Text("Média")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundStyle(TEMFCDesign.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                
                // Tempo de Estudo
                VStack(spacing: 6) {
                    Text(formattedStudyTime)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.orange)
                    
                    Text("Horas")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundStyle(TEMFCDesign.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var continueExamSection: some View {
        VStack(spacing: 8) {
            let inProgressExam = dataManager.inProgressExams.first!
            let exam = dataManager.getExam(id: inProgressExam.examId)
            
            TEMFCCard(title: "Continuar Simulado", systemImage: "arrow.triangle.2.circlepath", accentColor: .green) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(exam?.name ?? "Simulado em Andamento")
                            .font(TEMFCDesign.Typography.headline)
                            .foregroundStyle(TEMFCDesign.Colors.text)
                        
                        // Informações sobre o progresso
                        HStack {
                            ProgressView(value: Double(inProgressExam.userAnswers.count), total: Double(exam?.totalQuestions ?? 100))
                                .progressViewStyle(LinearProgressViewStyle(tint: TEMFCDesign.Colors.primary))
                                .frame(width: 100)
                            
                            Text("\(inProgressExam.userAnswers.count)/\(exam?.totalQuestions ?? 0) questões")
                                .font(TEMFCDesign.Typography.caption)
                                .foregroundStyle(TEMFCDesign.Colors.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Tentamos carregar e continuar o simulado em andamento
                        if let inProgressExam = dataManager.inProgressExams.first,
                           let exam = dataManager.getExam(id: inProgressExam.examId) {
                            let viewModel = ExamViewModel()
                            viewModel.loadInProgressExam(inProgressExam: inProgressExam, exam: exam)
                            
                            // Navegamos para a tela de simulado
                            let host = UIHostingController(rootView: ExamSessionView(viewModel: viewModel)
                                .environmentObject(dataManager)
                                .environmentObject(settingsManager))
                            
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = windowScene.windows.first?.rootViewController {
                                rootVC.present(host, animated: true)
                            }
                        }
                    }) {
                        Text("Continuar")
                            .font(TEMFCDesign.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(TEMFCDesign.Colors.primary)
                            .cornerRadius(8)
                    }
                    .accessibilityIdentifier("continueExamButton")
                }
                .padding(.vertical, 6)
            }
        }
    }
    
    private var recentExamsSection: some View {
        TEMFCCard(title: "Sessões Recentes", systemImage: "clock.fill", accentColor: .blue) {
            VStack(spacing: 12) {
                if dataManager.completedExams.isEmpty {
                    Text("Nenhum simulado concluído ainda")
                        .font(TEMFCDesign.Typography.body)
                        .foregroundStyle(TEMFCDesign.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(dataManager.completedExams.prefix(3)) { exam in
                        recentExamRow(exam)
                    }
                    
                    NavigationLink(destination: ExamHistoryListView()) {
                        Text("Ver todo histórico")
                            .font(TEMFCDesign.Typography.subheadline)
                            .foregroundStyle(TEMFCDesign.Colors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(TEMFCDesign.Colors.primary.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private func recentExamRow(_ exam: CompletedExam) -> some View {
        let examName = dataManager.exams.first(where: { $0.id == exam.examId })?.name ?? "Simulado"
        
        return NavigationLink(destination: ExamResultView(completedExam: exam)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(examName)
                        .font(TEMFCDesign.Typography.subheadline)
                        .foregroundStyle(TEMFCDesign.Colors.text)
                        .lineLimit(1)
                    
                    Text(formattedDate(exam.endTime))
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundStyle(TEMFCDesign.Colors.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(exam.score.rounded()))%")
                        .font(TEMFCDesign.Typography.subheadline)
                        .foregroundStyle(exam.score >= 60 ? .green : .red)
                    
                    Text(formattedTime(exam.timeSpent))
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundStyle(TEMFCDesign.Colors.secondaryText)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var improvementAreasSection: some View {
        TEMFCCard(title: "Áreas para Melhorar", systemImage: "arrow.up.forward", accentColor: .orange) {
            VStack(spacing: 12) {
                if let recommendations = getRecommendedAreas() {
                    ForEach(recommendations.prefix(2), id: \.category) { recommendation in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recommendation.category)
                                    .font(TEMFCDesign.Typography.subheadline)
                                    .foregroundStyle(TEMFCDesign.Colors.text)
                                
                                Text("\(Int(recommendation.score.rounded()))% nas últimas sessões")
                                    .font(TEMFCDesign.Typography.caption)
                                    .foregroundStyle(TEMFCDesign.Colors.secondaryText)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Ação para estudar esta área
                            }) {
                                Text("Praticar")
                                    .font(TEMFCDesign.Typography.caption)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(TEMFCDesign.Colors.tagColor(for: recommendation.category))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(8)
                    }
                } else {
                    Text("Complete mais simulados para obter recomendações")
                        .font(TEMFCDesign.Typography.body)
                        .foregroundStyle(TEMFCDesign.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
    }
    
    private var quickAccessSection: some View {
        VStack(spacing: 12) {
            Text("Acesso Rápido")
                .font(TEMFCDesign.Typography.headline)
                .foregroundStyle(TEMFCDesign.Colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                quickAccessButton(
                    title: "Estudo\nRápido",
                    systemImage: "bolt.fill",
                    color: .blue
                ) {
                    showingQuickStudy = true
                }
                .accessibilityIdentifier("quickAccess_study")
                
                quickAccessButton(
                    title: "Favoritos",
                    systemImage: "star.fill",
                    color: .yellow
                ) {
                    showingFavorites = true
                }
                .accessibilityIdentifier("quickAccess_favorites")
                
                quickAccessButton(
                    title: "Conquistas",
                    systemImage: "trophy.fill",
                    color: .orange
                ) {
                    showingAchievements = true
                }
                .accessibilityIdentifier("quickAccess_achievements")
                
                quickAccessButton(
                    title: "Perfil",
                    systemImage: "person.fill",
                    color: TEMFCDesign.Colors.primary
                ) {
                    showingProfile = true
                }
                .accessibilityIdentifier("quickAccess_profile")
            }
            .padding(.horizontal)
        }
    }
    
    private var quickStudyView: some View {
        NavigationView {
            StudyQuizView(selectedTags: [], quizSize: 10)
                .environmentObject(dataManager)
                .environmentObject(settingsManager)
                .navigationTitle("Estudo Rápido")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func quickAccessButton(title: String, systemImage: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            TEMFCDesign.HapticFeedback.mediumImpact()
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(TEMFCDesign.Typography.caption)
                    .foregroundStyle(TEMFCDesign.Colors.text)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Functions
    
    private var welcomeMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 {
            return "Bom dia! Que tal iniciar seus estudos para o TEMFC?"
        } else if hour < 18 {
            return "Boa tarde! Continue seu progresso nos simulados hoje."
        } else {
            return "Boa noite! Uma revisão rápida antes de dormir?"
        }
    }
    
    private var formattedStudyTime: String {
        let totalHours = Int(studyTimeTotal / 3600)
        return "\(totalHours)"
    }
    
    private var scoreColor: Color {
        if averageScore >= 80 {
            return .green
        } else if averageScore >= 60 {
            return .blue
        } else {
            return .red
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func getRecommendedAreas() -> [(category: String, score: Double, questionCount: Int)]? {
        guard !dataManager.completedExams.isEmpty else { return nil }
        
        var categoryStats: [String: (correct: Int, total: Int)] = [:]
        
        for completedExam in dataManager.completedExams {
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
        
        let results = categoryStats
            .filter { $0.value.total >= 3 }
            .map { (category: $0.key,
                   percentage: Double($0.value.correct) / Double($0.value.total) * 100,
                   questionCount: $0.value.total) }
            .sorted { $0.percentage < $1.percentage }
        
        return results.isEmpty ? nil : results as? [(category: String, score: Double, questionCount: Int)]
    }
}

// MARK: - Preview
struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
            .environmentObject(DataManager())
            .environmentObject(UserManager())
            .environmentObject(SettingsManager())
    }
}
