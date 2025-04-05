// Caminho: TEMFC/Views/EnhancedOptionButton.swift

import SwiftUI

struct EnhancedOptionButton: View {
    let option: String
    let index: Int
    let selectedIndex: Int?
    let correctIndex: Int?
    let isNullified: Bool
    let action: () -> Void
    
    // Estado para controlar o efeito de pressionar
    @State var isPressed = false
    
    // Array de letras das alternativas
    let optionLetters = ["A", "B", "C", "D"]
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Letra da opção (A, B, C, D)
                ZStack {
                    Circle()
                        .fill(getLetterBackgroundColor())
                        .frame(width: 36, height: 36)
                        .shadow(color: getLetterBackgroundColor().opacity(0.4), radius: 3, x: 0, y: 2)
                    
                    Text(optionLetters[index])
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Texto da opção
                Text(option)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true) // Evita truncamento do texto
                    .padding(.vertical, 8)
                
                Spacer()
                
                // Ícone de status (se aplicável)
                if let correctIndex = correctIndex, (index == selectedIndex || index == correctIndex) {
                    Image(systemName: getIconName())
                        .font(.title3)
                        .foregroundColor(getIconColor())
                        .padding(.top, 8)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        // Acessibilidade melhorada
        .accessibility(identifier: "optionButton_\(index)")
        .accessibility(label: Text("Opção \(optionLetters[index]): \(option)"))
        .accessibility(hint: Text(correctIndex != nil ?
            (index == correctIndex ? "Resposta correta" :
            (index == selectedIndex ? "Resposta incorreta" : "")) : ""))
        .accessibility(addTraits: selectedIndex == index ? .isSelected : [])
        .accessibility(addTraits: correctIndex == index ? .playsSound : [])
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(getBorderColor(), lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(getFillColor())
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: 50, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .disabled(correctIndex != nil)
    }
    
    // MARK: - Métodos de Customização Visual
    
    // Cor de fundo para o círculo da letra
    func getLetterBackgroundColor() -> Color {
        if isNullified {
            return .orange
        }
        
        if let correctIndex = correctIndex {
            if index == correctIndex {
                return .green
            } else if index == selectedIndex {
                return .red
            }
        }
        
        return selectedIndex == index ? .blue : Color(.systemGray4)
    }
    
    // Cor da borda do retângulo
    func getBorderColor() -> Color {
        if isNullified {
            return .orange
        }
        
        if let correctIndex = correctIndex {
            if index == correctIndex {
                return .green
            } else if index == selectedIndex {
                return .red
            }
        }
        
        return selectedIndex == index ? .blue : Color(.systemGray4).opacity(0.5)
    }
    
    // Cor de preenchimento do retângulo
    func getFillColor() -> Color {
        if let correctIndex = correctIndex {
            if index == correctIndex {
                return Color.green.opacity(0.1)
            } else if index == selectedIndex {
                return Color.red.opacity(0.05)
            }
        }
        
        return selectedIndex == index ? Color.blue.opacity(0.05) : Color(.systemBackground)
    }
    
    // Nome do ícone
    func getIconName() -> String {
        if isNullified {
            return "exclamationmark.circle.fill"
        }
        
        if let correctIndex = correctIndex {
            if index == correctIndex {
                return "checkmark.circle.fill"
            } else if index == selectedIndex {
                            return "xmark.circle.fill"
                        }
                    }
                    
                    return "circle.fill"
                }
                
                // Cor do ícone
                func getIconColor() -> Color {
                    if isNullified {
                        return .orange
                    }
                    
                    if let correctIndex = correctIndex {
                        if index == correctIndex {
                            return .green
                        } else if index == selectedIndex {
                            return .red
                        }
                    }
                    
                    return .blue
                }
            }
