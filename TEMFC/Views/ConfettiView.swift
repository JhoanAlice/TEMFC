// Crie um novo arquivo: TEMFC/Views/ConfettiView.swift

import SwiftUI

struct ConfettiView: View {
    @State private var isActive = false
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { i in
                ConfettiPiece(color: colors.randomElement()!)
                    .offset(x: .random(in: -UIScreen.main.bounds.width...UIScreen.main.bounds.width),
                            y: isActive ? .random(in: 0...UIScreen.main.bounds.height) : -50)
                    .animation(
                        Animation.linear(duration: .random(in: 1...3))
                            .repeatForever(autoreverses: false)
                            .delay(.random(in: 0...1)),
                        value: isActive
                    )
            }
        }
        .onAppear {
            isActive = true
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    @State private var rotation = Double.random(in: 0...360)
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = rotation + 360
                }
            }
    }
}
