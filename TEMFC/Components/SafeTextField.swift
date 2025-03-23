import SwiftUI

struct SafeTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(.placeholderText))
                    .padding(.horizontal, 4)
            }
            
            TextField("", text: $text)
                .disableAutocorrection(true)
                .autocapitalization(.none)
        }
    }
}
