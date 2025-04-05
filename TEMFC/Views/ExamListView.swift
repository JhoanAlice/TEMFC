// TEMFC/Views/ExamListView.swift

import SwiftUI

struct ExamListView: View {
    @EnvironmentObject var dataManager: DataManager
    let examType: Exam.ExamType
    @State private var showingCreateExamSheet = false
    @State private var exams: [Exam] = []
    @State private var isLoading = true
    
    var body: some View {
        // Importante: Remova o NavigationView, pois a MainTabView já fornece o contexto de navegação.
        ZStack {
            TEMFCDesign.Colors.groupedBackground
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Carregando exames...")
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(radius: 5)
                    .onAppear {
                        // Log que estamos carregando
                        print("🔄 ExamListView: Carregando exames do tipo \(examType.rawValue)...")
                    }
            } else if exams.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Nenhum simulado \(examType.rawValue) disponível")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingCreateExamSheet = true
                    }) {
                        Label("Criar Simulado Personalizado", systemImage: "plus.circle.fill")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(TEMFCDesign.Colors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
                .padding()
                .accessibilityIdentifier("noExamsView")
            } else {
                // Lista de exames
                ScrollView {
                    VStack(spacing: TEMFCDesign.Spacing.l) {
                        // Header
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
                        .accessibilityIdentifier("examListHeader")
                        
                        // Lista de exames usando o novo ExamCardView
                        ForEach(exams) { exam in
                            NavigationLink(destination: ExamDetailView(exam: exam)) {
                                ExamCardView(exam: exam)
                                    .contentShape(Rectangle()) // Garante que toda a área seja tappable
                            }
                            .buttonStyle(PlainButtonStyle())
                            .id("examRow_\(exam.id)")
                            .accessibilityIdentifier("examRow_\(exam.id)")
                            .padding(.horizontal, TEMFCDesign.Spacing.m)
                        }
                    }
                    .padding(.vertical, TEMFCDesign.Spacing.m)
                }
                .accessibilityIdentifier("examListScrollView")
                .refreshable {
                    await refreshExams()
                }
            }
            
            // Botão flutuante para criação de simulado personalizado
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        TEMFCDesign.HapticFeedback.buttonPressed()
                        showingCreateExamSheet = true
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
                    .accessibilityIdentifier("createExamButton")
                }
            }
        }
        .onAppear {
            loadExams()
            print("ExamListView appeared for \(examType.rawValue)")
        }
        .sheet(isPresented: $showingCreateExamSheet) {
            CreateCustomExamView(examType: examType)
                .environmentObject(dataManager)
        }
    }
    
    // MARK: - Métodos para Carga de Dados
    
    private func loadExams() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Log the state before filtering
            print("\n🔍 DIAGNÓSTICO DE EXAMLISTVIEW PARA TIPO: \(self.examType.rawValue)")
            print("Total de exames disponíveis: \(self.dataManager.exams.count)")
            
            // Log each exam in the DataManager
            for (index, exam) in self.dataManager.exams.enumerated() {
                print("[\(index+1)] Exame em DataManager: \(exam.name) (\(exam.id)) - Tipo: \(exam.type.rawValue)")
            }
            
            // Now filter and assign
            self.exams = self.dataManager.getExamsByType(type: self.examType)
            
            print("\nExames filtrados para tipo \(self.examType.rawValue): \(self.exams.count)")
            if self.exams.isEmpty {
                print("⚠️ ATENÇÃO: Nenhum exame encontrado para o tipo \(self.examType.rawValue)!")
                
                // Verificar se há problema com enum comparação
                for exam in self.dataManager.exams {
                    let typeMatch = exam.type == self.examType
                    let rawValues = "Exame: \(exam.type.rawValue), Filtro: \(self.examType.rawValue)"
                    print("- \(exam.id): Correspondência de tipo: \(typeMatch) (\(rawValues))")
                }
            } else {
                for exam in self.exams {
                    print("- Exame carregado: \(exam.name) (\(exam.id)), Questões: \(exam.questions.count)")
                }
            }
            
            self.isLoading = false
        }
    }
    
    private func refreshExams() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.loadExams()
                continuation.resume()
            }
        }
    }
}
