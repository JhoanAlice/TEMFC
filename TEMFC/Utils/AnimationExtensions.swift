import SwiftUI

// Extensões para facilitar o uso de animações consistentes
extension Animation {
    // Animações predefinidas para uso em todo o aplicativo
    static var standardAppear: Animation {
        .spring(response: 0.5, dampingFraction: 0.7)
    }
    
    static var quickTransition: Animation {
        .easeInOut(duration: 0.2)
    }
    
    static var pageTransition: Animation {
        .spring(response: 0.4, dampingFraction: 0.8)
    }
}

// Modificadores personalizados para animações
extension View {
    // Efeito de fade-in ao aparecer
    func fadeInOnAppear(delay: Double = 0) -> some View {
        self.modifier(FadeInModifier(delay: delay))
    }
    
    // Efeito de slide para o lado nas transições de perguntas
    func slideTransition(_ direction: Edge = .trailing) -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: direction).combined(with: .opacity),
            removal: .move(edge: direction.opposite).combined(with: .opacity)
        ))
    }
}

// Modificador para efeito de fade-in
struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.7).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// Extensão para obter a borda oposta
extension Edge {
    var opposite: Edge {
        switch self {
        case .top: return .bottom
        case .leading: return .trailing
        case .bottom: return .top
        case .trailing: return .leading
        }
    }
}
