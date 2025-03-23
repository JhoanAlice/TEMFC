// Caminho: TEMFC/Utils/DynamicTheme.swift

import SwiftUI

// Melhorando o sistema de temas dinâmicos
extension TEMFCDesign {
    struct ThemeManager {
        // Função que retorna cores adaptáveis ao modo claro/escuro
        static func adaptiveColor(light: Color, dark: Color) -> Color {
            @Environment(\.colorScheme) var colorScheme
            return colorScheme == .dark ? dark : light
        }
        
        // Paleta de cores adaptáveis
        struct AdaptiveColors {
            static var background: Color {
                adaptiveColor(light: .white, dark: Color(hex: "1C1C1E"))
            }
            
            static var cardBackground: Color {
                adaptiveColor(light: .white, dark: Color(hex: "2C2C2E"))
            }
            
            static var text: Color {
                adaptiveColor(light: .black, dark: .white)
            }
            
            static var secondaryText: Color {
                adaptiveColor(light: .gray, dark: Color(hex: "EBEBF5").opacity(0.6))
            }
        }
    }
}

// Extensão para facilitar o uso de cores hexadecimais
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
