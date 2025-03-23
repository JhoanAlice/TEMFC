// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/Views/StudyView.swift

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
                        
                        // Versão alternativa da barra de pesquisa para evitar problemas de thread
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(TEMFCDesign.Colors.secondaryText)
                            
                            // Usando ZStack para simular o placeholder manualmente
                            ZStack(alignment: .leading) {
                                if searchText.isEmpty {
                                    Text("Buscar área temática")
                                        .foregroundColor(Color(.placeholderText))
                                        .font(TEMFCDesign.Typography.body)
                                }
                                
                                // Texto básico com input para evitar propriedades UIKit
                                TextEditor(text: $searchText)
                                    .font(TEMFCDesign.Typography.body)
                                    .frame(height: 22)
                                    .background(Color.clear)
                                    .padding(.vertical, -8)
                            }
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
                                // Picker sem eventos complexos
                                let pickerOptions = [(5, "5"), (10, "10"), (15, "15"), (20, "20"),
                                                     (availableQuestionsCount, "Todas (\(availableQuestionsCount))")]
                                
                                Picker("", selection: $quizSize) {
                                    ForEach(pickerOptions.filter { $0.0 <= availableQuestionsCount }, id: \.0) { value, label in
                                        Text(label).tag(value)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(width: 200)
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
                    
                    // Lista de tags usando ForEach otimizado
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
                                // ForEach com ID seguro para evitar problemas de identidade de view
                                ForEach(filteredTags, id: \.self) { tag in
                                    TagSelectionRowSafe(
                                        tag: tag,
                                        isSelected: selectedTags.contains(tag),
                                        tagColor: TEMFCDesign.Colors.tagColor(for: tag),
                                        onSelect: {
                                            if selectedTags.contains(tag) {
                                                selectedTags.remove(tag)
                                            } else {
                                                selectedTags.insert(tag)
                                            }
                                            
                                            // Atualizar o tamanho do quiz se necessário
                                            if quizSize > availableQuestionsCount && availableQuestionsCount > 0 {
                                                quizSize = availableQuestionsCount
                                            }
                                        }
                                    )
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
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                // Configuração inicial segura
                if quizSize > availableQuestionsCount && availableQuestionsCount > 0 {
                    quizSize = availableQuestionsCount
                }
            }
        }
    }
}

// View auxiliar segura para seleção de tags
struct TagSelectionRowSafe: View {
    let tag: String
    let isSelected: Bool
    let tagColor: Color
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(tag)
                    .font(TEMFCDesign.Typography.body)
                    .foregroundColor(isSelected ? .white : TEMFCDesign.Colors.text)
                
                Spacer()
                
                // Pequeno círculo com a cor da tag
                Circle()
                    .fill(tagColor)
                    .frame(width: 12, height: 12)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? tagColor : TEMFCDesign.Colors.secondaryText)
                    .font(.system(size: 22))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                    .fill(isSelected ? tagColor.opacity(0.15) : TEMFCDesign.Colors.background)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                    .stroke(isSelected ? tagColor : Color.clear, lineWidth: isSelected ? 1 : 0)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 4)
    }
}
