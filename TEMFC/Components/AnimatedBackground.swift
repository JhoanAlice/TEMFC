import SwiftUI

struct AnimatedBackground: View {
    let colors: [Color]
    let duration: Double
    
    @State private var start = UnitPoint(x: 0, y: 0)
    @State private var end = UnitPoint(x: 1, y: 1)
    
    init(colors: [Color], duration: Double = 5) {
        self.colors = colors
        self.duration = duration
    }
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    self.start = UnitPoint(x: 1, y: 0)
                    self.end = UnitPoint(x: 0, y: 1)
                }
            }
    }
}

struct AnimatedBackground_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedBackground(colors: [.blue, .purple, .blue.opacity(0.8)])
    }
}
