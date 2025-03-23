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
                    // Lógica para criar exame personalizado (será implementada posteriormente)
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

// Componente de cartão de exame
struct ExamCardView: View {
    let exam: Exam
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cabeçalho do exame
            HStack {
                Image(systemName: exam.type == .theoretical ? "doc.text.fill" : "video.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(exam.name)
                    .font(.headline)
                
                Spacer()
                
                Text(exam.type.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Divider()
            
            // Informações do exame
            HStack {
                Label("\(exam.totalQuestions) questões", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
