// TEMFC/Utils/TEMFCDesign.swift

import SwiftUI

/// Main design system for the TEMFC app
struct TEMFCDesign {
    // MARK: - Typography
    struct Typography {
        // Titles
        static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
        static let title = Font.system(.title, design: .rounded, weight: .bold)
        static let title2 = Font.system(.title2, design: .rounded, weight: .semibold)
        static let title3 = Font.system(.title3, design: .rounded, weight: .semibold)
        
        // Body
        static let headline = Font.system(.headline, design: .rounded)
        static let subheadline = Font.system(.subheadline, design: .rounded)
        static let body = Font.system(.body, design: .rounded)
        static let callout = Font.system(.callout, design: .rounded)
        static let footnote = Font.system(.footnote, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded)
        static let caption2 = Font.system(.caption2, design: .rounded)
    }
    
    // MARK: - Colors
    struct Colors {
        // Primary colors (modern blue tones)
        static let primary = Color(red: 0.0, green: 0.478, blue: 1.0)
        static let secondary = Color(red: 0.25, green: 0.54, blue: 0.89)
        static let tertiary = Color(red: 0.0, green: 0.65, blue: 0.85)
        
        // Accent colors
        static let accent = Color.orange
        static let accentSecondary = Color(red: 1.0, green: 0.8, blue: 0.0)
        
        // Status colors
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
        static let info = Color.blue
        
        // Background colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)
        
        // Text colors
        static let text = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let tertiaryText = Color(.tertiaryLabel)
        static let placeholderText = Color(.placeholderText)
        
        // Separator colors
        static let separator = Color(.separator)
        static let opaqueSeparator = Color(.opaqueSeparator)
        
        // Gradients
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
        
        // MARK: - Tag color generation

        /// Tag category color mapping
        private static let tagColorMap: [String: Color] = [
            // Main thematic areas
            "Saúde da Mulher": Color(red: 0.9, green: 0.4, blue: 0.6),         // Soft pink
            "Saúde da Criança": Color(red: 0.3, green: 0.7, blue: 0.9),        // Light blue
            "Saúde Mental": Color(red: 0.5, green: 0.4, blue: 0.8),            // Medium purple
            "Saúde do Idoso": Color(red: 0.8, green: 0.6, blue: 0.3),          // Golden amber
            "Medicina centrada na pessoa": Color(red: 0.3, green: 0.7, blue: 0.5), // Medium green
            "Atenção Primária à Saúde": Color(red: 0.2, green: 0.5, blue: 0.8), // Medium blue
            "Urgências em APS": Color(red: 0.9, green: 0.4, blue: 0.3),        // Soft red
            "Doenças Crônicas": Color(red: 0.6, green: 0.3, blue: 0.7),        // Medium purple
            
            // Additional categories
            "SUS": Color(red: 0.2, green: 0.6, blue: 0.8),                     // Sky blue
            "Prevenção e Promoção": Color(red: 0.4, green: 0.8, blue: 0.4),    // Soft lime green
            "Saúde Coletiva": Color(red: 0.5, green: 0.7, blue: 0.3),          // Olive green
            "Procedimentos": Color(red: 0.7, green: 0.4, blue: 0.3),           // Terracotta
            "Diagnóstico": Color(red: 0.3, green: 0.5, blue: 0.7),             // Steel blue
            "Terapêutica": Color(red: 0.5, green: 0.3, blue: 0.5),             // Medium purple
            "Ética e Bioética": Color(red: 0.7, green: 0.7, blue: 0.3)         // Mustard yellow
        ]
        
        /// Generate a color for a tag based on its content
        /// - Parameter tag: The tag string
        /// - Returns: A color appropriate for the tag
        static func tagColor(for tag: String) -> Color {
            // Check for exact and partial matches
            for (key, color) in tagColorMap {
                if tag.contains(key) || key.contains(tag) {
                    return color
                }
            }
            
            // Generate a color based on hash (refined for more pleasing colors)
            let hash = abs(tag.hashValue)
            let hue = Double(hash % 1000) / 1000.0
            let saturation = 0.6 + (Double(hash % 200) / 1000.0) // 0.6-0.8
            let brightness = 0.7 + (Double(hash % 200) / 1000.0)   // 0.7-0.9
            
            return Color(hue: hue, saturation: saturation, brightness: brightness)
        }
    }
    
    // MARK: - Spacing
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
    
    // MARK: - Border Radius
    struct BorderRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 24
        static let pill: CGFloat = 999
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let medium = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let large = Shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        static let xl = Shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Animations
    struct Animations {
        static let short = Animation.easeInOut(duration: 0.2)
        static let medium = Animation.easeInOut(duration: 0.3)
        static let long = Animation.easeInOut(duration: 0.5)
        
        static let springGentle = Animation.spring(response: 0.5, dampingFraction: 0.7)
        static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.5)
        static let springSnappy = Animation.spring(response: 0.3, dampingFraction: 0.8)
    }
    
    // MARK: - Haptic Feedback
    struct HapticFeedback {
        private static let impactLight = UIImpactFeedbackGenerator(style: .light)
        private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        private static let notificationFeedback = UINotificationFeedbackGenerator()
        
        /// Prepares all feedback generators for immediate use
        static func prepareAll() {
            impactLight.prepare()
            impactMedium.prepare()
            impactHeavy.prepare()
            notificationFeedback.prepare()
        }
        
        /// Generates a light impact feedback
        static func lightImpact() {
            impactLight.impactOccurred()
        }
        
        /// Generates a medium impact feedback
        static func mediumImpact() {
            impactMedium.impactOccurred()
        }
        
        /// Generates a heavy impact feedback
        static func heavyImpact() {
            impactHeavy.impactOccurred()
        }
        
        /// Generates a success notification feedback
        static func success() {
            notificationFeedback.notificationOccurred(.success)
        }
        
        /// Generates a warning notification feedback
        static func warning() {
            notificationFeedback.notificationOccurred(.warning)
        }
        
        /// Generates an error notification feedback
        static func error() {
            notificationFeedback.notificationOccurred(.error)
        }
        
        /// Feedback for selection changes
        static func selectionChanged() {
            lightImpact()
        }
        
        /// Feedback for button presses
        static func buttonPressed() {
            mediumImpact()
        }
    }
}

// MARK: - ViewModifiers

extension TEMFCDesign {
    // Card ViewModifier
    struct CardModifier: ViewModifier {
        var padding: CGFloat = TEMFCDesign.Spacing.m
        var cornerRadius: CGFloat = TEMFCDesign.BorderRadius.medium
        var shadow: Shadow = TEMFCDesign.Shadows.medium
        var backgroundColor: Color = TEMFCDesign.Colors.background
        
        func body(content: Content) -> some View {
            content
                .padding(padding)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
                )
        }
    }
    
    // Tag ViewModifier
    struct TagModifier: ViewModifier {
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
    
    // Button ViewModifier
    struct ButtonModifier: ViewModifier {
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
}

// MARK: - Shadow Helper

struct Shadow {
    var color: Color
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat
}

// MARK: - View Extensions

extension View {
    /// Applies the card style to a view
    func temfcCard(
        padding: CGFloat = TEMFCDesign.Spacing.m,
        cornerRadius: CGFloat = TEMFCDesign.BorderRadius.medium,
        shadow: Shadow = TEMFCDesign.Shadows.medium,
        backgroundColor: Color = TEMFCDesign.Colors.background
    ) -> some View {
        self.modifier(TEMFCDesign.CardModifier(
            padding: padding,
            cornerRadius: cornerRadius,
            shadow: shadow,
            backgroundColor: backgroundColor
        ))
    }
    
    /// Applies the tag style to a view
    func temfcTag(backgroundColor: Color, textColor: Color = .white) -> some View {
        self.modifier(TEMFCDesign.TagModifier(backgroundColor: backgroundColor, textColor: textColor))
    }
    
    /// Applies the button style to a view
    func temfcButton(isPrimary: Bool = true, isFullWidth: Bool = false) -> some View {
        self.modifier(TEMFCDesign.ButtonModifier(isPrimary: isPrimary, isFullWidth: isFullWidth))
    }
    
    /// Applies primary button style to a view
    func temfcPrimaryButton(isFullWidth: Bool = false) -> some View {
        self.temfcButton(isPrimary: true, isFullWidth: isFullWidth)
    }
    
    /// Applies secondary button style to a view
    func temfcSecondaryButton(isFullWidth: Bool = false) -> some View {
        self.temfcButton(isPrimary: false, isFullWidth: isFullWidth)
    }
}
