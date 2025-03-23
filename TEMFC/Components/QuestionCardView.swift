import SwiftUI
import AVKit

struct QuestionCardView: View {
    let question: Question
    let selectedOption: Int?
    let isRevealed: Bool
    let onOptionSelected: (Int) -> Void
    
    // Feedback háptico
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header da questão
            HStack {
                Text("Questão \(question.number)")
                    .font(TEMFCDesign.Typography.headline)
                    .foregroundColor(TEMFCDesign.Colors.primary)
                
                Spacer()
                
                // Tags da questão
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(question.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(TEMFCDesign.Typography.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(TEMFCDesign.Colors.tagColor(for: tag).opacity(0.2))
                                .foregroundColor(TEMFCDesign.Colors.tagColor(for: tag))
                                .cornerRadius(12)
                        }
                        
                        if question.tags.count > 3 {
                            Text("+\(question.tags.count - 3)")
                                .font(TEMFCDesign.Typography.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(Color.gray)
                                .cornerRadius(12)
                        }
                    }
                }
                .frame(maxWidth: 200)
            }
            
            // Enunciado da questão
            Text(question.statement)
                .font(TEMFCDesign.Typography.body)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 5)
            
            // Vídeo (se houver)
            if let videoUrl = question.videoUrl,
               let url = URL(string: videoUrl) {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.bottom, 10)
            }
            
            // Título das alternativas
            Text("Alternativas")
                .font(TEMFCDesign.Typography.headline)
                .foregroundColor(TEMFCDesign.Colors.text)
                .padding(.top, 5)
            
            // Opções
            ForEach(0..<question.options.count, id: \.self) { index in
                EnhancedOptionButton(
                    option: question.options[index],
                    index: index,
                    selectedIndex: selectedOption,
                    correctIndex: isRevealed ? question.correctOption : nil,
                    isNullified: question.isNullified
                ) {
                    // Se a resposta ainda não foi revelada, permita a seleção
                    if !isRevealed {
                        impactFeedback.impactOccurred()
                        
                        // Feedback baseado na resposta (só após clicar)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if question.isNullified || index == question.correctOption {
                                notificationFeedback.notificationOccurred(.success)
                            } else {
                                notificationFeedback.notificationOccurred(.error)
                            }
                        }
                        
                        onOptionSelected(index)
                    }
                }
                .padding(.bottom, 5)
            }
            
            // Explicação (se revelada)
            if isRevealed {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        
                        Text("Explicação")
                            .font(TEMFCDesign.Typography.headline)
                            .foregroundColor(TEMFCDesign.Colors.primary)
                    }
                    .id("explanationSection") // ID adicionado para permitir scroll
                    
                    // Aviso de questão anulada (se aplicável)
                    if question.isNullified {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            
                            Text("Esta questão foi anulada. Qualquer alternativa será considerada correta.")
                                .font(TEMFCDesign.Typography.subheadline)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Text(question.explanation)
                        .font(TEMFCDesign.Typography.body)
                        .foregroundColor(TEMFCDesign.Colors.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                .transition(.opacity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
        .onAppear {
            impactFeedback.prepare()
            notificationFeedback.prepare()
        }
    }
}

struct QuestionCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            QuestionCardView(
                question: Question(
                    id: 1,
                    number: 1,
                    statement: "Fernanda, 35 anos, é usuária do SUS em um município da zona litorânea do Nordeste brasileiro. Considerando os mecanismos de participação no SUS, pode-se afirmar que:",
                    options: [
                        "A - A Ouvidoria do SUS é o melhor mecanismo.",
                        "B - A Mesa de Negociação deve ser acessada.",
                        "C - O canal Disque-saúde está disponível.",
                        "D - Uma petição ao MP é a melhor forma."
                    ],
                    correctOption: 0,
                    explanation: "A Ouvidoria do SUS é o canal oficial para denúncias, sugestões e reclamações, possibilitando a participação dos usuários na melhoria dos serviços.",
                    tags: ["Saúde Coletiva", "SUS", "Gestão em Saúde"]
                ),
                selectedOption: 0,
                isRevealed: true,
                onOptionSelected: { _ in }
            )
            .padding()
        }
        .background(Color(.systemGray6))
    }
}
