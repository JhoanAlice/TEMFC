// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/Views/FavoritesView.swift

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTag: String? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.getFavoriteQuestions().isEmpty {
                    // Mensagem quando não há favoritos
                    VStack(spacing: 20) {
                        Image(systemName: "star.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Nenhuma questão favorita")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Adicione questões aos favoritos durante os estudos para acessá-las rapidamente aqui.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 40)
                } else {
                    // Filtro por tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            TagFilterButton(
                                title: "Todas",
                                isSelected: selectedTag == nil,
                                action: { selectedTag = nil }
                            )
                            
                            ForEach(availableTags, id: \.self) { tag in
                                TagFilterButton(
                                    title: tag,
                                    isSelected: selectedTag == tag,
                                    action: { selectedTag = tag }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    // Lista de questões favoritas
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Utiliza o método filterByTags para obter os favoritos filtrados
                            ForEach(filterByTags(selectedTag == nil ? [] : [selectedTag!])) { question in
                                FavoriteQuestionCard(question: question)
                                    .environmentObject(dataManager)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Questões Favoritas")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Métodos Integrados
    
    /// Filtra as questões favoritas com base nas tags fornecidas.
    func filterByTags(_ tags: [String]) -> [Question] {
        let favorites = dataManager.getFavoriteQuestions()
        if tags.isEmpty {
            return favorites
        }
        return favorites.filter { question in
            let questionTags = Set(question.tags)
            let filterTags = Set(tags)
            return !questionTags.isDisjoint(with: filterTags)
        }
    }
    
    /// Agrupa as questões por tópico (utilizando a primeira tag de cada questão como chave).
    func groupQuestionsByTopic(_ questions: [Question]) -> [String: [Question]] {
        var groupedQuestions: [String: [Question]] = [:]
        for question in questions {
            let primaryTag = question.tags.first ?? "Sem categoria"
            var questionsForTag = groupedQuestions[primaryTag] ?? []
            questionsForTag.append(question)
            groupedQuestions[primaryTag] = questionsForTag
        }
        return groupedQuestions
    }
    
    // Todas as tags disponíveis nas questões favoritas
    private var availableTags: [String] {
        var tags = Set<String>()
        for question in dataManager.getFavoriteQuestions() {
            for tag in question.tags {
                tags.insert(tag)
            }
        }
        return Array(tags).sorted()
    }
}

// MARK: - Supporting Views

struct TagFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                )
                .foregroundColor(isSelected ? .blue : .primary)
        }
    }
}

struct FavoriteQuestionCard: View {
    let question: Question
    @EnvironmentObject var dataManager: DataManager
    @State private var showingQuestionDetail = false
    
    var body: some View {
        Button(action: {
            showingQuestionDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("Questão #\(question.id)")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        dataManager.removeFromFavorites(questionId: question.id)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Text(question.statement)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                
                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(question.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(TEMFCDesign.Colors.tagColor(for: tag).opacity(0.1))
                                )
                                .foregroundColor(TEMFCDesign.Colors.tagColor(for: tag))
                        }
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingQuestionDetail) {
            FavoriteQuestionDetailView(question: question)
                .environmentObject(dataManager)
        }
    }
}

struct FavoriteQuestionDetailView: View {
    let question: Question
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Enunciado
                    Text(question.statement)
                        .font(.body)
                    
                    // Opções
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Alternativas:")
                            .font(.headline)
                        
                        ForEach(0..<question.options.count, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text(question.options[index])
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                if index == question.correctOption {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(index == question.correctOption ? Color.green.opacity(0.1) : Color(.systemBackground))
                                    .stroke(
                                        index == question.correctOption ? Color.green : Color.gray.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                    
                    // Explicação
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Explicação:")
                            .font(.headline)
                        
                        Text(question.explanation)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Áreas Temáticas:")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(question.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(TEMFCDesign.Colors.tagColor(for: tag).opacity(0.1))
                                    )
                                    .foregroundColor(TEMFCDesign.Colors.tagColor(for: tag))
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Questão Favorita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        dataManager.removeFromFavorites(questionId: question.id)
                        dismiss()
                    }) {
                        Label("Remover dos Favoritos", systemImage: "star.slash")
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Layout de fluxo para as tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentRowWidth + size.width > width {
                height += currentRowHeight + spacing
                currentRowWidth = size.width
                currentRowHeight = size.height
            } else {
                currentRowWidth += size.width + spacing
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }
        
        height += currentRowHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let width = bounds.width
        
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > width {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
