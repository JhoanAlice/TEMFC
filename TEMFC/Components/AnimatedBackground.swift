// TEMFC/Views/Components/AnimatedBackground.swift

import SwiftUI

struct AnimatedBackground: View {
    let colors: [Color]
    @State private var start = UnitPoint(x: 0, y: 0)
    @State private var end = UnitPoint(x: 1, y: 1)
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    self.start = UnitPoint(x: 1, y: 0)
                    self.end = UnitPoint(x: 0, y: 1)
                }
            }
    }
}
