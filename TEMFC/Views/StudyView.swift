import SwiftUI

struct StudyView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTags: Set<String> = []
    @State private var showingQuizSheet = false
    @State private var quizSize: Int = 10
    @State private var searchText: String = ""
    
    // Computa quantas questões estão disponíveis para as tags selecionadas
    private var availableQuestionsCount: Int {
        guard !selectedTags.isEmpty else { return 0 }
        var uniqueQuestionIds = Set<Int>()
        for exam in dataManager.exams {
            for question in exam.questions {
                if !Set(question.tags).isDisjoint(with: selectedTags) {
                    uniqueQuestionIds.insert(question.id)
                }
            }
        }
        return uniqueQuestionIds.count
    }
    
    // Tamanho máximo do quiz: 20 ou o total de questões disponíveis, o que for menor
    private var maxQuizSize: Int {
        return min(20, availableQuestionsCount)
    }
    
    // Tamanho efetivo do quiz: o valor escolhido (quizSize) ou o total disponível, o que for menor
    private var effectiveQuizSize: Int {
        return min(quizSize, availableQuestionsCount)
    }
    
    var uniqueTags: [String] {
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
    
    var filteredTags: [String] {
        if searchText.isEmpty {
            return uniqueTags
        } else {
            return uniqueTags.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                TEMFCDesign.Colors.groupedBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Cabeçalho
                    VStack(alignment: .leading, spacing: TEMFCDesign.Spacing.s) {
                        Text("Modo de Estudo Personalizado")
                            .font(TEMFCDesign.Typography.title3)
                            .foregroundColor(TEMFCDesign.Colors.text)
                        
                        Text("Selecione áreas temáticas para criar um quiz personalizado")
                            .font(TEMFCDesign.Typography.subheadline)
                            .foregroundColor(TEMFCDesign.Colors.secondaryText)
                        
                        // Barra de pesquisa
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(TEMFCDesign.Colors.secondaryText)
                            
                            TextField("Buscar área temática", text: $searchText)
                                .font(TEMFCDesign.Typography.body)
                        }
                        .padding()
                        .background(TEMFCDesign.Colors.background)
                        .cornerRadius(TEMFCDesign.BorderRadius.medium)
                        .padding(.top, TEMFCDesign.Spacing.s)
                    }
                    .padding()
                    .background(TEMFCDesign.Colors.background)
                    
                    // Configuração do quiz
                    VStack(alignment: .leading, spacing: TEMFCDesign.Spacing.s) {
                        Text("Configuração do Quiz")
                            .font(TEMFCDesign.Typography.headline)
                            .foregroundColor(TEMFCDesign.Colors.text)
                        
                        HStack {
                            Text("Número de questões:")
                                .font(TEMFCDesign.Typography.subheadline)
                                .foregroundColor(TEMFCDesign.Colors.text)
                            
                            Spacer()
                            
                            if availableQuestionsCount > 0 {
                                Picker("", selection: $quizSize) {
                                    // Só mostrar opções que não excedam o número disponível
                                    if availableQuestionsCount >= 5 {
                                        Text("5").tag(5)
                                    }
                                    if availableQuestionsCount >= 10 {
                                        Text("10").tag(10)
                                    }
                                    if availableQuestionsCount >= 15 {
                                        Text("15").tag(15)
                                    }
                                    if availableQuestionsCount >= 20 {
                                        Text("20").tag(20)
                                    }
                                    // Opção "Todas" que usa todas as questões disponíveis
                                    Text("Todas (\(availableQuestionsCount))").tag(availableQuestionsCount)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(width: 200)
                                // Atualiza quizSize se exceder o disponível
                                .onChange(of: selectedTags) { _ in
                                    if quizSize > availableQuestionsCount {
                                        quizSize = availableQuestionsCount
                                    }
                                }
                            } else {
                                Text("Selecione tags primeiro")
                                    .font(TEMFCDesign.Typography.caption)
                                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
                            }
                        }
                        
                        // Texto informativo com o número de questões disponíveis
                        if !selectedTags.isEmpty {
                            Text("\(availableQuestionsCount) questões disponíveis para as tags selecionadas")
                                .font(TEMFCDesign.Typography.caption)
                                .foregroundColor(TEMFCDesign.Colors.secondaryText)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(TEMFCDesign.Colors.background)
                    .cornerRadius(TEMFCDesign.BorderRadius.medium)
                    .padding(.horizontal)
                    .padding(.top, TEMFCDesign.Spacing.m)
                    
                    // Lista de tags
                    ScrollView {
                        VStack(alignment: .leading, spacing: TEMFCDesign.Spacing.s) {
                            Text("Áreas Temáticas")
                                .font(TEMFCDesign.Typography.headline)
                                .foregroundColor(TEMFCDesign.Colors.text)
                                .padding(.horizontal)
                                .padding(.top, TEMFCDesign.Spacing.s)
                            
                            if filteredTags.isEmpty {
                                Text("Nenhuma área temática encontrada")
                                    .font(TEMFCDesign.Typography.body)
                                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                ForEach(filteredTags, id: \.self) { tag in
                                    TEMFCTagSelectionRow(
                                        tag: tag,
                                        isSelected: selectedTags.contains(tag),
                                        tagColor: TEMFCDesign.Colors.tagColor(for: tag)
                                    ) {
                                        TEMFCDesign.HapticFeedback.selectionChanged()
                                        if selectedTags.contains(tag) {
                                            selectedTags.remove(tag)
                                        } else {
                                            selectedTags.insert(tag)
                                        }
                                    }
                                }
                            }
                            
                            // Espaço extra para o botão flutuante
                            Color.clear.frame(height: 80)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Botão flutuante para iniciar o quiz
                VStack {
                    Spacer()
                    Button(action: {
                        TEMFCDesign.HapticFeedback.buttonPressed()
                        if !selectedTags.isEmpty {
                            showingQuizSheet = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Iniciar Quiz")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .padding(.horizontal, TEMFCDesign.Spacing.m)
                        .background(
                            Capsule()
                                .fill(selectedTags.isEmpty ? Color.gray : TEMFCDesign.Colors.primary)
                                .shadow(color: (selectedTags.isEmpty ? Color.gray : TEMFCDesign.Colors.primary).opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                    }
                    .disabled(selectedTags.isEmpty)
                    .padding(.bottom, TEMFCDesign.Spacing.l)
                }
            }
            .navigationTitle("Modo Estudo")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingQuizSheet) {
                if !selectedTags.isEmpty {
                    StudyQuizView(selectedTags: Array(selectedTags), quizSize: quizSize)
                        .environmentObject(dataManager)
                }
            }
        }
    }
}
