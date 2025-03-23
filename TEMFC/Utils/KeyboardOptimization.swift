import SwiftUI
import UIKit

// Configurações globais para otimização de teclado
struct KeyboardOptimization {
    static func setupKeyboard() {
        // Garantir que a configuração do teclado seja feita na thread principal
        DispatchQueue.main.async {
            UITextField.appearance().autocorrectionType = .no
        }
    }
    
    // Adicionar um método que pode ser chamado diretamente nas views
    static func applyTextFieldSettings() {
        DispatchQueue.main.async {
            UITextField.appearance().autocorrectionType = .no
            UITextField.appearance().spellCheckingType = .no
        }
    }
}
