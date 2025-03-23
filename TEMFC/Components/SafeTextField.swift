import SwiftUI

struct SafeTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false  // Defina como true para utilizar um campo seguro

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}
