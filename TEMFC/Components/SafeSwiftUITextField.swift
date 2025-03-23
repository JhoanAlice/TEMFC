import SwiftUI

struct SafeSwiftUITextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .none
    var foregroundColor: Color = .primary
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(textCapitalization())
            .foregroundColor(foregroundColor)
    }
    
    // Converte o enum do UIKit para o equivalente em SwiftUI
    private func textCapitalization() -> TextInputAutocapitalization {
        switch autocapitalization {
        case .none:
            return .never
        case .words:
            return .words
        case .sentences:
            return .sentences
        case .allCharacters:
            return .characters
        @unknown default:
            return .never
        }
    }
}

// Exemplo de Preview para testes no Xcode
struct SafeSwiftUITextField_Previews: PreviewProvider {
    @State static var previewText = ""
    
    static var previews: some View {
        SafeSwiftUITextField(
            placeholder: "Digite algo...",
            text: $previewText,
            keyboardType: .default,
            autocapitalization: .sentences,
            foregroundColor: .blue
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
