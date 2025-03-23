import SwiftUI
import UIKit

struct MainThreadTextField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .none
    
    func makeUIView(context: Context) -> UITextField {
        let textField: UITextField
        if Thread.isMainThread {
            textField = createTextField(context: context)
        } else {
            let semaphore = DispatchSemaphore(value: 0)
            var result: UITextField!
            DispatchQueue.main.async {
                result = self.createTextField(context: context)
                semaphore.signal()
            }
            semaphore.wait()
            textField = result
        }
        return textField
    }
    
    private func createTextField(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = autocapitalization
        textField.autocorrectionType = .no
        textField.delegate = context.coordinator
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }
    }
}
