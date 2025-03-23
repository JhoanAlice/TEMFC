// TEMFC/Components/TagSelectionRow.swift

import SwiftUI

struct TEMFCTagSelectionRow: View {   // Mudança do nome para evitar conflito
    let tag: String
    let isSelected: Bool
    let tagColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                HStack(spacing: 12) {
                    Text(tag)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("")
                        .frame(width: 12, height: 12)
                        .background(Circle().fill(tagColor))
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : Color(.secondaryLabel))
                    .font(.system(size: 22))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 4)
    }
}
