// TEMFC/Views/ExamCenterView.swift

import SwiftUI

struct ExamCenterView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedType: Exam.ExamType? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Seletor de tipo de exame
                Picker("Tipo de Exame", selection: $selectedType) {
                    Text("Todos").tag(nil as Exam.ExamType?)
                    ForEach(Exam.ExamType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type as Exam.ExamType?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)
                
                // Lista de exames
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredExams) { exam in
                            NavigationLink(destination: ExamDetailView(exam: exam)) {
                                ExamCardView(exam: exam)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                
                // Botão para criar exame personalizado
                Button(action: {
                    // Lógica para criar exame personalizado (a ser implementada)
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Criar Exame Personalizado")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationTitle("Central de Exames")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // Filtra os exames com base no tipo selecionado
    private var filteredExams: [Exam] {
        if let type = selectedType {
            return dataManager.exams.filter { $0.type == type }
        } else {
            return dataManager.exams
        }
    }
}
