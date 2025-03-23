import SwiftUI

struct TEMFCCard<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content
    var showShadow: Bool = true
    var accentColor: Color = TEMFCDesign.Colors.primary
    
    init(title: String, systemImage: String, showShadow: Bool = true, accentColor: Color = TEMFCDesign.Colors.primary, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.showShadow = showShadow
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label {
                    Text(title)
                        .font(TEMFCDesign.Typography.headline)
                        .foregroundStyle(TEMFCDesign.Colors.text)
                } icon: {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(accentColor)
                }
                
                Spacer()
            }
            
            content
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: TEMFCDesign.BorderRadius.medium)
                .fill(Color(uiColor: .systemBackground))
                .if(showShadow) { view in
                    view.shadow(
                        color: Color.black.opacity(0.1),
                        radius: 10,
                        x: 0,
                        y: 4
                    )
                }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// Helper modifier for conditional modifiers
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
