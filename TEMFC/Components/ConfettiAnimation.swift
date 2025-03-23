import SwiftUI

struct ExamConfettiPiece: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let rotation: Double
    let color: Color
    let speed: Double
}

struct ExamConfettiView: View {
    @State private var pieces: [ExamConfettiPiece] = []
    @State private var timer: Timer?
    
    private let colors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .pink
    ]
    
    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(piece.position)
                    .rotationEffect(.degrees(piece.rotation))
            }
        }
        .onAppear {
            generateConfetti()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func generateConfetti() {
        let screenWidth = UIScreen.main.bounds.width
        // Removido o valor não utilizado de screenHeight
        var newPieces: [ExamConfettiPiece] = []
        
        for _ in 0..<100 {
            let position = CGPoint(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: -100...0)
            )
            
            let piece = ExamConfettiPiece(
                position: position,
                size: CGFloat.random(in: 5...10),
                rotation: Double.random(in: 0...360),
                color: colors.randomElement()!,
                speed: Double.random(in: 1...5)
            )
            
            newPieces.append(piece)
        }
        
        pieces = newPieces
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updatePieces()
        }
    }
    
    private func updatePieces() {
        guard !pieces.isEmpty else { return }
        
        var newPieces = [ExamConfettiPiece]()
        let screenHeight = UIScreen.main.bounds.height
        
        for piece in pieces {
            if piece.position.y < screenHeight + 50 {
                let newPosition = CGPoint(
                    x: piece.position.x + CGFloat.random(in: -2...2),
                    y: piece.position.y + CGFloat(piece.speed)
                )
                
                let newRotation = piece.rotation + Double.random(in: -5...5)
                
                let newPiece = ExamConfettiPiece(
                    position: newPosition,
                    size: piece.size,
                    rotation: newRotation,
                    color: piece.color,
                    speed: piece.speed
                )
                
                newPieces.append(newPiece)
            }
        }
        
        pieces = newPieces
        
        if pieces.isEmpty {
            timer?.invalidate()
            timer = nil
        }
    }
}
