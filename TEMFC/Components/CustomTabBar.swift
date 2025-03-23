import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let items: [TabBarItem]
    
    // Feedback háptico
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack {
            ForEach(0..<items.count, id: \.self) { index in
                Spacer()
                tabButton(item: items[index], index: index)
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func tabButton(item: TabBarItem, index: Int) -> some View {
        Button(action: {
            impactFeedback.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                // Ícone com efeito de fundo para o item selecionado
                ZStack {
                    if selectedTab == index {
                        Circle()
                            .fill(TEMFCDesign.Colors.primary.opacity(0.2))
                            .frame(width: 40, height: 40)
                    }
                    
                    Image(systemName: selectedTab == index ? item.selectedIcon : item.icon)
                        .font(.system(size: 20))
                        .foregroundColor(selectedTab == index ? TEMFCDesign.Colors.primary : .gray)
                }
                
                // Texto com animação de opacidade
                Text(item.title)
                    .font(TEMFCDesign.Typography.caption)
                    .fontWeight(selectedTab == index ? .bold : .regular)
                    .foregroundColor(selectedTab == index ? TEMFCDesign.Colors.primary : .gray)
                    .opacity(selectedTab == index ? 1 : 0.7)
            }
            .frame(height: 50)
        }
    }
}

// Modelo de item do TabBar
struct TabBarItem {
    let title: String
    let icon: String
    let selectedIcon: String
}
