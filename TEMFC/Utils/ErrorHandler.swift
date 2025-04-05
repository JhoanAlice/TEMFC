// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/Utils/ErrorHandler.swift

import Foundation
import SwiftUI

enum TEMFCError: Error, Identifiable {
    case dataLoading(String)
    case userDataCorruption(String)
    case networkError(String)
    case unexpectedError(String)
    
    // Propriedade id necessária para conformidade com Identifiable
    var id: String {
        switch self {
        case .dataLoading(let message):
            return "dataLoading_\(message)"
        case .userDataCorruption(let message):
            return "userDataCorruption_\(message)"
        case .networkError(let message):
            return "networkError_\(message)"
        case .unexpectedError(let message):
            return "unexpectedError_\(message)"
        }
    }
    
    var description: String {
        switch self {
        case .dataLoading(let message):
            return "Erro ao carregar dados: \(message)"
        case .userDataCorruption(let message):
            return "Erro nos dados do usuário: \(message)"
        case .networkError(let message):
            return "Erro de rede: \(message)"
        case .unexpectedError(let message):
            return "Erro inesperado: \(message)"
        }
    }
}

class ErrorHandler {
    static let shared = ErrorHandler()
    
    private init() {}
    
    func handle(_ error: TEMFCError, file: String = #file, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("❌ [\(fileName):\(line)] \(error.description)")
        
        #if DEBUG
        // Registro mais detalhado em modo debug
        print("Stack trace:")
        Thread.callStackSymbols.forEach { print($0) }
        #endif
        
        // Enviar para serviço de analytics ou crash reporting em produção
        AnalyticsService.shared.logEvent(.featureUsed, parameters: [
            "action": "error",
            "error_type": String(describing: error),
            "error_description": error.description
        ])
    }
    
    // Método para apresentar um alerta de erro
    func showError(_ error: TEMFCError, in viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Ops, ocorreu um erro",
            message: error.description,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}

// Extensão para View para mostrar erros
extension View {
    func handleError(_ error: Binding<TEMFCError?>) -> some View {
        return self.alert(item: error) { currentError in
            Alert(
                title: Text("Erro"),
                message: Text(currentError.description),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
