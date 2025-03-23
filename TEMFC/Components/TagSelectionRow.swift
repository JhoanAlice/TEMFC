import SwiftUI

struct TEMFCTagSelectionRow: View {
    let tag: String
    let isSelected: Bool
    let tagColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                HStack(spacing: 12) {
                    Text(tag)
                        .font(TEMFCDesign.Typography.body)
                        .foregroundColor(isSelected ? .white : TEMFCDesign.Colors.text)
                    
                    Spacer()
                    
                    // Pequeno círculo com a cor da tag
                    Circle()
                        .fill(tagColor)
                        .frame(width: 12, height: 12)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? tagColor : TEMFCDesign.Colors.secondaryText)
                    .font(.system(size: 22))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                    .fill(isSelected ? tagColor.opacity(0.15) : TEMFCDesign.Colors.background)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                    .stroke(isSelected ? tagColor : Color.clear, lineWidth: isSelected ? 1 : 0)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 4)
    }
}

struct TEMFCTagSelectionRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            TEMFCTagSelectionRow(
                tag: "Saúde da Mulher",
                isSelected: true,
                tagColor: TEMFCDesign.Colors.tagColor(for: "Saúde da Mulher")
            ) { }
            
            TEMFCTagSelectionRow(
                tag: "Diagnóstico",
                isSelected: false,
                tagColor: TEMFCDesign.Colors.tagColor(for: "Diagnóstico")
            ) { }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
