import SwiftUI

struct OptionButtonView: View {
    let option: String
    let index: Int
    let selectedIndex: Int?
    let correctIndex: Int?
    let isNullified: Bool
    let action: () -> Void

    // Adicionar estado para controlar o efeito de pressionar
    @State private var isPressed = false

    // Removida a keyword private para tornar o array acessível
    let optionLetters = ["A", "B", "C", "D"]

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Letra da opção (A, B, C, D)
                ZStack {
                    Circle()
                        .fill(getLetterBackgroundColor())
                        .frame(width: 32, height: 32)
                    
                    Text(optionLetters[index])
                        .font(.headline)
                        .foregroundColor(getLetterForegroundColor())
                }
                .padding(.top, 2)
                
                // Texto da opção
                Text(option)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // Ícone de seleção/resultado
                if selectedIndex == index || (correctIndex == index && correctIndex != nil) {
                    Image(systemName: getOptionIconName())
                        .foregroundColor(getOptionColor())
                        .padding(.top, 2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(selectedIndex == index ? getOptionColor() : Color.gray.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedIndex == index ? getOptionColor().opacity(0.1) : Color(UIColor.systemBackground))
                    )
            )
            // Adicionar efeito de escala
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        // Detectar quando o botão está sendo pressionado
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: 50, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .disabled(correctIndex != nil) // Desabilita após a resposta ser revelada
    }
    
    // Determina a cor da opção baseada no contexto
    func getOptionColor() -> Color {
        guard let correctIndex = correctIndex else {
            return Color.blue // Opção selecionada, mas ainda não revelada a correta
        }
        
        if isNullified {
            return Color.orange // Questão anulada
        }
        
        if index == correctIndex {
            return Color.green // Opção correta
        } else if index == selectedIndex {
            return Color.red // Opção incorreta selecionada
        }
        
        return Color.blue // Padrão
    }
    
    // Define qual ícone mostrar
    func getOptionIconName() -> String {
        guard let correctIndex = correctIndex else {
            return "circle.fill" // Opção selecionada antes de revelar
        }
        
        if isNullified {
            return "exclamationmark.circle.fill" // Questão anulada
        }
        
        if index == correctIndex {
            return "checkmark.circle.fill" // Resposta correta
        } else if index == selectedIndex {
            return "xmark.circle.fill" // Resposta incorreta
        }
        
        return "circle.fill" // Padrão
    }
    
    // Cor de fundo da letra (A, B, C, D)
    func getLetterBackgroundColor() -> Color {
        if selectedIndex == index {
            return getOptionColor()
        } else if correctIndex == index && correctIndex != nil {
            return Color.green
        }
        return Color.gray.opacity(0.1)
    }
    
    // Cor do texto da letra
    func getLetterForegroundColor() -> Color {
        if selectedIndex == index || (correctIndex == index && correctIndex != nil) {
            return .white
        }
        return .primary
    }
}

struct OptionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Opção não selecionada
            OptionButtonView(
                option: "Esta é uma opção de exemplo",
                index: 0,
                selectedIndex: nil,
                correctIndex: nil,
                isNullified: false,
                action: {}
            )
            
            // Opção selecionada antes de revelar a resposta
            OptionButtonView(
                option: "Esta é uma opção selecionada",
                index: 0,
                selectedIndex: 0,
                correctIndex: nil,
                isNullified: false,
                action: {}
            )
            
            // Opção correta (revelada)
            OptionButtonView(
                option: "Esta é a opção correta",
                index: 1,
                selectedIndex: 1,
                correctIndex: 1,
                isNullified: false,
                action: {}
            )
            
            // Opção incorreta selecionada (revelada)
            OptionButtonView(
                option: "Esta é uma opção incorreta",
                index: 2,
                selectedIndex: 2,
                correctIndex: 1,
                isNullified: false,
                action: {}
            )
            
            // Questão anulada
            OptionButtonView(
                option: "Esta é uma opção de questão anulada",
                index: 3,
                selectedIndex: 3,
                correctIndex: nil,
                isNullified: true,
                action: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
