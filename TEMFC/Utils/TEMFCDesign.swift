// TEMFC/Utils/TEMFCDesign.swift

import SwiftUI

/// Design System do App TEMFC
struct TEMFCDesign {
    // MARK: - Tipografia
    struct Typography {
        // Títulos
        static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
        static let title = Font.system(.title, design: .rounded, weight: .bold)
        static let title2 = Font.system(.title2, design: .rounded, weight: .semibold)
        static let title3 = Font.system(.title3, design: .rounded, weight: .semibold)
        
        // Corpo
        static let headline = Font.system(.headline, design: .rounded)
        static let subheadline = Font.system(.subheadline, design: .rounded)
        static let body = Font.system(.body, design: .rounded)
        static let callout = Font.system(.callout, design: .rounded)
        static let footnote = Font.system(.footnote, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded)
        static let caption2 = Font.system(.caption2, design: .rounded)
    }
    
    // MARK: - Cores
    struct Colors {
        // Cores principais
        static let primary = Color.blue
        static let secondary = Color(red: 0.25, green: 0.54, blue: 0.89)
        static let tertiary = Color(red: 0.0, green: 0.65, blue: 0.85)
        
        // Cores de acento
        static let accent = Color.orange
        static let accentSecondary = Color.yellow
        
        // Cores de estado
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
        static let info = Color.blue
        
        // Cores de fundo
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)
        
        // Cores de texto
        static let text = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let tertiaryText = Color(.tertiaryLabel)
        static let placeholderText = Color(.placeholderText)
        
        // Cores de separador e linha
        static let separator = Color(.separator)
        static let opaqueSeparator = Color(.opaqueSeparator)
        
        // Gradientes
        static let primaryGradient = LinearGradient(
            gradient: Gradient(colors: [primary, secondary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let accentGradient = LinearGradient(
            gradient: Gradient(colors: [accent, accentSecondary]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static func tagColor(for tag: String) -> Color {
            // Gera uma cor consistente baseada no hash da string
            let hash = abs(tag.hashValue)
            
            // Use cores previamente definidas para categorias comuns
            // Adicione mais mapeamentos conforme necessário
            let tagMap: [String: Color] = [
                "Saúde da Mulher": Color(red: 0.9, green: 0.4, blue: 0.7),
                "Saúde da Criança": Color(red: 0.4, green: 0.7, blue: 0.9),
                "Saúde Mental": Color(red: 0.5, green: 0.3, blue: 0.8),
                "Medicina centrada na pessoa": Color(red: 0.3, green: 0.8, blue: 0.5),
                "Atenção Primária à Saúde": Color(red: 0.2, green: 0.6, blue: 0.9),
                "Saúde do Idoso": Color(red: 0.7, green: 0.5, blue: 0.2),
                "Urgências em APS": Color(red: 0.9, green: 0.3, blue: 0.3),
                "Doenças Crônicas": Color(red: 0.6, green: 0.2, blue: 0.6)
            ]
            
            // Verifique por correspondências parciais
            for (key, color) in tagMap {
                if tag.contains(key) || key.contains(tag) {
                    return color
                }
            }
            
            // Gera uma cor baseada no hash se não encontrou correspondência
            let hue = Double(hash % 1000) / 1000.0
            return Color(hue: hue, saturation: 0.7, brightness: 0.9)
        }
    }
    
    // MARK: - Espaçamento
    struct Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Bordas e Cantos
    struct BorderRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 24
        static let pill: CGFloat = 999
    }
    
    // MARK: - Sombras
    struct Shadows {
        static let small: Shadow = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let medium: Shadow = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let large: Shadow = Shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        static let xl: Shadow = Shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Animações
    struct Animations {
        static let short = Animation.easeInOut(duration: 0.2)
        static let medium = Animation.easeInOut(duration: 0.3)
        static let long = Animation.easeInOut(duration: 0.5)
        
        static let springGentle = Animation.spring(response: 0.5, dampingFraction: 0.7)
        static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.5)
        static let springSnappy = Animation.spring(response: 0.3, dampingFraction: 0.8)
    }
    
    // MARK: - Feedback Háptico
    struct HapticFeedback {
        private static let impactLight = UIImpactFeedbackGenerator(style: .light)
        private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        private static let notificationFeedback = UINotificationFeedbackGenerator()
        
        // Preparar geradores (chame no início da view)
        static func prepareAll() {
            impactLight.prepare()
            impactMedium.prepare()
            impactHeavy.prepare()
            notificationFeedback.prepare()
        }
        
        // Impactos
        static func lightImpact() {
            impactLight.impactOccurred()
        }
        
        static func mediumImpact() {
            impactMedium.impactOccurred()
        }
        
        static func heavyImpact() {
            impactHeavy.impactOccurred()
        }
        
        // Notificações
        static func success() {
            notificationFeedback.notificationOccurred(.success)
        }
        
        static func warning() {
            notificationFeedback.notificationOccurred(.warning)
        }
        
        static func error() {
            notificationFeedback.notificationOccurred(.error)
        }
        
        // Feedback de seleção
        static func selectionChanged() {
            lightImpact()
        }
        
        static func buttonPressed() {
            mediumImpact()
        }
    }
    
    // MARK: - Componentes de UI
    
    // Card
    struct Card: ViewModifier {
        var padding: CGFloat = Spacing.m
        var cornerRadius: CGFloat = BorderRadius.medium
        var shadowStyle: Shadow = Shadows.medium
        var backgroundColor: Color = Colors.background
        
        func body(content: Content) -> some View {
            content
                .padding(padding)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .shadow(color: shadowStyle.color, radius: shadowStyle.radius, x: shadowStyle.x, y: shadowStyle.y)
                )
        }
    }
    
    // Tag
    struct Tag: ViewModifier {
        var backgroundColor: Color
        var textColor: Color = .white
        
        func body(content: Content) -> some View {
            content
                .font(Typography.caption)
                .padding(.horizontal, Spacing.s)
                .padding(.vertical, Spacing.xxs)
                .background(
                    Capsule()
                        .fill(backgroundColor.opacity(0.8))
                )
                .foregroundColor(textColor)
        }
    }
    
    // ActionButton
    struct ActionButton: ViewModifier {
        var isPrimary: Bool = true
        var isFullWidth: Bool = false
        
        func body(content: Content) -> some View {
            content
                .font(Typography.headline)
                .padding(.vertical, Spacing.xs)
                .padding(.horizontal, Spacing.m)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .background(
                    RoundedRectangle(cornerRadius: BorderRadius.medium)
                        .fill(isPrimary ? Colors.primary : Colors.background)
                        .shadow(color: (isPrimary ? Colors.primary : Colors.separator).opacity(0.3), radius: 4, x: 0, y: 2)
                )
                .foregroundColor(isPrimary ? .white : Colors.primary)
        }
    }
    
    // NavBar
    struct NavBar: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, Spacing.s)
                .background(
                    Rectangle()
                        .fill(Colors.background)
                        .shadow(color: Colors.separator.opacity(0.5), radius: 5, x: 0, y: 5)
                )
        }
    }
    
    // MARK: - Extensions para uso fácil
    
    // Card extension
    static func card(
        padding: CGFloat = Spacing.m,
        cornerRadius: CGFloat = BorderRadius.medium,
        shadowStyle: Shadow = Shadows.medium,
        backgroundColor: Color = Colors.background
    ) -> Card {
        return Card(padding: padding, cornerRadius: cornerRadius, shadowStyle: shadowStyle, backgroundColor: backgroundColor)
    }
    
    // Tag extension
    static func tag(backgroundColor: Color, textColor: Color = .white) -> Tag {
        return Tag(backgroundColor: backgroundColor, textColor: textColor)
    }
    
    // ActionButton extension
    static func actionButton(isPrimary: Bool = true, isFullWidth: Bool = false) -> ActionButton {
        return ActionButton(isPrimary: isPrimary, isFullWidth: isFullWidth)
    }
    
    // NavBar extension
    static func navBar() -> NavBar {
        return NavBar()
    }
}

// Extensões para facilitar o uso
extension View {
    func temfcCard(
        padding: CGFloat = TEMFCDesign.Spacing.m,
        cornerRadius: CGFloat = TEMFCDesign.BorderRadius.medium,
        shadowStyle: Shadow = TEMFCDesign.Shadows.medium,
        backgroundColor: Color = TEMFCDesign.Colors.background
    ) -> some View {
        self.modifier(TEMFCDesign.Card(padding: padding, cornerRadius: cornerRadius, shadowStyle: shadowStyle, backgroundColor: backgroundColor))
    }
    
    func temfcTag(backgroundColor: Color, textColor: Color = .white) -> some View {
        self.modifier(TEMFCDesign.Tag(backgroundColor: backgroundColor, textColor: textColor))
    }
    
    func temfcActionButton(isPrimary: Bool = true, isFullWidth: Bool = false) -> some View {
        self.modifier(TEMFCDesign.ActionButton(isPrimary: isPrimary, isFullWidth: isFullWidth))
    }
    
    func temfcNavBar() -> some View {
        self.modifier(TEMFCDesign.NavBar())
    }
}

// Helper para shadow
struct Shadow {
    var color: Color
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat
}
