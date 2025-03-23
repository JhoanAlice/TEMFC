// TEMFC/Views/ExamListView.swift

import SwiftUI

struct ExamListView: View {
    @EnvironmentObject var dataManager: DataManager
    let examType: Exam.ExamType
    
    var body: some View {
        NavigationView {
            ZStack {
                TEMFCDesign.Colors.groupedBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: TEMFCDesign.Spacing.l) {
                        // Cabeçalho
                        VStack(alignment: .leading, spacing: TEMFCDesign.Spacing.xs) {
                            Text("Simulados \(examType.rawValue)")
                                .font(TEMFCDesign.Typography.title3)
                                .foregroundColor(TEMFCDesign.Colors.text)
                            
                            Text("Pratique com questões no formato oficial")
                                .font(TEMFCDesign.Typography.subheadline)
                                .foregroundColor(TEMFCDesign.Colors.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, TEMFCDesign.Spacing.m)
                        
                        // Simulados disponíveis
                        ForEach(dataManager.getExamsByType(type: examType)) { exam in
                            NavigationLink(destination: ExamDetailView(exam: exam)) {
                                EnhancedExamRowView(exam: exam)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, TEMFCDesign.Spacing.m)
                }
                
                // Botão flutuante para criar simulado personalizado
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            TEMFCDesign.HapticFeedback.buttonPressed()
                            // Ação para criar simulado personalizado
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(TEMFCDesign.Colors.primary)
                                        .shadow(color: TEMFCDesign.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                                )
                        }
                        .padding()
                        .accessibility(label: Text("Criar simulado personalizado"))
                    }
                }
            }
            .navigationTitle(examType == .theoretical ? "Prova Teórica" : "Prova Teórico-Prática")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct EnhancedExamRowView: View {
    let exam: Exam
    
    var body: some View {
        HStack(alignment: .top, spacing: TEMFCDesign.Spacing.m) {
            // Ícone
            ZStack {
                Circle()
                    .fill(exam.type == .theoretical ?
                          TEMFCDesign.Colors.primary.opacity(0.1) :
                          TEMFCDesign.Colors.accent.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: exam.type == .theoretical ? "doc.text.fill" : "video.fill")
                    .font(.system(size: 24))
                    .foregroundColor(exam.type == .theoretical ?
                                    TEMFCDesign.Colors.primary :
                                    TEMFCDesign.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: TEMFCDesign.Spacing.xs) {
                Text(exam.name)
                    .font(TEMFCDesign.Typography.headline)
                    .foregroundColor(TEMFCDesign.Colors.text)
                
                Text("\(exam.totalQuestions) questões • \(estimatedTime(exam.totalQuestions))")
                    .font(TEMFCDesign.Typography.subheadline)
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
                
                // Tags das principais áreas
                if !uniqueTags(exam).isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: TEMFCDesign.Spacing.xxs) {
                            ForEach(uniqueTags(exam).prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .temfcTag(
                                        backgroundColor: TEMFCDesign.Colors.tagColor(for: tag),
                                        textColor: .white
                                    )
                            }
                            
                            if uniqueTags(exam).count > 3 {
                                Text("+\(uniqueTags(exam).count - 3)")
                                    .temfcTag(
                                        backgroundColor: TEMFCDesign.Colors.secondaryText,
                                        textColor: .white
                                    )
                            }
                        }
                    }
                    .padding(.top, TEMFCDesign.Spacing.xxs)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(TEMFCDesign.Colors.secondaryText)
                .padding(.top, 4)
        }
        .padding(TEMFCDesign.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                .fill(TEMFCDesign.Colors.background)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, TEMFCDesign.Spacing.m)
    }
    
    private func uniqueTags(_ exam: Exam) -> [String] {
        var allTags = Set<String>()
        for question in exam.questions {
            for tag in question.tags {
                allTags.insert(tag)
            }
        }
        return Array(allTags).sorted()
    }
    
    private func estimatedTime(_ questionCount: Int) -> String {
        let estimatedMinutes = questionCount * 2 // ~2 min por questão
        if estimatedMinutes < 60 {
            return "\(estimatedMinutes) min"
        } else {
            let hours = estimatedMinutes / 60
            let minutes = estimatedMinutes % 60
            return minutes > 0 ? "\(hours)h \(minutes)min" : "\(hours)h"
        }
    }
}
