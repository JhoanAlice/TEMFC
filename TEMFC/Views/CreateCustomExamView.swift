import SwiftUI

struct CreateCustomExamView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    let examType: Exam.ExamType
    
    @State private var examName = ""
    @State private var numberOfQuestions = 30
    @State private var selectedTags: Set<String> = []
    @State private var isLoading = false
    
    // Obtém todas as tags únicas de todos os exames
    private var allTags: [String] {
        var tags = Set<String>()
        
        for exam in dataManager.exams {
            for question in exam.questions {
                for tag in question.tags {
                    tags.insert(tag)
                }
            }
        }
        
        return Array(tags).sorted()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informações do Simulado")) {
                    TextField("Nome do simulado", text: $examName)
                        .disableAutocorrection(true)
                    
                    Stepper("Número de questões: \(numberOfQuestions)", value: $numberOfQuestions, in: 10...80, step: 5)
                }
                
                Section(header: Text("Áreas Temáticas")) {
                    Text("Selecione ao menos uma área temática")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    List {
                        ForEach(allTags, id: \.self) { tag in
                            Button(action: {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }) {
                                HStack {
                                    Text(tag)
                                    Spacer()
                                    if selectedTags.contains(tag) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(TEMFCDesign.Colors.primary)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                
                Section {
                    Button(action: createCustomExam) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Criar Simulado")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(isFormValid ? TEMFCDesign.Colors.primary : Color.gray)
                    .cornerRadius(10)
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationTitle("Novo Simulado")
            .navigationBarItems(trailing: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // Validação do formulário
    private var isFormValid: Bool {
        return !examName.isEmpty && selectedTags.count > 0 && numberOfQuestions >= 10
    }
    
    // Função para criar simulado personalizado
    private func createCustomExam() {
        isLoading = true
        
        // Coletar questões dos exames existentes que correspondam às tags selecionadas
        var allQuestions: [Question] = []
        
        for exam in dataManager.exams {
            for question in exam.questions where question.tags.contains(where: { selectedTags.contains($0) }) {
                allQuestions.append(question)
            }
        }
        
        // Embaralhar e selecionar o número desejado de questões
        allQuestions.shuffle()
        let selectedQuestions = Array(allQuestions.prefix(min(numberOfQuestions, allQuestions.count)))
        
        // Criar o novo exame
        let customExamId = "CUSTOM_\(UUID().uuidString.prefix(8))"
        let customExam = Exam(
            id: customExamId,
            name: examName,
            type: examType,
            totalQuestions: selectedQuestions.count,
            questions: selectedQuestions
        )
        
        // Adicionar o exame personalizado ao DataManager
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dataManager.exams.append(customExam)
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}
