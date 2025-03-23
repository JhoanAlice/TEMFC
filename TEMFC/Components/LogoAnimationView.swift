import SwiftUI

struct LogoAnimationView: View {
    @State private var isAnimating = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo principal
            Text("TEMFC")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .scaleEffect(isAnimating ? 1.0 : scale)
                .opacity(opacity)
            
            Text("Simulados para Medicina de Família e Comunidade")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                isAnimating = true
                opacity = 1.0
                scale = 1.0
            }
        }
    }
}

// Prévia para visualização no SwiftUI Canvas
struct LogoAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            LogoAnimationView()
        }
        .ignoresSafeArea()
    }
}
